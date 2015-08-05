worker_processes 2
working_directory '/usr/src/app'
listen 3000, backlog: 64
timeout 30
pid '/tmp/web_server.pid'
stderr_path '/usr/src/app/log/unicorn.log'
check_client_connection false