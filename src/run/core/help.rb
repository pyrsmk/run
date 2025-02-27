require "ripper"

module Run
  module Core
    module Help
      # @return [String]
      def self.run(contents)
        tasks = extract_tasks(contents)
        help_verbatims = extract_help_verbatims(contents, tasks)
        tasks_column_length = compute_tasks_column_length(tasks)

        output = help_verbatims.reduce("") do |output, help_verbatim|
          name_verbatim = help_verbatim[:names].sort.join(", ")
          name_verbatim = " #{name_verbatim}".yellow +
                          " " * (tasks_column_length - name_verbatim.size - 1)

          if help_verbatim[:comments].size > 0
            help_verbatim[:comments].each_with_index do |comment, comment_line|
              split_comment = split_verbatim(
                comment,
                STDOUT.winsize[1] - tasks_column_length - 2
              )
              split_comment.map.with_index do |chunk, chunk_line|
                text = comment_line == 0 && chunk_line == 0 ?
                      name_verbatim :
                      " " * tasks_column_length
                text += chunk
                output += "#{Markdown::Engine.new(text).to_ansi}\n"
              end
            end
          else
            output += "#{Markdown::Engine.new(name_verbatim).to_ansi}\n"
          end

          output
        end

        puts output
      end

      private

      # @param contents [String]
      # @param tasks [Array<Hash>]
      # @return [Array<Hash>]
      def self.extract_help_verbatims(contents, tasks)
        lines = contents.lines.map(&:chomp)

        tasks.map do |task|
          lines_to_scan = (0..(task[:line] - 2 < 0 ? 0 : task[:line] - 2)).to_a.reverse
          {
            names: task[:names],
            comments: lines_to_scan.each_with_object([]) do |current_line, comments|
              match = /^\s*#\s*(?<comment>.*?)\s*$/.match(lines[current_line])
              break comments if !match
              comments << match[:comment]
            end.reverse
          }
        end
      end

      # @param contents [String]
      # @return [Array<Hash>]
      def self.extract_tasks(contents)
        Ripper.sexp(contents)[1].each_with_object([]) do |(id, sexp), tasks|
          next if id != :method_add_block || sexp.fetch(1, nil)&.fetch(1, nil) != "task"

          names = case sexp[2][1][0][0]
                  when :symbol_literal
                    [sexp[2][1][0][1][1][1].to_sym]
                  when :array
                    sexp[2][1][0][1].map{ |tokens| tokens[1][1][1].to_sym }.sort
                  else
                    raise "Unsupported task name type"
                  end

          line = case sexp[2][1][0][0]
                 when :symbol_literal
                   sexp[2][1][0][1][1][2][0]
                 when :array
                   sexp[2][1][0][1][0][1][1][2][0]
                 else
                   raise "Unsupported task name type"
                 end

          tasks << {
            names: names,
            line: line,
          }
        end.sort do |a, b|
          a[:names].first <=> b[:names].first
        end
      end

      # @param tasks [Array<Hash>]
      # @return [Integer]
      def self.compute_tasks_column_length(tasks)
        tasks
          .map do |item|
            item[:names].join(", ")
          end
          .reduce(0) do |max, name|
            next max if name.size <= max
            name.size
          end + 2
      end

      # @param verbatim [String]
      # @param available_length [Integer]
      # @return [Array<String>]
      def self.split_verbatim(verbatim, available_length)
        verbatim.split(/\s+/).each_with_object([]) do |word, lines|
          line = lines.pop || ""
          if (line + word).size > available_length
            lines << line
            line = word
          else
            line += line.size == 0 ? word : " #{word}"
          end
          lines << line
        end
      end
    end
  end
end
