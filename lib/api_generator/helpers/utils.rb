module ApiGenerator
  module Helpers
    module Utils
      INDENTATION_REGEX = /^([ \t]*)(?=\S)/.freeze
      WRITE_MODE = 'w'.freeze

      def create_dir(dir)
        FileUtils.mkdir_p(dir) && log(dir)
      end

      def log(path)
        path.gsub!(root, '.') if path.match?(Regexp.new(root))
        shell.say_status('create', path, :green)
      end

      def shell
        Thor::Shell::Color.new
      end

      def copy_template(template, destination, data_binding)
        content = render(template, data_binding)
        destination.gsub!(/\.erb$/, '.rb')

        File.write(destination, content, mode: WRITE_MODE) && log(destination)
      end

      def render(path, data_binding)
        ERB.new(File.read(path)).result(data_binding)
      end

      def inject_after_str(file, str, insert)
        text = File.read(file)
        result = inject_after(text, str, insert)
        File.write(file, result, mode: WRITE_MODE)
      end

      def inject_after(text, str, insert)
        lines = text.each_line.to_a
        regex = Regexp.new(str)
        match_line_idx = lines.index { |line| line =~ regex }

        return unless match_line_idx

        line = lines[match_line_idx]
        indented_insert = insert.each_line.map { |insert_line| indent_as(line, insert_line) }
        lines.insert(match_line_idx + 1, *indented_insert)
        lines.map(&:chomp).join("\n")
      end

      def indent_as(source, target)
        indentation = INDENTATION_REGEX.match(source).captures.first.to_s
        indentation + target
      end
    end
  end
end
