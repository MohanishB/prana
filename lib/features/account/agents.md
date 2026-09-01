# Account feature guidance

- Keep account data behind `AccountRepository`; presentation code must not call `ApiClient` directly.
- Use Cubit/BLoC for loading, update, and password-change state. Do not use `setState`.
- `GET /account/profile.php` is the source of truth for the Account header and edit-profile data.
- `POST /account/update_profile.php` must use `multipart/form-data`. Email and phone are read-only because the API does not accept updates for them.
- `POST /account/change_password.php` is authenticated and must keep password values out of logs and persistent storage.
- Keep validation in `core/validation` and user-facing strings in localization.
- Profile updates should refresh the visible Account header and synchronize basic session display fields without replacing the access token or expiry.
- Preserve existing Account actions and theme behavior when adding account functionality.

## Profile presentation and photo updates
- Account profile data is API-driven; do not reintroduce static user identity values.
- Email and phone remain read-only in edit profile because the API does not accept changes to them.
- Profile photo updates use `student_photo` in the existing multipart profile endpoint.
- Keep selected-photo state in `EditProfileCubit`; do not use `setState`.
- Profile photo uploads must be JPG/JPEG/PNG and no larger than 5 MB.
- Account and app-bar avatars must fall back to the standard person icon when `photo_url` is absent.
- Any successful profile refresh/update must synchronize session display fields, including `photo_url`, so shared UI updates without a new login.
- Account child screens use `PranaAppBar(showBack: true)` for consistent back navigation.

