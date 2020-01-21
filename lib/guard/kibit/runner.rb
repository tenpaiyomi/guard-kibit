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
        command = build_command(paths)
        passed = system(*command)

        case @options[:notification]
        when :failed
          notify(passed) unless passed
        when true
          notify(passed)
        end

        passed
      end

      def build_command(paths)
        command = ['lein kibit']
        command.concat(paths)
      end

      def notify(passed)
        image = passed ? :success : :failed
        Notifier.notify('Finished Kibit inspection', title: 'Kibit results', image: image)
      end
    end
  end
end
