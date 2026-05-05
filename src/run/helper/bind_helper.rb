# frozen_string_literal: true

require 'fiddle'

module Run
  module Helper
    class BindHelper
      TERM_TIMEOUT = 3
      COLORS = %i[cyan magenta yellow green blue]

      def initialize(*names, stdin: nil)
        @names = names
        @stdin_name = stdin
      end

      def run
        pgids = {}
        threads = []
        mutex = Mutex.new
        shutting_down = false
        use_terminal = @stdin_name && $stdin.isatty

        # Prevent SIGTTOU when the parent writes to the terminal while in background.
        Signal.trap('TTOU', 'IGNORE') if use_terminal

        shutdown = lambda do
          return if shutting_down
          shutting_down = true
          tcsetpgrp(Process.getpgrp) if use_terminal
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
          is_stdin_task = name == @stdin_name
          rd, wr = IO.pipe unless is_stdin_task

          pid = fork do
            unless is_stdin_task
              rd.close
              $stdout.reopen(wr)
              $stderr.reopen(wr)
              $stdin.reopen('/dev/null')
              wr.close
            end
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

          unless is_stdin_task
            wr.close
          end
          # Set pgid from the parent too to avoid a race with tcsetpgrp below.
          Process.setpgid(pid, pid) rescue nil
          pgids[name] = pid

          if is_stdin_task
            tcsetpgrp(pid) if use_terminal
          else
            threads << Thread.new(rd, prefix) do |pipe, pre|
              pipe.each_line { |line| mutex.synchronize { STDOUT.write("#{pre} #{line}") } }
              pipe.close
            end
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

      private

      def tcsetpgrp(pgid)
        @_tcsetpgrp ||= begin
          libc = Fiddle.dlopen(nil)
          Fiddle::Function.new(libc['tcsetpgrp'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
        end
        @_tcsetpgrp.call(0, pgid)
      end
    end
  end
end
