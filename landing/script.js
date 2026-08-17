/* ==========================================================================
   Passio Sorrento — Landing Page Logic & Internationalization
   ========================================================================== */

// Global switcher for Hero Smartphone Mockup
window.changeHeroScreen = function(src, btn) {
    const heroImg = document.getElementById('heroMockupImg');
    if (heroImg) {
        heroImg.style.opacity = '0.3';
        heroImg.style.transition = 'opacity 0.2s ease';
        setTimeout(() => {
            heroImg.src = src;
            heroImg.style.opacity = '1';
        }, 150);
    }
    document.querySelectorAll('.phone-tab-btn').forEach(b => b.classList.remove('active'));
    if (btn) {
        btn.classList.add('active');
    }
};

document.addEventListener('DOMContentLoaded', () => {
    // -------------------------------------------------------------------------
    // 1. Multilingual Translations Dictionary (Italian & English)
    // -------------------------------------------------------------------------
    const translations = {
        it: {
            nav_showcase: "L'Applicazione",
            nav_features: "Funzionalità",
            nav_towns: "Comuni",
            nav_privacy: "Privacy",
            nav_download: "Scarica l'App",
            hero_badge: "Live GPS Tracking • Penisola Sorrentina",
            hero_title: "Vivi la Settimana Santa nel cuore della Penisola Sorrentina.",
            hero_subtitle: "L'applicazione ufficiale per seguire in tempo reale il corteo degli Incappucciati. Scopri itinerari, orari, previsioni meteo e la secolare storia delle Confraternite.",
            btn_available_on: "Disponibile su",
            stat_processions: "Processioni Solenni",
            stat_towns: "Comuni Monitorati",
            stat_live: "Tracciamento Live",
            showcase_tag: "Uno sguardo all'App",
            showcase_title: "Progettata per fedeli, confratelli e visitatori",
            showcase_desc: "Interfaccia minimale ed elegante, pensata per una consultazione rapida e chiara anche durante i cortei notturni.",
            card1_title: "Elenco Confraternite",
            card1_desc: "Tutti i cortei organizzati per comune, con indicazione dello stato in tempo reale e orari.",
            card2_title: "Tracciamento GPS",
            card2_desc: "Posizione in tempo reale del corteo, velocità di marcia e percorso lungo le strade peninsulari.",
            card3_title: "Storia & Simboli",
            card3_desc: "Stemma nobiliare, cenni storici, colore del saio e tradizioni secolari di ciascun sodalizio.",
            card4_title: "Percorso & Tappe",
            card4_desc: "Itinerario completo via per via con orari di partenza e rientro previsti.",
            card5_title: "Meteo & Radar",
            card5_desc: "Previsioni costantemente aggiornate per ciascun comune peninsulare con focus pioggia.",
            features_tag: "Caratteristiche",
            features_title: "Tutto quello che serve per vivere i Riti Sacri",
            features_desc: "Un connubio perfetto tra la solennità delle tradizioni secolari e la precisione del tracciamento GPS in tempo reale.",
            feat1_title: "GPS ad Alta Precisione",
            feat1_desc: "Aggiornamento automatico costante della testa del corteo direttamente dai trasmettitori dei capofila.",
            feat2_title: "Guida alle Confraternite",
            feat2_desc: "Scopri l'origine dei canti del Miserere, il significato dei simboli e la storia dei sodalizi.",
            feat3_title: "Meteo Dedicato",
            feat3_desc: "Monitoraggio meteo orario e probabilità di pioggia per pianificare la partecipazione in sicurezza.",
            towns_tag: "Territorio",
            towns_title: "I Comuni della Penisola Sorrentina",
            towns_desc: "Tutti i riti e le processioni solenni monitorati nei sei comuni peninsulari.",
            cta_title: "Scarica Passio Sorrento",
            cta_desc: "L'applicazione è gratuita e disponibile per tutti i dispositivi Android e iOS."
        },
        en: {
            nav_showcase: "The App",
            nav_features: "Features",
            nav_towns: "Municipalities",
            nav_privacy: "Privacy",
            nav_download: "Download App",
            hero_badge: "Live GPS Tracking • Sorrento Peninsula",
            hero_title: "Experience Holy Week in the heart of Sorrento Peninsula.",
            hero_subtitle: "The official application to follow the hooded processions in real time. Discover routes, timetables, weather forecasts, and centuries-old Archconfraternities.",
            btn_available_on: "Available on",
            stat_processions: "Solemn Processions",
            stat_towns: "Towns Covered",
            stat_live: "Live GPS",
            showcase_tag: "App Preview",
            showcase_title: "Designed for visitors, pilgrims and locals",
            showcase_desc: "Clean and minimal interface, designed for swift and clear navigation even during night processions.",
            card1_title: "Confraternities List",
            card1_desc: "All processions organized by municipality, with real-time status indicators and schedules.",
            card2_title: "Live GPS Map",
            card2_desc: "Real-time position of the procession along the historic streets of the Sorrento Peninsula.",
            card3_title: "History & Emblems",
            card3_desc: "Coats of arms, historical devotion, robe colors, and ancient traditions of each brotherhood.",
            card4_title: "Routes & Stops",
            card4_desc: "Street-by-street itineraries with departure, altar visits, and estimated return times.",
            card5_title: "Weather & Radar",
            card5_desc: "Hourly weather forecasts and rain radar for each peninsula town.",
            features_tag: "Features",
            features_title: "Everything you need to experience Holy Week",
            features_desc: "A harmonious blend of centuries-old sacred rites and real-time live GPS precision.",
            feat1_title: "High-Precision GPS",
            feat1_desc: "Real-time updates of the procession front directly from brotherhood leaders.",
            feat2_title: "Confraternities Guide",
            feat2_desc: "Discover the polyphonic Miserere chants, the symbols of the Passion, and deep history.",
            feat3_title: "Dedicated Weather",
            feat3_desc: "Hourly forecasts and rain probability to plan your participation safely.",
            towns_tag: "Territory",
            towns_title: "Sorrento Peninsula Municipalities",
            towns_desc: "All solemn rites monitored across the six peninsula towns.",
            cta_title: "Download Passio Sorrento",
            cta_desc: "The app is free and available for all Android and iOS devices."
        }
    };

    // -------------------------------------------------------------------------
    // 2. Language Switcher Logic
    // -------------------------------------------------------------------------
    let currentLang = localStorage.getItem('passio_lang') || 'it';
    const langToggleBtn = document.getElementById('langToggle');

    function updateLanguage(lang) {
        currentLang = lang;
        localStorage.setItem('passio_lang', lang);

        if (langToggleBtn) {
            langToggleBtn.querySelector('.lang-flag').textContent = lang === 'it' ? '🇮🇹' : '🇬🇧';
            langToggleBtn.querySelector('.lang-code').textContent = lang.toUpperCase();
        }

        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (translations[lang] && translations[lang][key]) {
                el.textContent = translations[lang][key];
            }
        });
    }

    if (langToggleBtn) {
        langToggleBtn.addEventListener('click', () => {
            const nextLang = currentLang === 'it' ? 'en' : 'it';
            updateLanguage(nextLang);
        });
    }

    updateLanguage(currentLang);

    // -------------------------------------------------------------------------
    // 3. Header Scroll Effect
    // -------------------------------------------------------------------------
    const header = document.querySelector('.header');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 40) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });
});
