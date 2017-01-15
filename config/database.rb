Sequel::Database.extension(:pagination)

Sequel::Model.plugin(:schema)

# Automated created at / updated at timestamps
Sequel::Model.plugin :timestamps

Sequel::Model.raise_on_save_failure = true # Do not throw exceptions on failure


opts            = { loggers: [logger] }
opts[:adapter]  = Observatory::Config::Database::ADAPTER
opts[:host]     = Observatory::Config::Database::HOST     if Observatory::Config::Database::HOST
opts[:database] = Observatory::Config::Database::DATABASE if Observatory::Config::Database::DATABASE
opts[:user]     = Observatory::Config::Database::USER     if Observatory::Config::Database::USER
opts[:password] = Observatory::Config::Database::PASS     if Observatory::Config::Database::PASS
opts[:test]     = true

Sequel::Model.db = Sequel.connect(opts)
