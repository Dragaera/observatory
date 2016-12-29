Sequel::Model.plugin(:schema)

# Automated created at / updated at timestamps
Sequel::Model.plugin :timestamps

Sequel::Model.raise_on_save_failure = true # Do not throw exceptions on failure

db_adapter  = ENV.fetch('DB_ADAPTER', 'sqlite')
db_host     = ENV['DB_HOST']
db_database = ENV.fetch('DB_DATABASE', "db/observatory_#{ Padrino.env }.db")
db_user     = ENV['DB_USER']
db_pass     = ENV['DB_PASS']

opts            = { loggers: [logger] }
opts[:adapter]  = db_adapter
opts[:host]     = db_host     if db_host
opts[:database] = db_database if db_database
opts[:user]     = db_user     if db_user
opts[:password] = db_pass     if db_pass
opts[:test]     = true

Sequel::Model.db =
  case Padrino.env
  when :development then
    Sequel.connect(opts)
  when :production  then
    Sequel.connect(opts)
  when :test        then
    Sequel.connect(opts)
  end
