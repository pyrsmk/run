# frozen_string_literal: true

module Run
  module Helper
    class BindHelper
      TERM_TIMEOUT = 3
      COLORS = %i[cyan magenta yellow green blue]

      def initialize(*names)
        @names = names
      end

      def run
        pgids = {}
        threads = []
        mutex = Mutex.new
        shutting_down = false

        shutdown = lambda do
          return if shutting_down
          shutting_down = true
          pgids.each_value { |pgid| Process.kill('TERM', -pgid) rescue nil }
          Thread.new do
            sleep TERM_TIMEOUT
            pgids.each_value { |pgid| Process.kill('KILL', -pgid) rescue nil }
          end
        end

        Signal.trap('INT')  { shutdown.call }
        Signal.trap('TERM') { shutdown.call }

        @names.each_with_index do |name, index|
          prefix = "[#{name}]".send(COLORS[index % COLORS.size])
          rd, wr = IO.pipe

          pid = fork do
            rd.close
            $stdout.reopen(wr)
            $stderr.reopen(wr)
            wr.close
            Process.setpgrp
            Signal.trap('TERM') { exit 0 }
            begin
              Run::Core.run(name)
              exit 0
            rescue SystemExit => e
              exit e.status
            rescue Exception
              exit 1
            end
          end

          wr.close
          pgids[name] = pid

          threads << Thread.new(rd, prefix) do |pipe, pre|
            pipe.each_line { |line| mutex.synchronize { STDOUT.write("#{pre} #{line}") } }
            pipe.close
          end
        end

        begin
          loop do
            Process.wait(-1)
            shutdown.call
          end
        rescue Errno::ECHILD
        end

        threads.each(&:join)
      end
    end
  end
end
