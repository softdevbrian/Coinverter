# Coinverter

A modern, offline-resilient currency converter Flutter application featuring live exchange rates, custom color palettes, and persistence.

## 🚀 Features

- **Smart Currency Persistence**: Remembers your chosen currency pair (defaults to USD → KES) across sessions.
- **Offline Resilience & Cache**: Caches exchange rates locally with timestamps; falls back to cached rates and offline defaults when disconnected.
- **Live Exchange Rates**: Real-time rate updates via ExchangeRate-API (160+ currencies supported).
- **Searchable Currency Picker**: Bottom-sheet selector with flags, live search filtering, and ⭐ favorite currencies.
- **Dynamic Theming & 8 Color Palettes**:
  - 💜 Royal Purple (Default)
  - 🌊 Ocean Blue
  - 🌿 Emerald Green
  - 🌅 Sunset Orange
  - 🌸 Rose Pink
  - 🌙 Midnight
  - 🍒 Cherry Red
  - ✨ Golden
- **Dark Mode Support**: System Default, Light, and Dark mode across all screens.
- **Animated Splash Screen**: Choreographed entry animation on startup.
- **Conversion History**: Track past conversions grouped by date, with tap-to-reuse and swipe-to-delete.
- **Interactive Result Card**: Tap-to-copy to clipboard, rate display, and long-press for full unabbreviated amount.
- **7-Day Trend Chart**: Sparkline rate chart directly under conversion results.

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter (Dart)
- **State Management**: `provider`
- **Local Storage**: `shared_preferences`
- **Networking**: `http`, `connectivity_plus`
- **Charts**: `fl_chart`
- **Typography & Formatting**: `intl`, `google_fonts`

## 📦 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/softdevbrian/Coinverter.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on your device:
   ```bash
   flutter run
   ```
