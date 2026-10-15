# Authenticating requests

To authenticate requests, include an **`Authorization`** header with the value **`"Bearer {TOKEN}"`**.

All authenticated endpoints are marked with a `requires authentication` badge in the documentation below.

Token didapat dari <code>POST /api/v1/auth/login</code> (pelapor/driver). Endpoint admin memakai cookie session dashboard.
