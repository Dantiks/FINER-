# FINER

AI-powered personal finance and tax assistant for Kyrgyzstan (сом) and
Kazakhstan (₸). Track income/expenses in either currency, see your estimated
tax liability update live as you log income, and ask the built-in AI about
taxes and finances.

## Running locally

```bash
flutter pub get
flutter run --dart-define=ANTHROPIC_API_KEY=your_key_here
```

The AI chat works without the flag, but shows a message asking you to set
`ANTHROPIC_API_KEY` instead of a real reply. Optional: override the model
with `--dart-define=ANTHROPIC_MODEL=claude-...`.

## AI setup — read before shipping to real users

The Anthropic API key above is a compile-time constant baked into the app
binary (via `--dart-define`, never committed to source). That's fine for
local development and demos, but **it can be extracted from a compiled
APK/IPA by anyone** — do not submit a build like this to an app store or
give it to real users. Before a public release, replace
`lib/services/ai_service.dart`'s direct Anthropic call with a request to a
small backend proxy that holds the key server-side instead.

## Tax calculator

`lib/services/tax_calculator.dart` is the single source of truth for KG/KZ
tax rates. It's deliberately isolated and commented with sources/dates so
rates can be re-checked yearly — tax law changes (see the 2026 KZ Tax Code
reform) without warning, and got this MVP's numbers wrong once already
before they were corrected.

## Project structure

```
lib/
  models/       # Transaction, Goal, AppCountry
  providers/    # FinanceProvider, AiProvider, SettingsProvider (state)
  screens/      # UI screens
  services/     # tax_calculator, ai_service — pure logic, no widgets
  theme/        # FinerColors, FinerTheme
  widgets/      # Shared widgets (GlassCard, AmountText, TaxImpactCard, ...)
```
