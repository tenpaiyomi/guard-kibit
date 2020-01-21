# frozen_string_literal: true

require 'json'

module Guard
  class Kibit
    # This class runs `lein kibit` command, retrieves result and notifies.
    # An instance of this class is intended to invoke `lein kibit` only once in its lifetime.
    class Runner
      def initialize(options)
        @options = options
      end

      def run(paths = [])
        paths = Dir.glob(paths).uniq
        command = build_command(paths)

        Compat::UI.info "Inspecting #{paths.length} files"
        passed = system(*command)

        case @options[:notification]
        when :failed
          notify(passed, paths.length) unless passed
        when true
          notify(passed, paths.length)
        end

        passed
      end

      def build_command(paths)
        command = ['lein kibit']
        command.concat(paths)
        command.join(' ')
      end

      def notify(passed, path_count)
        image = passed ? :success : :failed
        text = "#{pluralize(path_count, 'file')} inspected,"
        text = "#{text} No" if passed
        text = "#{text} Errors Detected"
        priority = _priority(image)

        Compat::UI.info(text, title: 'Kibit results', image: image, priority: priority)
        Compat::UI.notify(text, title: 'Kibit results', image: image, priority: priority)
      rescue => e
        puts e.failed
        puts e.inspect
      end

      def pluralize(number, thing, options = {})
        text = ''

        text = if number == 0 && options[:no_for_zero]
                'no'
               else
                number.to_s
               end

        text = "#{text} #{thing}"
        text = "#{text}s" unless number == 1

        text
      end

      def _priority(image)
        { failed:   2,
          success: -2 }[image]
      end
    end
  end
end
