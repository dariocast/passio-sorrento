"""Admin Routes for Holyweek Tracker."""

import os
import uuid
import sqlite3
from datetime import datetime

from flask import (
    render_template, redirect, url_for, flash, request,
    current_app, send_file
)
from flask_login import login_user, logout_user, login_required, current_user

from . import admin_bp
from .forms import LoginForm, ConfraternityForm, ProcessionForm
from .. import db
from ..models import AdminUser, Confraternity, Procession, TrackingLog


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

@admin_bp.route('/login', methods=['GET', 'POST'])
def login():
    """Admin login page."""
    if current_user.is_authenticated:
        return redirect(url_for('admin.dashboard'))

    form = LoginForm()
    if form.validate_on_submit():
        user = AdminUser.query.filter_by(username=form.username.data).first()
        if user and user.check_password(form.password.data):
            login_user(user, remember=True)
            flash('Logged in successfully.', 'success')
            next_page = request.args.get('next')
            return redirect(next_page or url_for('admin.dashboard'))
        flash('Invalid username or password.', 'error')

    return render_template('admin/login.html', form=form)


@admin_bp.route('/logout')
@login_required
def logout():
    """Log out the current admin user."""
    logout_user()
    flash('Logged out.', 'success')
    return redirect(url_for('admin.login'))


# ---------------------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------------------

@admin_bp.route('/')
@login_required
def dashboard():
    """Admin dashboard with entity counts."""
    stats = {
        'confraternities': Confraternity.query.count(),
        'processions': Procession.query.count(),
        'tracking_logs': TrackingLog.query.count(),
        'live_processions': Procession.query.filter_by(is_live=True).count(),
    }
    return render_template('admin/dashboard.html', stats=stats)


# ---------------------------------------------------------------------------
# Confraternities CRUD
# ---------------------------------------------------------------------------

@admin_bp.route('/confraternities')
@login_required
def confraternities_list():
    """List all confraternities."""
    confraternities = Confraternity.query.order_by(Confraternity.name).all()
    return render_template(
        'admin/confraternities_list.html', confraternities=confraternities
    )


@admin_bp.route('/confraternities/create', methods=['GET', 'POST'])
@login_required
def confraternity_create():
    """Create a new confraternity."""
    form = ConfraternityForm()
    if form.validate_on_submit():
        confraternity = Confraternity(
            id=str(uuid.uuid4()),
            name=form.name.data,
            color=form.color.data,
            municipality=form.municipality.data,
            coat_of_arms=form.coat_of_arms.data or None,
            history=form.history.data or None,
        )
        db.session.add(confraternity)
        db.session.commit()
        flash(f'Confraternity "{confraternity.name}" created.', 'success')
        return redirect(url_for('admin.confraternities_list'))

    return render_template(
        'admin/confraternity_form.html', form=form, is_edit=False
    )


@admin_bp.route('/confraternities/<cid>/edit', methods=['GET', 'POST'])
@login_required
def confraternity_edit(cid: str):
    """Edit an existing confraternity."""
    confraternity = Confraternity.query.get_or_404(cid)
    form = ConfraternityForm(obj=confraternity)

    if form.validate_on_submit():
        confraternity.name = form.name.data
        confraternity.color = form.color.data
        confraternity.municipality = form.municipality.data
        confraternity.coat_of_arms = form.coat_of_arms.data or None
        confraternity.history = form.history.data or None
        db.session.commit()
        flash(f'Confraternity "{confraternity.name}" updated.', 'success')
        return redirect(url_for('admin.confraternities_list'))

    return render_template(
        'admin/confraternity_form.html',
        form=form, is_edit=True, confraternity=confraternity
    )


@admin_bp.route('/confraternities/<cid>/delete', methods=['POST'])
@login_required
def confraternity_delete(cid: str):
    """Delete a confraternity."""
    confraternity = Confraternity.query.get_or_404(cid)
    name = confraternity.name
    db.session.delete(confraternity)
    db.session.commit()
    flash(f'Confraternity "{name}" deleted.', 'success')
    return redirect(url_for('admin.confraternities_list'))


# ---------------------------------------------------------------------------
# Processions CRUD
# ---------------------------------------------------------------------------

def _populate_procession_choices(form: ProcessionForm) -> None:
    """Fill the confraternity select choices."""
    form.confraternity_id.choices = [
        (c.id, f'{c.name} ({c.municipality})')
        for c in Confraternity.query.order_by(Confraternity.name).all()
    ]


@admin_bp.route('/processions')
@login_required
def processions_list():
    """List all processions."""
    processions = Procession.query.order_by(Procession.exit_time).all()
    return render_template('admin/processions_list.html', processions=processions)


@admin_bp.route('/processions/create', methods=['GET', 'POST'])
@login_required
def procession_create():
    """Create a new procession."""
    form = ProcessionForm()
    _populate_procession_choices(form)

    if form.validate_on_submit():
        procession = Procession(
            id=str(uuid.uuid4()),
            confraternity_id=form.confraternity_id.data,
            day=form.day.data,
            exit_time=form.exit_time.data,
            expected_return_time=form.expected_return_time.data or None,
            is_live=form.is_live.data,
        )
        db.session.add(procession)
        db.session.commit()
        flash('Procession created.', 'success')
        return redirect(url_for('admin.processions_list'))

    return render_template(
        'admin/procession_form.html', form=form, is_edit=False
    )


@admin_bp.route('/processions/<pid>/edit', methods=['GET', 'POST'])
@login_required
def procession_edit(pid: str):
    """Edit an existing procession."""
    procession = Procession.query.get_or_404(pid)
    form = ProcessionForm(obj=procession)
    _populate_procession_choices(form)

    if form.validate_on_submit():
        procession.confraternity_id = form.confraternity_id.data
        procession.day = form.day.data
        procession.exit_time = form.exit_time.data
        procession.expected_return_time = form.expected_return_time.data or None
        procession.is_live = form.is_live.data
        db.session.commit()
        flash('Procession updated.', 'success')
        return redirect(url_for('admin.processions_list'))

    return render_template(
        'admin/procession_form.html',
        form=form, is_edit=True, procession=procession
    )


@admin_bp.route('/processions/<pid>/delete', methods=['POST'])
@login_required
def procession_delete(pid: str):
    """Delete a procession."""
    procession = Procession.query.get_or_404(pid)
    db.session.delete(procession)
    db.session.commit()
    flash('Procession deleted.', 'success')
    return redirect(url_for('admin.processions_list'))


@admin_bp.route('/processions/<pid>/toggle-live', methods=['POST'])
@login_required
def procession_toggle_live(pid: str):
    """Toggle the is_live flag on a procession."""
    procession = Procession.query.get_or_404(pid)
    procession.is_live = not procession.is_live
    db.session.commit()
    status = 'live' if procession.is_live else 'offline'
    flash(f'Procession set to {status}.', 'success')
    return redirect(url_for('admin.processions_list'))


# ---------------------------------------------------------------------------
# Tracking Logs (read + delete only)
# ---------------------------------------------------------------------------

@admin_bp.route('/tracking')
@login_required
def tracking_list():
    """List tracking logs with optional confraternity filter and pagination."""
    page = request.args.get('page', 1, type=int)
    per_page = 50
    confraternity_id = request.args.get('confraternity_id')

    query = TrackingLog.query.order_by(TrackingLog.timestamp.desc())
    if confraternity_id:
        query = query.filter_by(confraternity_id=confraternity_id)

    pagination = query.paginate(page=page, per_page=per_page, error_out=False)
    confraternities = Confraternity.query.order_by(Confraternity.name).all()

    return render_template(
        'admin/tracking_list.html',
        logs=pagination.items,
        pagination=pagination,
        confraternities=confraternities,
        selected_confraternity=confraternity_id,
    )


@admin_bp.route('/tracking/<int:log_id>/delete', methods=['POST'])
@login_required
def tracking_delete(log_id: int):
    """Delete a single tracking log entry."""
    log = TrackingLog.query.get_or_404(log_id)
    db.session.delete(log)
    db.session.commit()
    flash('Tracking log deleted.', 'success')
    return redirect(url_for('admin.tracking_list'))


# ---------------------------------------------------------------------------
# Backup
# ---------------------------------------------------------------------------

@admin_bp.route('/backup')
@login_required
def backup():
    """Download a consistent backup of the SQLite database."""
    db_uri = current_app.config['SQLALCHEMY_DATABASE_URI']
    db_path = db_uri.replace('sqlite:///', '')

    if not os.path.isabs(db_path):
        db_path = os.path.join(current_app.instance_path, db_path)

    if not os.path.exists(db_path):
        flash('Database file not found.', 'error')
        return redirect(url_for('admin.dashboard'))

    backup_name = f'holyweek_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}.db'
    backup_path = os.path.join(current_app.instance_path, backup_name)

    try:
        source = sqlite3.connect(db_path)
        dest = sqlite3.connect(backup_path)
        source.backup(dest)
        dest.close()
        source.close()

        response = send_file(
            backup_path, as_attachment=True, download_name=backup_name
        )

        @response.call_on_close
        def _cleanup():
            if os.path.exists(backup_path):
                os.remove(backup_path)

        return response
    except Exception as e:
        flash(f'Backup failed: {e}', 'error')
        return redirect(url_for('admin.dashboard'))


# ---------------------------------------------------------------------------
# CLI commands  (flask admin create-user ...)
# ---------------------------------------------------------------------------

import click  # noqa: E402


@admin_bp.cli.command('create-user')
@click.argument('username')
@click.password_option()
def create_admin_user(username: str, password: str) -> None:
    """Create a new admin user.  Usage: flask admin create-user <username>"""
    if AdminUser.query.filter_by(username=username).first():
        click.echo(f'Error: user "{username}" already exists.')
        raise SystemExit(1)

    user = AdminUser(username=username)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    click.echo(f'Admin user "{username}" created.')
