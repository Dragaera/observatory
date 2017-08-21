threads_min = ENV.fetch('PUMA_THREADS_MIN', 0).to_i
threads_max = ENV.fetch('PUMA_THREADS_MAX', 16).to_i
workers     = ENV.fetch('PUMA_WORKERS', 2).to_i
listen_ip   = ENV.fetch('PUMA_LISTEN_IP', '0.0.0.0')
listen_port = ENV.fetch('PUMA_LISTEN_PORT', '8080').to_i

threads threads_min, threads_max
workers workers
bind "tcp://#{ listen_ip }:#{ listen_port }"
