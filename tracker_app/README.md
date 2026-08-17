# Passio Tracker — App Capofila & Priori (Android)

Applicazione interna Flutter per i Capofila e i Priori delle Confraternite della Penisola Sorrentina per la trasmissione della posizione GPS durante lo svolgimento delle Processioni della Settimana Santa.

## 📡 Funzionalità

* **Trasmissione GPS ad Alta Precisione**: Invio cadenzato della posizione della testa del corteo al server (`POST /api/tracking/log`) con autenticazione `X-Capofila-Secret`.
* **Coda Offline Resiliente**: Se la connessione internet si interrompe nei vicoli del centro storico, le coordinate vengono salvate in un buffer locale e sincronizzate non appena la rete torna disponibile.
* **Test di Connessione Rapido**: Verifica istantanea della raggiungibilità del server prima dell'uscita dalla chiesa.
* **Intervalli Configurabili**: Frequenza di campionamento selezionabile (10s, 30s, 60s).

## 🚀 Esecuzione & Test in Locale

```bash
flutter pub get
flutter test
flutter run
```
