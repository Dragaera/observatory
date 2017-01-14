# Change log

This document represents a high-level overview of changes made to this project.
It will not list every miniscule change, but will allow you to view - at a
glance - what to expact from upgrading to a new version.

## [unpublished]

### Added

### Changed

### Fixed

- Ratelimit gem now respects redis connection settings.

### Security

### Deprecated

### Removed


## [0.4.0] - 2017-01-14

### Added

- Automated and on-demand background updates for player data.
- Rate-limiting for on-demand and background updates.

### Fixed

- Adagrad sum is now properly saved as a float rather than an integer.


## [0.3.2] - 2017-01-02

### Security

- Adds .dockerignore, preventing dev credentials from leaking into public
  containers.


## [0.3.1] - 2016-12-31

### Fixed

- Fixed docker container: Log to stdout, add missing DB adapters.


## [0.3.0] - 2016-12-31

### Added

- Persistent storage of Hive 2 user profiles and data.
- Basic paginated leaderboard.

### Fixed

- Properly format 0s-timespans.
- Updates HiveStalker gem to fix bug with resolving of Steam IDs.


## [0.2.1] - 2016-12-26

### Fixed

- Updates HiveStalker gem to fix bug with low account IDs.


## [0.2.0] - 2016-12-26

### Added

- Allows 'vanity'-URLs as input, in addition to various formats of Steam ID.


## [0.1.0] - 2016-12-25

### Added

- Basic interface to query data of one or multiple players from the Hive 2 HTTP
  API.
