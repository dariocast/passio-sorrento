"""WTForms for Passio Sorrento Admin Portal."""

from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed
from wtforms import (
    StringField, TextAreaField, SelectField, DateTimeField,
    BooleanField, PasswordField, FloatField, IntegerField
)
from wtforms.validators import DataRequired, Length, Optional, Email, NumberRange


class LoginForm(FlaskForm):
    """Admin login form."""
    username = StringField('Nome Utente', validators=[DataRequired(), Length(min=3, max=64)])
    password = PasswordField('Password', validators=[DataRequired()])


class UserForm(FlaskForm):
    """Form to create/edit Admin and Priore accounts (SuperAdmin only)."""
    username = StringField('Nome Utente', validators=[DataRequired(), Length(min=3, max=64)])
    email = StringField('Email', validators=[Optional(), Email(), Length(max=120)])
    password = PasswordField('Password (lascia vuoto per non modificare)', validators=[Optional(), Length(min=6)])
    role = SelectField('Ruolo', choices=[
        ('PRIORE', 'Priore / Amministratore Confraternita'),
        ('SUPERADMIN', 'SuperAdmin (Accesso Totale)')
    ], validators=[DataRequired()])
    confraternity_id = SelectField('Confraternita Assegnata', validators=[Optional()])
    is_active = BooleanField('Account Attivo', default=True)


class MunicipalityForm(FlaskForm):
    """Form to create/edit Municipalities (SuperAdmin only)."""
    name = StringField('Nome Comune', validators=[DataRequired(), Length(max=100)])
    latitude = FloatField('Latitudine GPS (es. 40.6263)', validators=[DataRequired(), NumberRange(min=-90, max=90)])
    longitude = FloatField('Longitudine GPS (es. 14.3758)', validators=[DataRequired(), NumberRange(min=-180, max=180)])
    display_order = IntegerField('Ordine di Visualizzazione', default=0, validators=[DataRequired()])
    is_active = BooleanField('Comune Attivo', default=True)


class ConfraternityForm(FlaskForm):
    """Create/Edit confraternity form."""
    name = StringField('Nome Arciconfraternita', validators=[DataRequired(), Length(max=255)])
    color = StringField('Colore Identificativo (Hex, es. #5C1A1B)', validators=[DataRequired(), Length(min=4, max=7)])
    municipality_id = SelectField('Comune di Appartenenza', validators=[Optional()])
    municipality = StringField('Nome Comune (Testo)', validators=[Optional(), Length(max=100)])
    coat_of_arms = StringField('URL o Percorso Stemma (Manuale)', validators=[Optional(), Length(max=500)])
    coat_of_arms_file = FileField('Carica Nuovo File Immagine / Logo', validators=[
        FileAllowed(['jpg', 'jpeg', 'png', 'webp', 'svg'], 'Formato non supportato. Carica un file JPG, PNG, WebP o SVG.')
    ])
    history = TextAreaField('Cenni Storici e Devozione', validators=[Optional()])
    capofila_secret = StringField('Codice Segreto Trasmettitore (Passio Tracker)', default='capofila123', validators=[DataRequired(), Length(min=4, max=64)])


class ProcessionForm(FlaskForm):
    """Create/Edit procession form."""
    confraternity_id = SelectField('Confraternita', validators=[DataRequired()])
    day = SelectField('Giorno del Rito', choices=[
        ('Giovedì Santo', 'Giovedì Santo (Notte)'),
        ('Venerdì Santo', 'Venerdì Santo (Sera)'),
        ('Sabato Santo', 'Sabato Santo'),
        ('Altro', 'Altro Giorno')
    ], validators=[DataRequired()])
    exit_time = DateTimeField(
        'Orario di Uscita', format='%Y-%m-%dT%H:%M', validators=[DataRequired()]
    )
    expected_return_time = DateTimeField(
        'Orario Stimato di Rientro', format='%Y-%m-%dT%H:%M', validators=[Optional()]
    )
    route_description = TextAreaField('Descrizione Itinerario e Tappe Sepolcri', validators=[Optional()])
    is_live = BooleanField('Trasmissione LIVE Attiva')
