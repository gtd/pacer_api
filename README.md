# PACER API

Ruby interface to the [PACER Case Locator
API](https://pacer.uscourts.gov/help/pacer/pacer-case-locator-pcl-api-user-guide).

## Development notes

VCR redaction is used for login parameters. To supply working parameters to add
new VCR cassettes, set these via the `PACER_LOGIN` and `PACER_PASSWORD`
environment variables.
