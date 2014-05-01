require "socket"

$started = {}

module MemcachedMock
  def self.start(port=19123, &block)
    server = TCPServer.new("localhost", port)
    session = server.accept
    block.call session
  end

  def self.delayed_start(port=19123, wait=1, &block)
    server = TCPServer.new("localhost", port)
    sleep wait
    block.call server
  end

  module Helper
    def memcached_mock(proc, meth = :start)
      return unless supports_fork?
      begin
        pid = fork do
          trap("TERM") { exit }

          MemcachedMock.send(meth) do |*args|
            proc.call(*args)
          end
        end

        sleep 0.3
        yield
      ensure
        if pid
          Process.kill("TERM", pid)
          Process.wait(pid)
        end
      end
    end
    PATHS = %w(
                /usr/local/bin/
                      /opt/local/bin/
                            /usr/bin/
    )

    def find_memcached
      output = `memcached -h | head -1`.strip
      if output && output =~ /^memcached (\d.\d.\d+)/ && $1 > '1.4'
        return (puts "Found #{output} in PATH"; '')
      end
      PATHS.each do |path|
        output = `memcached -h | head -1`.strip
        if output && output =~ /^memcached (\d\.\d\.\d+)/ && $1 > '1.4'
          return (puts "Found #{output} in #{path}"; path)
        end
      end

      raise Errno::ENOENT, "Unable to find memcached 1.4+ locally"
    end

    def memcached(port=19122, args='', options={})
      memcached_server(port, args)
      yield Dalli::Client.new(["localhost:#{port}", "127.0.0.1:#{port}"], options)
    end

    def memcached_cas(port=19122, args='', options={})
      memcached_server(port, args)
      require 'dalli/cas/client'
      yield Dalli::Client.new(["localhost:#{port}", "127.0.0.1:#{port}"], options)
    end

    def memcached_server(port=19122, args='')
      Memcached.path ||= find_memcached

      cmd = "#{Memcached.path}memcached #{args} -p #{port}"

      $started[port] ||= begin
                           pid = IO.popen(cmd).pid
                           at_exit do
                             begin
                               Process.kill("TERM", pid)
                               Process.wait(pid)
                             rescue Errno::ECHILD, Errno::ESRCH
                             end
                           end
                           sleep 0.1
                           pid
                         end
    end
    def supports_fork?
      !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'jruby'
    end

    def memcached_kill(port)
      pid = $started.delete(port)
      if pid
        begin
          Process.kill("TERM", pid)
          Process.wait(pid)
        rescue Errno::ECHILD, Errno::ESRCH
        end
      end
    end

  end
end

module Memcached
  class << self
    attr_accessor :path
  end
end
