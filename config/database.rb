Sequel::Database.extension(:pagination)

# Automated created at / updated at timestamps
Sequel::Model.plugin :timestamps

Sequel::Model.raise_on_save_failure = true # Do not throw exceptions on failure

Sequel.extension :named_timezones
Sequel.extension :pg_trgm

timezone_db          = Observatory::Config::Timezone::DATABASE
timezone_application = Observatory::Config::Timezone::APPLICATION
timezone_typecast    = Observatory::Config::Timezone::TYPECAST

tz_db, tz_app, tz_cast = [timezone_db, timezone_application, timezone_typecast].map do |tz|
  if ['local', 'utc'].include? tz
    # Named values only work when Sequel does the conversion - which is not the
    # case for e.g. the mysql2 adapter.
    # This way you can atleast chose between UTC and local time for those two -
    # otherwise it would fall back to UTC if given a named timezone.
    tz.to_sym
  else
    # Catching TZInfo::InvalidTimezoneIdentifier / Logging & Reraising leads to
    # the exception being hidden behind a "No DB assigned to Sequel::Model", so
    # we'll just let it bubble up.
    TZInfo::Timezone.get(tz)
  end
end

logger.info "Database timezone: #{ tz_db }"
logger.info "Application timezone: #{ tz_app }"
logger.info "Typecast timezone: #{ tz_cast }"

Sequel.database_timezone    = tz_db
Sequel.application_timezone = tz_app
Sequel.typecast_timezone    = tz_cast

opts            = { loggers: [logger] }
opts[:adapter]  = Observatory::Config::Database::ADAPTER
opts[:host]     = Observatory::Config::Database::HOST     if Observatory::Config::Database::HOST
opts[:port]     = Observatory::Config::Database::PORT     if Observatory::Config::Database::PORT
opts[:database] = Observatory::Config::Database::DATABASE if Observatory::Config::Database::DATABASE
opts[:user]     = Observatory::Config::Database::USER     if Observatory::Config::Database::USER
opts[:password] = Observatory::Config::Database::PASS     if Observatory::Config::Database::PASS
opts[:test]     = true

Sequel::Model.db = Sequel.connect(opts)
