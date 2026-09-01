# Account feature plan

Implemented:
- API-backed profile loading in the Account tab.
- Edit-profile screen for supported editable fields.
- Country options sourced from the profile API response.
- Multipart profile update request.
- Read-only email and phone display.
- Change-password screen with client validation and API submission.
- Localized loading, success, validation, and API error states.
- Session display fields synchronized after a successful profile update.

Next:
- Add optional profile-photo selection/upload when image-picking is selected for the app dependency set.
- Replace remaining placeholder Account actions as their APIs/features are selected.

## Profile polish milestone
- [x] Add back navigation to edit profile and change-password screens.
- [x] Keep email and phone on separate lines in the Account summary.
- [x] Normalize account form fields through the shared app input theme.
- [x] Add gallery profile-photo selection and multipart upload.
- [x] Persist `photo_url` in `UserSession` and update the shared app-bar avatar.
- [x] Refresh session identity data after profile fetch/update.

