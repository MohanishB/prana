# Certificate Agent Guide

- Certificate files must use the shared `FileDownloadService`; do not add feature-specific HTTP/file code.
- A locally persisted certificate is authoritative for reopen/offline behavior.
- Never redownload a file when the expected local file already exists.
- Never invent certificate metadata not present in the current backend response.
- Static UI chrome must use localization.
- No `setState`; asynchronous file state is owned by the shared file-download Cubit.

- Certificate generation belongs to the masterclass course-detail flow. This feature continues to own/open/download already-generated certificate files and must not duplicate the generation API call.
- `MyCertificatesScreen` (Account > My certificates) only lists certificates the server says are generated (`masterclasses/my_certificates.php`, newest first). It never calls the generation API. Each row reuses `DownloadableFileTile` with the same file id (`certificate_<courseId>`) as the single certificate screen, so a PDF downloaded from either place is reused.
