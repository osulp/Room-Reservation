app_root = "/path/to/deploy/root"
current = "#{app_root}/current"
shared = "#{app_root}/shared"
worker_processes 2

working_directory current

listen "#{shared}/sockets/unicorn.sock"

timeout 30

pid "#{shared}/pids/unicorn.pid"
old_pid = "#{shared}/pids/unicorn.pid.oldbin"

stderr_path "#{shared}/log/unicorn-err.log"
stdout_path "#{shared}/log/unicorn-out.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
    GC.copy_on_write_friendly = true

check_client_connection false
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{current}/Gemfile"
end
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end