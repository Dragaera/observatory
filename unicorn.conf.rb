listen ENV.fetch('UNICORN_LISTEN', 8080)

# Discourage long-running requests ;)
# Reverse-proxying webserver should be set up to retry at least once.
timeout 10

worker_processes ENV.fetch('UNICORN_WORKERS', 2).to_i
