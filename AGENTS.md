# General Project Guidelines

- **No Hardcoded Translations / Multi-Language Support**: Never hardcode user-facing strings or texts. Always use the project's localization system / translation keys to support multiple languages.
- **Theme Support (Dark & Light Theme)**: Always account for both Dark Mode and Light Mode. Do not hardcode static colors; use theme-aware colors and styles.
- **No Emoji Icons**: Do not use emojis as icons or UI symbols. Always use standard vector icons (SVGs, Material Icons, CupertinoIcons, or designated icon assets).
- **Full End-to-End Integration (Shella Ecosystem)**: When developing or updating features, ensure full end-to-end integration across the ecosystem (Marketer App, Backend APIs, and Dashboards). Coordinate all requirements and dependencies across the stack.
- **No Dummy / Mock Data (Real Database & APIs)**: Never rely on dummy or mock data. All data must come from real backend endpoints and the actual database.
