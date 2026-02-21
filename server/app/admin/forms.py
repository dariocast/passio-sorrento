"""WTForms for Admin CRUD operations."""

from flask_wtf import FlaskForm
from wtforms import (
    StringField, TextAreaField, SelectField, DateTimeField,
    BooleanField, PasswordField
)
from wtforms.validators import DataRequired, Length, Optional


class LoginForm(FlaskForm):
    """Admin login form."""
    username = StringField('Username', validators=[DataRequired(), Length(min=3, max=64)])
    password = PasswordField('Password', validators=[DataRequired()])


class ConfraternityForm(FlaskForm):
    """Create/Edit confraternity form."""
    name = StringField('Name', validators=[DataRequired(), Length(max=255)])
    color = StringField('Color', validators=[DataRequired(), Length(min=4, max=7)])
    municipality = StringField('Municipality', validators=[DataRequired(), Length(max=100)])
    coat_of_arms = StringField('Coat of Arms Path', validators=[Optional(), Length(max=500)])
    history = TextAreaField('History', validators=[Optional()])


class ProcessionForm(FlaskForm):
    """Create/Edit procession form."""
    confraternity_id = SelectField('Confraternity', validators=[DataRequired()])
    day = SelectField('Day', choices=[
        ('Giovedì Santo', 'Giovedì Santo'),
        ('Venerdì Santo', 'Venerdì Santo')
    ], validators=[DataRequired()])
    exit_time = DateTimeField(
        'Exit Time', format='%Y-%m-%dT%H:%M', validators=[DataRequired()]
    )
    expected_return_time = DateTimeField(
        'Expected Return Time', format='%Y-%m-%dT%H:%M', validators=[Optional()]
    )
    is_live = BooleanField('Is Live')
