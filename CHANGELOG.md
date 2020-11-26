# Change log

This document represents a high-level overview of changes made to this project.
It will not list every miniscule change, but will allow you to view - at a
glance - what to expect from upgrading to a new version.

## [unpublished]

### Added

### Changed

### Fixed

### Security

### Deprecated

### Removed


## [0.39.0] - 2020-04-30

### Added

- Historical compensation for score-multiplying bug. Based on the changes in
  playtime and score between data points, suspicious score increases which are
  likely the result of the known score-multiplying bug are detected, and
  compensated for.

### Changed

- Use redis-backed leaderboard for rank determination on profile pages.
  This removes redundant functionality, and ensures the leaderboard and
  profile page will match at all times.
- Update dependencies.


## [0.38.0] - 2019-09-20

### Changed

- Leaderboard now uses Redis as cache for significantly faster sorting.

### Fixed

- Ensure new cleanup job is ran rather than old one.

### Removed

- Player queries graph, as it refers to queries from before persistence was a
  thing, and is only relevant for newly added players now.
- Possibility to filter leaderboard by player activity. Rarely used, and would
  have complicated using Redis as a cache.


## [0.37.0] - 2019-09-01

### Added

- Background job to fix players in state where no future updates might happen.
- Use player's "last active at" timestamp as secondary order parameter in
  search results. Aliases which are equally similar to the search parameter
  will hence be sorted by the player's last activity.

### Changed

- Change to new skill tier badges. Thanks Rantology. :)

### Fixed

- Remove incorrect reference that searching for players' previous aliases is
  possible.


## [0.36.2] - 2019-08-28

### Fixed

- Fix issue in NSL account importer.


## [0.36.1] - 2019-08-28

### Fixed

- Fix typo in background job schedule preventing leaderboard updates.


## [0.36.0] - 2019-08-28

### Added

- Links to players' ensl.org profiles if known.

### Changed

- Show no-onos accuracy above yes-onos accuracy. Change wording.
- Update dependencies.

### Fixed

- Duplicate player updates due to race condition between player updates and
  update frequency classification (Github issue #36)
- Double updates when adding new players via web-interface.


## [0.35.0] - 2019-07-13

### Added

- Advertisement for ENSL.org-hosted tournaments / gathers.
- Link to wiki from FAQ.
- Opengraph tags to profile pages.

### Changed

- Update ruby to `2.6.3`, update dependencies.
- Link to tutorial landing page on wiki rather than ensl.org.


## [0.34.2] - 2019-04-06

### Changed

- Strip query parameters which are specified without a value.
- Update skill tier badges to newest versions from game files. Thanks
  @Adambean.

### Fixed

- Exception if search for a player's Steam ID and last activity matches a
  player for whom no data is no record yet.
- Exception if searching for a player, and the `last_active_after` query
  parameter is given as a toggle (ie without any value).
- Exception in classification of player update frequency, caused by race condition.


## [0.34.1] - 2019-03-20

### Added

- PAX2012 badge, which seems to be exported by Hive now.

### Fixed

- Exception if unknown badge encountered in Hive response.


## [0.34.0] - 2019-03-18

### Added

- Show 'no onos' accuracy on player profile page.
- Hint about ingame stats being refreshed weekly.

### Changed

- Update ruby to `2.6.1`.
- Update dependencies.


## [0.33.0] - 2019-03-17

### Added

- Support for cached player statistics and new output format of Gorge.


## [0.32.0] - 2019-03-12

### Added

- Caching of player ranks.
  Player ranks (for skill, score, experience etc) are now cached in Redis. A
  background job periodically recalculates them, and the profile page fetches
  them from Redis.

  This will cut load time of the profile by an order of magnitude, as rank
  calculation has been the most time-consuming aspect.


## [0.31.1] - 2019-03-06

### Added

### Changed

- Do not add new data points if API result is full of zeroes, in order not to
  pollute database with faulty data.


## [0.31.0] - 2019-03-06

### Added

- Ability to show a configurable MOTD at the top of each page.


## [0.30.2] - 2018-09-22

### Fixed

- Pagination links on player search and leaderboards don't reset 'last active
  after' filter anymore.
- Pagination page count on leaderboard now respects 'last active after' filter.


## [0.30.1] - 2018-09-16

### Fixed

- Exception on startup caused by partially loaded `ActiveSupport`, and gems not
  supporting this properly.


## [0.30.0] - 2018-09-16

### Added

- Ability to filter player search, and leaderboard, by players' last activity.

### Changed

- Update dependencies.


## [0.29.0] - 2018-08-12

### Added

- `sentry.io` integration for tracking of exceptions.


## [0.28.1] - 2018-07-04

### Fixed

- Assignment of players to skill tiers now uses adagrad sum for better accuracy.


## [0.28.0] - 2018-06-30

### Added

- Skill tier badges on profile page, leaderboard, and search result page.

### Changed

- Update base image to ruby `2.5.1`.
- Update dependencies.

### Fixed

- Made link to Piwik opt-out window on FAQ page absolute.


## [0.27.1] - 2018-04-13

### Fixed

- Exception on player profile page if a player has no rounds of a given team on
  record.


## [0.27.0] - 2018-04-13

### Added

- Basic per-player statistics (accuracy and KDR) on profile page.
- Hard-coded FAQ.


## [0.26.1] - 2018-03-19

### Fixed

- Prevent trying to load `dotenv` in production.


## [0.26.0] - 2018-03-19

### Added

- Show link to ENSL.org tutorials on profile pages of players matching certain
  criteria.

### Changed

- Update dependencies and base image.


## [0.25.1] - 2017-12-17

### Fixed

- Steam HTTP proxies not being used in round-robin fashion due to forking
  worker processes.


## [0.25.0] - 2017-12-17

### Added

- HTTP proxy support to Steam inventory API calls.


## [0.24.0] - 2017-12-09

### Added

- Optional Piwik integration.

### Fixed

- Exception when searching for a direct identifier (eg Steam ID) and badge at
  the same time. #2


## [0.23.1] - 2017-11-30

### Added

- Rate limiting of Steam queries.

### Fixed

- Exception when searching for non-ASCII alias.


## [0.23.0] - 2017-11-30

### Added

- Link to player's Steam community profile on profile page.
- Support for badges managed via Steam inventory:
  - NCT Early & Late 2017
  - WC 2014 Participant
  - ENSL S11
  - Mod Madness 2017

### Changed

- Ordering of badge groups to be more sensible thematically.

### Removed

- PAX 2012 badge, which can't be tracked due to being a game DLC.


## [0.22.0] - 2017-11-15

### Added

- Endpoint (`/player?steam_id=`) to query player profile by Steam ID.

### Changed

- Delegate various pretty-printing tasks to `silverball` instead of doing it
  ourselves.


## [0.21.0] - 2017-09-08

### Changed

- Schedule player updates based on when the last update was performed - not
  based on when it *should* have been performed. This ensures that updates
  spread out on their own.

### Fixed

- Properly set `last_used_at` when API key is used.

### Security

- Deactivated API keys can no longer be used for authentication.


## [0.20.0] - 2017-09-03

### Added

- API to retrieve player information as JSON.
  - (Static) token-based authentication
  - Returns basic player data (skill, playtime, ...)
  - Returns some internal data (profile URL, last update)


## [0.19.1] - 2017-08-21

### Fixed

- Fix `docker-entrypoint.sh` using wrong CLI argument to load puma
  configuration.


## [0.19.0] - 2017-08-21

### Added

- Healthcheck URL at `/health`

### Changed

- Replace Unicorn in favour of Puma
- Minify Chartkick JS.
- Use pie chart for 'player update frequency' graph.
- Update `sequel-pg-trgm` to latest git version.
  Removes deprecated Sequel behaviour.

### Removed

- 'Player data point relevance' graph, as we only store relevant data points.


## [0.18.0] - 2017-07-14

### Added

- Configure databasee port via DB_PORT.

### Changed

- Update dependencies.
- Use steam_id2 gem to resolve Steam IDs.
  Unifies resolving behaviour with Lerk Discord bot.


## [0.17.0] - 2017-04-19

### Added

- Configurable colours for aliens and marines in graphs.
- Configurable formatting directives for date and datetime.

### Changed

- Update Ruby base image, Tini, gems


## [0.16.1] - 2017-02-23

### Changed

- Update dependencies.

### Fixed

- 'Last active' on leaderboard showed time of last update instead of last time
  the player's data changed.


## [0.16.0] - 2017-02-22

### Added

- Views to manage update frequencies.
- User accounts with authentication, and management viewes.

### Removed

- Caching of fully-static pages. Performance gains are minor, and implementing
  cache-invalidation - as would be needed now that we have authentication - not
  worth it.


## [0.15.0] - 2017-02-17

### Added

- Redis-based page cache for static pages.
- Big performance improvements for player rank queries.
- Minor performance improvements for player profile, search and leaderboard.

### Changed

- Re-enabled dynamic rank on player profile.
- Non-relevant player points no longer get stored in the database.

### Removed

- Existing non-relevant player points from database.


## [0.14.1] - 2017-02-11

### Changed

- Disable dynamic player rank on profile page due to performance reasons.


## [0.14.0] - 2017-02-08

### Added

- Adding a new player is now mostly asynchronous - only initial resolving of
  the Steam ID happens synchronously.

- Exports which allow to export all stored data of a player as a CSV.

### Changed

- Improved placeholder page for players with no data.

### Fixed

- Bug in the logic which disables a player after too many updates failed
  made it disable the player one failed update later than configured.

- Bug in logic which re-enables a player after a succesful update which might
  have prevented it being re-enabled.


## [0.13.0] - 2017-02-02

### Added

- Link from per-stats rank on profile page to corresponding page in leaderboard.

### Changed

 - Update Ruby to 2.4.0.

### Fixed

- Fix searching for player by Steam ID.


## [0.12.2] - 2017-01-31

### Fixed

- Fix search breaking in anything but the default configuration.


## [0.12.1] - 2017-01-31

### Fixed

- Fix ordering in player search, at the cost of only searching current alias.


## [0.12.0] - 2017-01-30

### Added

- Resque::Plugin::JobStats to monitor job performance.
- Improve player search
  - Allow searching for Steam IDs and custom URLs
  - Show direct matches (e.g. Steam ID) first
  - Improve alias search by using Postgres Trigrams.

### Fixed

- Fix pagination of player search resetting badge parameter.

### Removed

- MySQL support. Player search implemention requires Postgres-specific
  features.


## [0.11.2] - 2017-01-28

### Security

- Enable CSRF protection. Configuration issue fixed.


## [0.11.1] - 2017-01-28

### Security

- Disable CSRF protection.

  There is an obscure issue where Google Chrome consistently fails CSRF
  protection, when nginx is put in front of the application server.

  Other browsers work fine, and so does Google Chrome if accessing the
  application server (be that Unicorn or Webrick) directly.

  While the bug is under investigation, CSRF protection has been disabled;
  there is no sensitive information stored within the application, and no
  destructive actions can be taken, so while not ideal, it is acceptable.

- Add session secret configuration via env variable.

  Must be same on all hosts in case of loadbalanced setups. Will be generated
  randomly if not defined. See the README for further details.

### Removed

- SQLite support. As we extensively use window functions to dyamically
  calculate player ranks, SQLite is not an option, as it does not support
  those.


## [0.11.0] - 2017-01-27

### Added

- Adds search functionality to search through players in database using account
  ID, ingame alias (both past and current), and badges. The 'add new player'
  query form on the main page was moved to a separate screen.
- Links entries on badge overview page to search result page.

### Changed

- Player - Badge join table will now cascade on update / delete. This allows to
  reasonably delete a player with badges.
- Updates dependencies.


## [0.10.1] - 2017-01-25

### Fixed

- Fixed ranking on profile page being incorrect while new players are being
  added.


## [0.10.0] - 2017-01-25

### Added

- Badge support:
  - Per-player badges
  - Global stats


## [0.9.0] - 2017-01-23

### Added

- 'Last active' field in leaderboard, showing when last tracked activity of
  player was.
- Stats page, with some graphs of statisics for the Observatory.

### Changed

- Made Steam Web API optional. If no key configured, the application will work
  as long as no name resolution is attempted.


## [0.8.1] - 2017-01-22

### Added

- Debug mode for hunting down the CSRF failures in Chrome.


## [0.8.0] - 2017-01-22

### Added

- Improved profile pages:
  - For score, skill, score / minute and experience, the player's rank is shown
    too.
  - Graphs to visualize development of playtime and skill over time.
  - Pagination for 'skill progression' table.

### Changed

- Made update scheduling more resistant to unexpected failures.
- Internal refactoring of logging output.

### Fixed

- Automatic test suite.


## [0.7.1] - 2017-01-20

### Changed

- Updates dependencies.

### Fixed

- Calculation of 'Score per Minute' if both score and total time are 0.


## [0.7.0] - 2017-01-19

### Added

- 'Score per minute' value to player profiles and leaderboard.

### Fixed

- Stay on current pagee if sort column of leaderboard changed.


## [0.6.2] - 2017-01-19

### Fixed

- Fixed creation of stale user objects if the Hive query failed.


## [0.6.1] - 2017-01-19

### Added

- Placeholder player profile for players with no data.

### Fixed

- Removed players without player data from leaderboard.

### Removed

- PLAYER_DATA_UPDATE_INTERVAL: With custom update frequencies this setting has
  no value anymore.


## [0.6.0] - 2017-01-18

### Added

- Per-player update frequency which determines at which rate background updates
  get scheduled. Frequency is determined by player activity.

- Delay automatically scheduled player updates to prevent them from
  trying to execute all at once.

### Changed

- Refactored Player and PlayerDataPoint models. All Hive data is now stored in
  the later, while the former only contains the player's resolved account ID.

  Also adds a `relevant` field to data points, which states whether the data
  changed since its predecessor.


## [0.5.3] - 2017-01-16

### Added

- Prevent user from scheduling multiple updates for the same player.

### Fixed

- Prevent background updates from scheduling multiple updates for the same
  player.


## [0.5.2] - 2017-01-16

### Fixed

- Fixed `PLAYER_DATA_BACKOFF_DELAY` setting.


## [0.5.1] - 2017-01-15

### Added

- Backoff time for player updates in case of rate limiting is now configurable.

### Fixed

- Updated dependencies to fix handling of account IDs starting with 765.


## [0.5.0] - 2017-01-15

### Added

- New pagination to leaderboard which scales better with number of pages.

### Changed

- Randomize delay duration in case of rate limiting of background updates.


## [0.4.1] - 2017-01-14

### Added

- Docker entrypoints for Resque worker and scheduler.

### Fixed

- Ratelimit gem now respects redis connection settings.


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

### Removed

- Multi-person queries due to rate-limiting concerns.


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
