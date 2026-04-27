# frozen_string_literal: true

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
              terminal_width = (STDOUT.winsize[1] rescue 80)
              split_comment = split_verbatim(
                comment,
                terminal_width - tasks_column_length - 2
              )
              split_comment.map.with_index do |chunk, chunk_line|
                text = comment_line == 0 && chunk_line == 0 ?
                       name_verbatim :
                       " " * tasks_column_length
                text += Markdown::Engine.new(chunk).to_ansi
                output += "#{text}\n"
              end
            end
          else
            output += "#{name_verbatim}\n"
          end

          if help_verbatim[:params].any?
            indent = " " * tasks_column_length
            help_verbatim[:params].each do |p|
              output += "#{indent}  - #{format_param(p)}\n"
            end
          end

          output
        end

        output
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
            params: task[:params],
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
        Ripper.sexp(contents)[1].each_with_object([]) do |node, tasks|
          next if node[0] != :method_add_block
          sexp = node[1]
          next if sexp.fetch(1, nil)&.fetch(1, nil) != "task"

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
            params: extract_params(node[2]),
          }
        end.sort do |a, b|
          a[:names].first <=> b[:names].first
        end
      end

      # @param block_node [Array, nil]
      # @return [Array<Hash>]
      def self.extract_params(block_node)
        return [] if block_node.nil?
        block_var = block_node[1]
        return [] if block_var.nil?
        params = block_var[1]
        return [] if params.nil?

        result = []

        (params[1] || []).each do |p|
          result << { name: p[1], required: true, keyword: false, default: nil }
        end

        (params[2] || []).each do |p|
          result << { name: p[0][1], required: false, keyword: false, default: node_to_s(p[1]) }
        end

        (params[5] || []).each do |p|
          name = p[0][1].chomp(":")
          if p[1] == false
            result << { name: name, required: true, keyword: true, default: nil }
          else
            result << { name: name, required: false, keyword: true, default: node_to_s(p[1]) }
          end
        end

        result
      end

      # @param node [Array, nil]
      # @return [String]
      def self.node_to_s(node)
        return "nil" if node.nil?
        case node[0]
        when :string_literal
          node[1][1..-1].map { |p| p[0] == :@tstring_content ? p[1] : "..." }.join
        when :@int, :@float
          node[1]
        when :var_ref
          node[1][1]
        when :symbol_literal
          node[1][1][1]
        when :array
          "[]"
        when :hash
          "{}"
        else
          "..."
        end
      end

      # @param param [Hash]
      # @return [String]
      def self.format_param(param)
        name = param[:name]
        if param[:keyword]
          if param[:required]
            "<#{name}=<value>>"
          else
            "[#{name}=<value>] " + param[:default].bright_cyan
          end
        else
          if param[:required]
            "<#{name}>"
          else
            "[#{name}] " + param[:default].bright_cyan
          end
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
