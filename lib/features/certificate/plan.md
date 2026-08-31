# Certificate Plan

## Implemented
- Open certificate entry points from both masterclass list metadata and course-detail metadata.
- Course-detail certificate source: `course_detail.php -> data.certificate`.
- Download certificate PDF only when generated and a download URL exists.
- Reuse central file download/open service.
- Reopen the persisted local file without downloading again.
- Support offline opening after the file has been downloaded.

## Deferred
- Sharing/export flow.
- Certificate metadata not returned by the API (recipient, certificate number, formatted issue date).
