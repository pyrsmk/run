module Run
  class HelpVerbatim
    # @param task_name [String]
    def initialize(task_name)
      @task_name = task_name
      @verbatim = extract_help_verbatim
    end

    # @param max_size [Integer]
    # @return [String]
    def render(max_size:)
      output = ""
      line_no = 0
      line_str = ""
      @verbatim.split("\n").each do |help_line|
        help_line.split(/\s+/).each do |help_word|
          # The line would be too long with the new word, let's print the line.
          if $stdout.tty? && (line_str + help_word).size > $stdout.winsize[1] - 2
            output += Markdown::Engine.new(line_str).to_ansi
            line_str = ""
            line_no += 1
          end
          # Initialize the line contents.
          if line_str == ""
            if line_no == 0
              line_str = " #{@task_name}".yellow + (" " * (max_size - @task_name.size + 4))
            else
              line_str = (" " * (max_size + 5))
            end
          end
          # Add the new word.
          line_str += " " + help_word
        end
        # Print the current line if it's not empty.
        if line_str.size > 0
          output += Markdown::Engine.new(line_str).to_ansi
          line_str = ""
        end
        line_no += 1
      end
      output
    end

    private

    # @return [String]
    def extract_help_verbatim
      caller = caller_locations[4]
      lines = File.readlines(caller.absolute_path)
      help = (0..(caller.lineno - 2)).to_a.reverse.reduce([]) do |comments, lineno|
        match = /^\s*#\s*(?<comment>.*?)\s*$/.match(lines[lineno])
        break comments if match.nil?
        comments << match[:comment]
        comments
      end
      help.reverse.join("\n")
    end
  end
end
