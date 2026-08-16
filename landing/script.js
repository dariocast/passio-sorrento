/* ==========================================================================
   Passio Sorrento — Landing Page Logic & Internationalization
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    // -------------------------------------------------------------------------
    // 1. Multilingual Translations Dictionary (Italian & English)
    // -------------------------------------------------------------------------
    const translations = {
        it: {
            nav_features: "Funzionalità",
            nav_live_map: "Mappa Live",
            nav_confraternities: "Confraternite",
            nav_schedule: "Programma",
            nav_faq: "Domande Frequenti",
            nav_download: "Scarica l'App",
            hero_badge: "Live GPS Tracking • Penisola Sorrentina",
            hero_title: "Vivi la Settimana Santa nel cuore della Penisola Sorrentina.",
            hero_subtitle: "L'applicazione ufficiale per seguire in tempo reale il corteo degli Incappucciati. Scopri itinerari, orari, cori del Miserere e le secolari Arciconfraternite.",
            btn_available_on: "Disponibile su",
            stat_processions: "Processioni Solenni",
            stat_towns: "Comuni Monitorati",
            stat_live: "Tracciamento Live",
            mockup_marker_black: "Venerdì Santo (Nera)",
            mockup_marker_white: "Giovedì Santo (Bianca)",
            features_tag: "Tecnologia & Tradizione",
            features_title: "Tutto quello che serve per vivere i Riti Sacri",
            features_desc: "Un connubio perfetto tra la solennità delle tradizioni secolari e la precisione del tracciamento GPS in tempo reale.",
            feat_1_title: "Tracciamento GPS in Tempo Reale",
            feat_1_text: "Visualizza la posizione esatta del corteo con la scia storica del percorso. Non perderai mai il passaggio degli incappucciati.",
            feat_2_title: "Itinerari & Orari Ufficiali",
            feat_2_text: "Programma completo di tutte le processioni: orario di uscita dalla chiesa, tappe nei Sepolcri e orario stimato di rientro.",
            feat_3_title: "Meteo & Radar per i Cortei",
            feat_3_text: "Previsioni orarie e probabilità di pioggia comune per comune, per sapere in anticipo l'andamento meteo durante le uscite serali e notturne.",
            feat_4_title: "Storia & Confraternite",
            feat_4_text: "Schede storiche su ogni Arciconfraternita, il significato dei lampioni, dei misteri, dei canti del Miserere e degli abiti tradizionali.",
            feat_5_title: "Notifiche Istantanee",
            feat_5_text: "Ricevi avvisi quando un corteo esce dalla chiesa madre o quando ci sono aggiornamenti di percorso in tempo reale.",
            feat_6_title: "6 Comuni in una Sola App",
            feat_6_text: "Copertura completa dell'intera costiera: Sorrento, Sant'Agnello, Piano di Sorrento, Meta, Vico Equense e Massa Lubrense.",
            spotlight_tag: "Esperienza Live",
            spotlight_title: "Non domandarti più dov'è il corteo. Guardalo in diretta.",
            spotlight_desc: "Grazie all'app satellite utilizzata direttamente dai capofila, le posizioni GPS vengono aggiornate ogni 10 secondi e proiettate su una mappa dettagliata con stile notte ad alto contrasto.",
            spotlight_pt_1: "Scia luminosa che indica il senso di marcia",
            spotlight_pt_2: "Distanza in metri rispetto alla tua posizione attuale",
            spotlight_pt_3: "Differenziazione visiva per colore confraternita",
            radar_active: "GPS LIVE SIGNAL • PENISOLA SORRENTINA",
            confraternities_tag: "L'anima del territorio",
            confraternities_title: "Le Confraternite della Penisola",
            confraternities_desc: "Secoli di fede, anonimato e preghiera attraverso gli abiti storici e i canti sacri tramandati di padre in figlio.",
            habit_white: "Abito Bianco con mantellina nera e cappuccio",
            habit_black: "Abito Nero, mantellina nera e cappuccio nero",
            habit_white_red: "Abito Bianco e mozzetta rossa",
            habit_red: "Abito Rosso e cappuccio rosso scarlatto",
            proc_thursday_night: "Notte del Giovedì Santo (03:00)",
            proc_friday_night: "Sera del Venerdì Santo (20:30)",
            proc_friday_morning: "Venerdì Santo (20:00)",
            proc_friday_night_piano: "Venerdì Santo (20:00)",
            faq_tag: "Chiarezza & Supporto",
            faq_title: "Domande Frequenti",
            faq_q1: "L'applicazione è gratuita?",
            faq_a1: "Sì, Passio Sorrento è totalmente gratuita per tutti i cittadini, fedeli e turisti. Non contiene pubblicità invasive.",
            faq_q2: "Come funziona il tracciamento GPS in tempo reale?",
            faq_a2: "I capofila delle Confraternite utilizzano l'app di trasmissione 'Passio Tracker' durante il corteo. I dati di geolocalizzazione vengono trasmessi in tempo reale e proiettati istantaneamente sulla mappa dell'app mobile.",
            faq_q3: "L'app funziona anche offline o senza connessione veloce?",
            faq_a3: "Sì! Tutti gli orari, le schede storiche e gli itinerari ufficiali vengono memorizzati nella memoria del telefono e sono consultabili anche in assenza di segnale.",
            faq_q4: "L'app è disponibile in lingua inglese per i turisti stranieri?",
            faq_a4: "Certamente. L'app rileva automaticamente la lingua dello smartphone (italiano o inglese) e adatta tutte le descrizioni, orari e mappe per accogliere al meglio i visitatori internazionali.",
            dl_title: "Scarica Passio Sorrento",
            dl_desc: "Porta la solennità e la bellezza della Settimana Santa sempre con te sul tuo smartphone.",
            footer_tagline: "Settimana Santa in Penisola Sorrentina",
            footer_desc: "Progetto digitale indipendente dedicato alla salvaguardia, valorizzazione e condivisione dei Riti Pasquali della Penisola Sorrentina.",
            footer_links_title: "Comuni",
            footer_app_title: "App"
        },
        en: {
            nav_features: "Features",
            nav_live_map: "Live Map",
            nav_confraternities: "Confraternities",
            nav_schedule: "Schedule",
            nav_faq: "FAQ",
            nav_download: "Download App",
            hero_badge: "Live GPS Tracking • Sorrento Peninsula",
            hero_title: "Experience Holy Week in the heart of Sorrento Peninsula.",
            hero_subtitle: "The official application to follow the hooded processions in real time. Discover routes, timetables, Miserere choirs, and centuries-old Archconfraternities.",
            btn_available_on: "Available on",
            stat_processions: "Solemn Processions",
            stat_towns: "Municipalities Covered",
            stat_live: "Live GPS Tracking",
            mockup_marker_black: "Good Friday (Black)",
            mockup_marker_white: "Holy Thursday (White)",
            features_tag: "Technology & Tradition",
            features_title: "Everything you need to experience Holy Week",
            features_desc: "A harmonious blend of centuries-old sacred rites and real-time live GPS precision.",
            feat_1_title: "Real-Time GPS Tracking",
            feat_1_text: "Follow the exact position of the procession with historical path trails. Never miss the solemn passing of the penitents.",
            feat_2_title: "Official Schedules & Routes",
            feat_2_text: "Complete schedules for every procession: departure times, church altar stations, and estimated return times.",
            feat_3_title: "Weather Radar & Forecast",
            feat_3_text: "Hourly forecasts and rain probability per town, keeping you informed before and during evening and nocturnal processions.",
            feat_4_title: "History & Brotherhoods",
            feat_4_text: "Historical profiles of each Archconfraternity, the meaning of the lamps, sacred symbols, Miserere chants, and traditional habits.",
            feat_5_title: "Instant Notifications",
            feat_5_text: "Receive real-time alerts when a procession begins its journey or whenever route updates occur.",
            feat_6_title: "6 Towns in One Single App",
            feat_6_text: "Complete peninsula-wide coverage: Sorrento, Sant'Agnello, Piano di Sorrento, Meta, Vico Equense, and Massa Lubrense.",
            spotlight_tag: "Live Experience",
            spotlight_title: "Never wonder where the procession is. Watch it live.",
            spotlight_desc: "Powered by the satellite tracker app operated directly by procession leaders, positions are refreshed every 10 seconds onto a high-contrast dark map.",
            spotlight_pt_1: "Glowing trail displaying procession direction",
            spotlight_pt_2: "Distance in meters from your current location",
            spotlight_pt_3: "Distinctive colors for each confraternity habit",
            radar_active: "GPS LIVE SIGNAL • SORRENTO PENINSULA",
            confraternities_tag: "Soul of the Coast",
            confraternities_title: "Peninsula Confraternities",
            confraternities_desc: "Centuries of devotion, anonymity, and prayer expressed through historical vestments and sacred chants.",
            habit_white: "White Habit with black cape and pointed hood",
            habit_black: "Full Black Habit with black cape and hood",
            habit_white_red: "White Habit with red mozzetta",
            habit_red: "Scarlet Red Habit and crimson hood",
            proc_thursday_night: "Holy Thursday Night (03:00 AM)",
            proc_friday_night: "Good Friday Night (08:30 PM)",
            proc_friday_morning: "Good Friday (08:00 PM)",
            proc_friday_night_piano: "Good Friday (08:00 PM)",
            faq_tag: "Support & Guidance",
            faq_title: "Frequently Asked Questions",
            faq_q1: "Is the application free to use?",
            faq_a1: "Yes, Passio Sorrento is completely free for all citizens, devotees, and tourists. No intrusive advertisements.",
            faq_q2: "How does real-time GPS tracking work?",
            faq_a2: "Procession leaders transmit position signals using the companion 'Passio Tracker' app. Coordinates are broadcast live directly onto the mobile map.",
            faq_q3: "Does the app work offline without internet?",
            faq_a3: "Yes! All schedules, historical guides, and official route itineraries are cached locally on your device for offline reading.",
            faq_q4: "Is the app translated into English for international visitors?",
            faq_a4: "Yes. Passio Sorrento supports both Italian and English, automatically selecting your device language.",
            dl_title: "Download Passio Sorrento",
            dl_desc: "Carry the solemnity and timeless beauty of Holy Week in your pocket.",
            footer_tagline: "Holy Week in the Sorrento Peninsula",
            footer_desc: "Independent digital initiative dedicated to preserving, promoting, and sharing the Holy Week traditions of Sorrento.",
            footer_links_title: "Towns",
            footer_app_title: "App"
        }
    };

    let currentLang = 'it';

    const langToggleBtn = document.getElementById('langToggle');
    const flagSpan = langToggleBtn.querySelector('.lang-flag');
    const codeSpan = langToggleBtn.querySelector('.lang-code');

    function updateLanguage(lang) {
        currentLang = lang;
        document.documentElement.lang = lang;
        flagSpan.textContent = lang === 'it' ? '🇮🇹' : '🇬🇧';
        codeSpan.textContent = lang === 'it' ? 'IT' : 'EN';

        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (translations[lang] && translations[lang][key]) {
                el.textContent = translations[lang][key];
            }
        });
    }

    if (langToggleBtn) {
        langToggleBtn.addEventListener('click', () => {
            const newLang = currentLang === 'it' ? 'en' : 'it';
            updateLanguage(newLang);
        });
    }

    // -------------------------------------------------------------------------
    // 2. Mobile Menu Toggle
    // -------------------------------------------------------------------------
    const mobileToggle = document.getElementById('mobileToggle');
    const navMenu = document.getElementById('navMenu');

    if (mobileToggle && navMenu) {
        mobileToggle.addEventListener('click', () => {
            navMenu.classList.toggle('open');
            mobileToggle.classList.toggle('active');
        });

        // Close on link click
        navMenu.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('open');
                mobileToggle.classList.remove('active');
            });
        });
    }

    // -------------------------------------------------------------------------
    // 3. FAQ Accordion
    // -------------------------------------------------------------------------
    const faqItems = document.querySelectorAll('.faq-item');
    faqItems.forEach(item => {
        const questionBtn = item.querySelector('.faq-question');
        questionBtn.addEventListener('click', () => {
            const isActive = item.classList.contains('active');
            faqItems.forEach(i => i.classList.remove('active'));
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });

    // -------------------------------------------------------------------------
    // 4. Header Shadow on Scroll
    // -------------------------------------------------------------------------
    const header = document.querySelector('.header');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 30) {
            header.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.7)';
        } else {
            header.style.boxShadow = 'none';
        }
    });
});
