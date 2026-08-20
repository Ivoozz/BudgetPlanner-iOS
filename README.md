# 💶 BudgetPlanner iOS - Native iPhone Cockpit voor budget.ivoozz.nl

[![Build iOS IPA (BudgetPlanner)](https://github.com/Ivoozz/BudgetPlanner-iOS/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/Ivoozz/BudgetPlanner-iOS/actions/workflows/build-ipa.yml)
[![SideStore Compatible](https://img.shields.io/badge/SideStore-Source%20Ready-10B981?style=flat&logo=apple)](https://raw.githubusercontent.com/Ivoozz/BudgetPlanner-iOS/main/apps.json)
[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%20SwiftUI-F05138?style=flat&logo=swift)](https://developer.apple.com/swift/)
[![iOS](https://img.shields.io/badge/iOS-17.0%2B-black?style=flat&logo=apple)](https://developer.apple.com/ios/)

**BudgetPlanner iOS** is een bloedsnelle, native **SwiftUI (iOS 17+)** applicatie met **Liquid Glass design** die rechtstreeks communiceert met jouw centrale homelab backend op **`https://budget.ivoozz.nl`**. 

Elke transactie, budgetwijziging of overboeking die je op je iPhone doet, wordt **realtime** gesynchroniseerd met je centrale database en webdashboard!

---

## 📲 Installeren via SideStore / AltStore (Draadloos op je iPhone)

BudgetPlanner heeft een officiële **SideStore Community Source**!

### 1. SideStore Source URL:
```text
https://raw.githubusercontent.com/Ivoozz/BudgetPlanner-iOS/main/apps.json
```

### 2. Direct 1-Tik Toevoegen in SideStore:
Tik op je iPhone op onderstaande link om de source direct in SideStore te openen:
👉 [**Open in SideStore**](sidestore://source?url=https://raw.githubusercontent.com/Ivoozz/BudgetPlanner-iOS/main/apps.json)

*(Of ga in SideStore naar **Sources** ➔ **+ (Voeg toe)** en plak de bovenstaande URL).*

---

## 🌟 Belangrijkste Features

1. **⚡ 2-Seconden Quick Entry:**
   - Voer binnen 2 seconden een uitgave of inkomst in bij de kassa.
   - Snelle categorisering, rekeningselectie, numeriek toetsenbord en haptische feedback.
2. **🔄 100% Realtime 2-Way Synchronisatie:**
   - Direct gekoppeld aan de REST API van `https://budget.ivoozz.nl`.
   - Mutaties op je iPhone zijn per direct zichtbaar op het webdashboard en vice versa.
3. **📊 Financiële Cockpit & Dagbudget:**
   - **Hero Maandoverzicht:** Inkomsten, vaste lasten, variabele uitgaven en spaarquote in één oogopslag.
   - **Dagbudget-meter:** Weet exact hoeveel je vandaag nog vrij kunt besteden tot het einde van de maand.
4. **🏦 Rekeningen & Saldo's:**
   - Live saldo per bank-, spaar- of beleggingsrekening.
   - Snelle interne overboekingen met 1 tik.
5. **🎯 Visuele Budgetten & Categorieën:**
   - Kleurindicatoren (groen ➔ oranje ➔ rood) om budgetoverschrijding tijdig te voorkomen.
6. **🐖 Spaardoelen & Vaste Lasten Kalender:**
   - Voortgangsringen voor spaardoelen met snelle *"Bijstorten"* modal.
   - Vaste lasten kalender voor de komende 30 dagen met 1-tap *"Boek nu"*.
7. **🔒 Biometrische Face ID Beveiliging:**
   - Beveilig je financiële gegevens met Face ID of Touch ID.
8. **🌐 Offline-First Resilience:**
   - Geen internet? Uitgaven worden lokaal gebufferd en automatisch gesynchroniseerd zodra je weer online bent.
9. **🎙️ Apple Siri Shortcuts & Action Button:**
   - Voeg razendsnel uitgaven toe via Siri of de iPhone Actieknop.

---

## 🛠️ Technische Architectuur

- **Framework:** SwiftUI (iOS 17.0+)
- **Design System:** Liquid Glass (Frosted Glassmorphism, Haptics, Dark UI)
- **Netwerk & Sync:** `URLSession` async/await met JWT Bearer authenticatie
- **Project Generator:** `XcodeGen` (`project.yml`)
- **CI/CD:** GitHub Actions bouwt bij elke push / tag automatisch een unsigned `.ipa` artifact voor SideStore.

---

## 💻 Handmatig Installeren via Sideloadly / AltServer

1. Download het `.ipa` bestand via [GitHub Releases](https://github.com/Ivoozz/BudgetPlanner-iOS/releases).
2. Koppel je iPhone aan je computer via USB of Wi-Fi.
3. Sleep `BudgetPlanner.ipa` in Sideloadly of AltServer en installeer de app direct op je toestel.

---

*Ontwikkeld met meedogenloze syntaxkwaliteit door Kapitein Syntax ⚓️*
