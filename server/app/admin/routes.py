"""Admin Routes for Passio Sorrento Management Portal."""

import os
import uuid
import sqlite3
from datetime import datetime
from functools import wraps

from flask import (
    render_template, redirect, url_for, flash, request,
    current_app, send_file, abort
)
from flask_login import login_user, logout_user, login_required, current_user

from . import admin_bp
from .forms import (
    LoginForm, UserForm, MunicipalityForm,
    ConfraternityForm, ProcessionForm
)
from .. import db, limiter
from ..models import AdminUser, Municipality, Confraternity, Procession, TrackingLog


# ---------------------------------------------------------------------------
# Role Authorization Decorators
# ---------------------------------------------------------------------------

def superadmin_required(f):
    """Decorator to restrict view exclusively to SUPERADMIN users."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated or not current_user.is_superadmin:
            flash('Accesso riservato esclusivamente al SuperAdmin.', 'error')
            return redirect(url_for('admin.dashboard'))
        return f(*args, **kwargs)
    return decorated_function


# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------

@admin_bp.route('/login', methods=['GET', 'POST'])
@limiter.limit("5 per 5 minutes", methods=["POST"])
def login():
    """Admin login page."""
    if current_user.is_authenticated:
        return redirect(url_for('admin.dashboard'))

    form = LoginForm()
    if form.validate_on_submit():
        user = AdminUser.query.filter_by(username=form.username.data).first()
        if user and user.is_active and user.check_password(form.password.data):
            login_user(user, remember=True)
            flash(f'Benvenuto, {user.username}! Accesso effettuato.', 'success')
            next_page = request.args.get('next')
            return redirect(next_page or url_for('admin.dashboard'))
        flash('Credenziali non valide o account disabilitato.', 'error')

    return render_template('admin/login.html', form=form)


@admin_bp.route('/logout')
@login_required
def logout():
    """Log out the current user."""
    logout_user()
    flash('Disconnessione effettuata con successo.', 'success')
    return redirect(url_for('admin.login'))


# ---------------------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------------------

@admin_bp.route('/')
@login_required
def dashboard():
    """Admin dashboard adaptive based on user role."""
    if current_user.is_superadmin:
        stats = {
            'municipalities': Municipality.query.count(),
            'confraternities': Confraternity.query.count(),
            'processions': Procession.query.count(),
            'tracking_logs': TrackingLog.query.count(),
            'live_processions': Procession.query.filter_by(is_live=True).count(),
            'users': AdminUser.query.count(),
        }
        recent_logs = TrackingLog.query.order_by(TrackingLog.timestamp.desc()).limit(10).all()
        live_processions = Procession.query.filter_by(is_live=True).all()
        return render_template(
            'admin/dashboard_superadmin.html',
            stats=stats,
            recent_logs=recent_logs,
            live_processions=live_processions
        )
    else:
        # Priore Dashboard
        confraternity = current_user.confraternity
        if not confraternity:
            flash('Nessuna confraternita associata a questo account. Contatta il SuperAdmin.', 'error')
            return render_template('admin/dashboard_priore.html', confraternity=None, processions=[])
        
        processions = Procession.query.filter_by(confraternity_id=confraternity.id).all()
        recent_logs = TrackingLog.query.filter_by(confraternity_id=confraternity.id).order_by(TrackingLog.timestamp.desc()).limit(10).all()
        return render_template(
            'admin/dashboard_priore.html',
            confraternity=confraternity,
            processions=processions,
            recent_logs=recent_logs
        )


# ---------------------------------------------------------------------------
# SuperAdmin: User Management (Priori & Admins)
# ---------------------------------------------------------------------------

@admin_bp.route('/users')
@login_required
@superadmin_required
def users_list():
    """List all registered users (Priori & SuperAdmins)."""
    users = AdminUser.query.order_by(AdminUser.role, AdminUser.username).all()
    return render_template('admin/users_list.html', users=users)


@admin_bp.route('/users/create', methods=['GET', 'POST'])
@login_required
@superadmin_required
def user_create():
    """Create a new Priore or SuperAdmin user."""
    form = UserForm()
    
    # Populate confraternities dropdown
    confraternities = Confraternity.query.order_by(Confraternity.name).all()
    form.confraternity_id.choices = [('', '-- Nessuna (SuperAdmin) --')] + [
        (c.id, f'{c.name} ({c.municipality})') for c in confraternities
    ]

    if form.validate_on_submit():
        if not form.password.data:
            flash('La password è obbligatoria per i nuovi utenti.', 'error')
            return render_template('admin/user_form.html', form=form, is_edit=False)

        existing = AdminUser.query.filter_by(username=form.username.data).first()
        if existing:
            flash(f'Lo username "{form.username.data}" è già in uso.', 'error')
            return render_template('admin/user_form.html', form=form, is_edit=False)

        user = AdminUser(
            username=form.username.data,
            email=form.email.data or None,
            role=form.role.data,
            confraternity_id=form.confraternity_id.data if form.confraternity_id.data else None,
            is_active=form.is_active.data,
        )
        user.set_password(form.password.data)
        db.session.add(user)
        db.session.commit()
        flash(f'Utente "{user.username}" creato con successo come {user.role}.', 'success')
        return redirect(url_for('admin.users_list'))

    return render_template('admin/user_form.html', form=form, is_edit=False)


@admin_bp.route('/users/<int:user_id>/edit', methods=['GET', 'POST'])
@login_required
@superadmin_required
def user_edit(user_id: int):
    """Edit user details and credentials."""
    user = AdminUser.query.get_or_404(user_id)
    form = UserForm(obj=user)

    confraternities = Confraternity.query.order_by(Confraternity.name).all()
    form.confraternity_id.choices = [('', '-- Nessuna (SuperAdmin) --')] + [
        (c.id, f'{c.name} ({c.municipality})') for c in confraternities
    ]

    if form.validate_on_submit():
        # Check if username changed and exists
        existing = AdminUser.query.filter(AdminUser.username == form.username.data, AdminUser.id != user.id).first()
        if existing:
            flash(f'Lo username "{form.username.data}" è già in uso da un altro account.', 'error')
            return render_template('admin/user_form.html', form=form, is_edit=True, user=user)

        user.username = form.username.data
        user.email = form.email.data or None
        user.role = form.role.data
        user.confraternity_id = form.confraternity_id.data if form.confraternity_id.data else None
        user.is_active = form.is_active.data

        if form.password.data:
            user.set_password(form.password.data)
            flash('Password aggiornata con successo.', 'info')

        db.session.commit()
        flash(f'Utente "{user.username}" modificato con successo.', 'success')
        return redirect(url_for('admin.users_list'))

    return render_template('admin/user_form.html', form=form, is_edit=True, user=user)


@admin_bp.route('/users/<int:user_id>/delete', methods=['POST'])
@login_required
@superadmin_required
def user_delete(user_id: int):
    """Delete a user account."""
    if user_id == current_user.id:
        flash('Non puoi eliminare il tuo stesso account.', 'error')
        return redirect(url_for('admin.users_list'))

    user = AdminUser.query.get_or_404(user_id)
    username = user.username
    db.session.delete(user)
    db.session.commit()
    flash(f'Utente "{username}" eliminato con successo.', 'success')
    return redirect(url_for('admin.users_list'))


# ---------------------------------------------------------------------------
# SuperAdmin: Municipalities Management
# ---------------------------------------------------------------------------

@admin_bp.route('/municipalities')
@login_required
@superadmin_required
def municipalities_list():
    """List all registered municipalities."""
    municipalities = Municipality.query.order_by(Municipality.display_order, Municipality.name).all()
    return render_template('admin/municipalities_list.html', municipalities=municipalities)


@admin_bp.route('/municipalities/create', methods=['GET', 'POST'])
@login_required
@superadmin_required
def municipality_create():
    """Add a new municipality with GPS coordinates."""
    form = MunicipalityForm()
    if form.validate_on_submit():
        existing = Municipality.query.filter_by(name=form.name.data).first()
        if existing:
            flash(f'Il comune "{form.name.data}" è già presente.', 'error')
            return render_template('admin/municipality_form.html', form=form, is_edit=False)

        municipality = Municipality(
            id=str(uuid.uuid4()),
            name=form.name.data,
            latitude=form.latitude.data,
            longitude=form.longitude.data,
            display_order=form.display_order.data,
            is_active=form.is_active.data,
        )
        db.session.add(municipality)
        db.session.commit()
        flash(f'Comune "{municipality.name}" aggiunto con successo.', 'success')
        return redirect(url_for('admin.municipalities_list'))

    return render_template('admin/municipality_form.html', form=form, is_edit=False)


@admin_bp.route('/municipalities/<municipality_id>/edit', methods=['GET', 'POST'])
@login_required
@superadmin_required
def municipality_edit(municipality_id: str):
    """Edit municipality coordinates and status."""
    municipality = Municipality.query.get_or_404(municipality_id)
    form = MunicipalityForm(obj=municipality)

    if form.validate_on_submit():
        municipality.name = form.name.data
        municipality.latitude = form.latitude.data
        municipality.longitude = form.longitude.data
        municipality.display_order = form.display_order.data
        municipality.is_active = form.is_active.data

        db.session.commit()
        flash(f'Comune "{municipality.name}" aggiornato.', 'success')
        return redirect(url_for('admin.municipalities_list'))

    return render_template('admin/municipality_form.html', form=form, is_edit=True, municipality=municipality)


@admin_bp.route('/municipalities/<municipality_id>/delete', methods=['POST'])
@login_required
@superadmin_required
def municipality_delete(municipality_id: str):
    """Delete or deactivate a municipality."""
    municipality = Municipality.query.get_or_404(municipality_id)
    if municipality.confraternities:
        flash(f'Impossibile eliminare il comune "{municipality.name}": ci sono confraternite collegate. Disattivalo invece.', 'error')
        return redirect(url_for('admin.municipalities_list'))

    name = municipality.name
    db.session.delete(municipality)
    db.session.commit()
    flash(f'Comune "{name}" eliminato.', 'success')
    return redirect(url_for('admin.municipalities_list'))


# ---------------------------------------------------------------------------
# Confraternities Management (SuperAdmin & Priori)
# ---------------------------------------------------------------------------

@admin_bp.route('/confraternities')
@login_required
def confraternities_list():
    """List confraternities."""
    if current_user.is_superadmin:
        confraternities = Confraternity.query.order_by(Confraternity.municipality, Confraternity.name).all()
    else:
        confraternities = [current_user.confraternity] if current_user.confraternity else []

    return render_template('admin/confraternities_list.html', confraternities=confraternities)


@admin_bp.route('/confraternities/create', methods=['GET', 'POST'])
@login_required
@superadmin_required
def confraternity_create():
    """Create a new confraternity (SuperAdmin only)."""
    form = ConfraternityForm()
    
    municipalities = Municipality.query.filter_by(is_active=True).order_by(Municipality.name).all()
    form.municipality_id.choices = [('', '-- Seleziona Comune --')] + [(m.id, m.name) for m in municipalities]

    if form.validate_on_submit():
        selected_m = Municipality.query.get(form.municipality_id.data) if form.municipality_id.data else None
        municipality_name = selected_m.name if selected_m else (form.municipality.data or 'Sorrento')

        confraternity = Confraternity(
            id=str(uuid.uuid4()),
            name=form.name.data,
            color=form.color.data,
            municipality_id=form.municipality_id.data if form.municipality_id.data else None,
            municipality=municipality_name,
            coat_of_arms=form.coat_of_arms.data or None,
            history=form.history.data or None,
            capofila_secret=form.capofila_secret.data or 'capofila123',
        )
        db.session.add(confraternity)
        db.session.commit()
        flash(f'Arciconfraternita "{confraternity.name}" creata con successo.', 'success')
        return redirect(url_for('admin.confraternities_list'))

    return render_template('admin/confraternity_form.html', form=form, is_edit=False)


@admin_bp.route('/confraternities/<confraternity_id>/edit', methods=['GET', 'POST'])
@login_required
def confraternity_edit(confraternity_id: str):
    """Edit confraternity details (SuperAdmin or assigned Priore)."""
    if not current_user.can_manage_confraternity(confraternity_id):
        abort(403)

    confraternity = Confraternity.query.get_or_404(confraternity_id)
    form = ConfraternityForm(obj=confraternity)

    municipalities = Municipality.query.filter_by(is_active=True).order_by(Municipality.name).all()
    form.municipality_id.choices = [('', '-- Seleziona Comune --')] + [(m.id, m.name) for m in municipalities]

    if form.validate_on_submit():
        selected_m = Municipality.query.get(form.municipality_id.data) if form.municipality_id.data else None
        municipality_name = selected_m.name if selected_m else (form.municipality.data or confraternity.municipality)

        confraternity.name = form.name.data
        confraternity.color = form.color.data
        confraternity.municipality_id = form.municipality_id.data if form.municipality_id.data else None
        confraternity.municipality = municipality_name
        confraternity.coat_of_arms = form.coat_of_arms.data or None
        confraternity.history = form.history.data or None
        confraternity.capofila_secret = form.capofila_secret.data or 'capofila123'

        db.session.commit()
        flash(f'Arciconfraternita "{confraternity.name}" aggiornata.', 'success')
        return redirect(url_for('admin.dashboard'))

    return render_template('admin/confraternity_form.html', form=form, is_edit=True, confraternity=confraternity)


@admin_bp.route('/confraternities/<confraternity_id>/delete', methods=['POST'])
@login_required
@superadmin_required
def confraternity_delete(confraternity_id: str):
    """Delete a confraternity (SuperAdmin only)."""
    confraternity = Confraternity.query.get_or_404(confraternity_id)
    name = confraternity.name
    db.session.delete(confraternity)
    db.session.commit()
    flash(f'Arciconfraternita "{name}" e tutte le relative processioni eliminate.', 'success')
    return redirect(url_for('admin.confraternities_list'))


# ---------------------------------------------------------------------------
# Processions Management (SuperAdmin & Priori)
# ---------------------------------------------------------------------------

@admin_bp.route('/processions')
@login_required
def processions_list():
    """List processions."""
    if current_user.is_superadmin:
        processions = Procession.query.order_by(Procession.exit_time).all()
    else:
        if current_user.confraternity_id:
            processions = Procession.query.filter_by(
                confraternity_id=current_user.confraternity_id
            ).order_by(Procession.exit_time).all()
        else:
            processions = []

    return render_template('admin/processions_list.html', processions=processions)


@admin_bp.route('/processions/create', methods=['GET', 'POST'])
@login_required
def procession_create():
    """Create a new procession."""
    form = ProcessionForm()

    if current_user.is_superadmin:
        confraternities = Confraternity.query.order_by(Confraternity.name).all()
        form.confraternity_id.choices = [(c.id, f'{c.name} ({c.municipality})') for c in confraternities]
    else:
        if not current_user.confraternity_id:
            flash('Nessuna confraternita associata.', 'error')
            return redirect(url_for('admin.dashboard'))
        form.confraternity_id.choices = [(current_user.confraternity_id, current_user.confraternity.name)]

    if form.validate_on_submit():
        target_conf_id = form.confraternity_id.data
        if not current_user.can_manage_confraternity(target_conf_id):
            abort(403)

        procession = Procession(
            id=str(uuid.uuid4()),
            confraternity_id=target_conf_id,
            day=form.day.data,
            exit_time=form.exit_time.data,
            expected_return_time=form.expected_return_time.data,
            route_description=form.route_description.data or None,
            is_live=form.is_live.data,
        )
        db.session.add(procession)
        db.session.commit()
        flash('Processione programmata con successo.', 'success')
        return redirect(url_for('admin.processions_list'))

    return render_template('admin/procession_form.html', form=form, is_edit=False)


@admin_bp.route('/processions/<procession_id>/edit', methods=['GET', 'POST'])
@login_required
def procession_edit(procession_id: str):
    """Edit procession details and schedule."""
    procession = Procession.query.get_or_404(procession_id)
    if not current_user.can_manage_confraternity(procession.confraternity_id):
        abort(403)

    form = ProcessionForm(obj=procession)

    if current_user.is_superadmin:
        confraternities = Confraternity.query.order_by(Confraternity.name).all()
        form.confraternity_id.choices = [(c.id, f'{c.name} ({c.municipality})') for c in confraternities]
    else:
        form.confraternity_id.choices = [(current_user.confraternity_id, current_user.confraternity.name)]

    if form.validate_on_submit():
        procession.day = form.day.data
        procession.exit_time = form.exit_time.data
        procession.expected_return_time = form.expected_return_time.data
        procession.route_description = form.route_description.data or None
        procession.is_live = form.is_live.data

        db.session.commit()
        flash('Processione aggiornata.', 'success')
        return redirect(url_for('admin.processions_list'))

    return render_template('admin/procession_form.html', form=form, is_edit=True, procession=procession)


@admin_bp.route('/processions/<procession_id>/toggle-live', methods=['POST'])
@login_required
def procession_toggle_live(procession_id: str):
    """Instantly toggle live tracking status of a procession."""
    procession = Procession.query.get_or_404(procession_id)
    if not current_user.can_manage_confraternity(procession.confraternity_id):
        abort(403)

    procession.is_live = not procession.is_live
    db.session.commit()
    status_label = 'ATTIVATO (Live in onda)' if procession.is_live else 'DISATTIVATO (Rientrata)'
    flash(f'Stato della processione {procession.confraternity.name}: {status_label}', 'info')
    return redirect(request.referrer or url_for('admin.dashboard'))


@admin_bp.route('/processions/<procession_id>/delete', methods=['POST'])
@login_required
def procession_delete(procession_id: str):
    """Delete a procession."""
    procession = Procession.query.get_or_404(procession_id)
    if not current_user.can_manage_confraternity(procession.confraternity_id):
        abort(403)

    db.session.delete(procession)
    db.session.commit()
    flash('Processione eliminata.', 'success')
    return redirect(url_for('admin.processions_list'))


# ---------------------------------------------------------------------------
# Tracking Logs & Monitoring
# ---------------------------------------------------------------------------

@admin_bp.route('/tracking')
@login_required
def tracking_list():
    """View tracking log stream."""
    if current_user.is_superadmin:
        logs = TrackingLog.query.order_by(TrackingLog.timestamp.desc()).limit(100).all()
    else:
        if current_user.confraternity_id:
            logs = TrackingLog.query.filter_by(
                confraternity_id=current_user.confraternity_id
            ).order_by(TrackingLog.timestamp.desc()).limit(100).all()
        else:
            logs = []

    return render_template('admin/tracking_list.html', logs=logs)


# ---------------------------------------------------------------------------
# Backup (SuperAdmin only)
# ---------------------------------------------------------------------------

@admin_bp.route('/backup')
@login_required
@superadmin_required
def backup():
    """Download a live snapshot of the SQLite database."""
    db_path = current_app.config.get('SQLALCHEMY_DATABASE_URI', '').replace('sqlite:///', '')
    if not db_path or not os.path.exists(db_path):
        flash('Database file not accessible.', 'error')
        return redirect(url_for('admin.dashboard'))

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_filename = f'passio_sorrento_backup_{timestamp}.db'
    backup_path = os.path.join(current_app.instance_path, backup_filename)

    try:
        src = sqlite3.connect(db_path)
        dst = sqlite3.connect(backup_path)
        with dst:
            src.backup(dst)
        src.close()
        dst.close()

        return send_file(
            backup_path,
            as_attachment=True,
            download_name=backup_filename,
            mimetype='application/x-sqlite3'
        )
    except Exception as e:
        flash(f'Backup fallito: {e}', 'error')
        return redirect(url_for('admin.dashboard'))
