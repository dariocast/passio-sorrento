/// User-friendly error messages in Italian.
library;

import 'failures.dart';

/// Maps failures to user-friendly Italian error messages.
class ErrorMessages {
  ErrorMessages._();

  /// Returns a user-friendly message for the given failure.
  static String fromFailure(Failure failure) {
    return switch (failure) {
      ServerFailure() =>
        failure.message ?? 'Errore del server. Riprova più tardi.',
      NetworkFailure() =>
        'Nessuna connessione internet. Controlla la tua rete.',
      CacheFailure() => 'Errore nel recupero dei dati salvati.',
      UnknownFailure() => 'Si è verificato un errore imprevisto.',
      _ => 'Si è verificato un errore.',
    };
  }

  /// Returns a user-friendly message from an exception.
  static String fromException(Object exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('socket') || message.contains('network')) {
      return 'Impossibile connettersi al server. Verifica la tua connessione internet.';
    }
    if (message.contains('timeout')) {
      return 'La richiesta ha impiegato troppo tempo. Riprova.';
    }
    if (message.contains('format') || message.contains('parse')) {
      return 'Errore nel formato dei dati ricevuti.';
    }
    if (message.contains('404')) {
      return 'Risorsa non trovata.';
    }
    if (message.contains('401') || message.contains('403')) {
      return 'Accesso non autorizzato.';
    }
    if (message.contains('500')) {
      return 'Errore interno del server. Riprova più tardi.';
    }

    return 'Si è verificato un errore. Riprova.';
  }

  // Common UI strings
  static const String retry = 'Riprova';
  static const String loading = 'Caricamento...';
  static const String noData = 'Nessun dato disponibile';
  static const String noConnection = 'Nessuna connessione';
  static const String offlineMode = 'Modalità offline';
  static const String dataFromCache = 'Dati dalla cache locale';
}
