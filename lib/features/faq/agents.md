# FAQ Feature Guidance

- Keep FAQ networking in `data/`, state in `bloc/`, and UI in `presentation/`.
- Use `FaqCubit`; do not introduce `setState` for feature state.
- Fetch FAQ content only through `FaqRepository` and the centralized `ApiClient`.
- Render backend HTML safely as readable app text without exposing raw markup.
- Preserve PRANA theme tokens, responsive layout, light/dark mode, localization, retry, and pull-to-refresh behavior.
