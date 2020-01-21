# frozen_string_literal: true

require 'guard'
require 'guard/plugin'

module Guard
  # This class gets API calls from `guard` and runs `lein kibit` command via {Guard::Kibit::Runner}.
  # An instance of this class stays alive in a `guard` command session.
  class Kibit < Plugin
    autoload :Runner, 'guard/kibit/runner'

    attr_reader :options

    def initialize(options = {})
      super

      @options = {
        all_on_start: true,
        notification: :failed,
        default_paths: []
      }.merge(options)
    end

    def start
      run_all if @options[:all_on_start]
    end

    def run_all
      Compat::UI.info 'Inspecting Clojure code style of all files'
      inspect_with_kibit
    end

    def run_on_additions(paths)
      run_partially(paths)
    end

    def run_on_modifications(paths)
      run_partially(paths)
    end

    private

    def run_partially(paths)
      paths = clean_paths(paths)

      return if paths.empty?

      displayed_paths = paths.map { |path| smart_path(path) }
      Compat::UI.info "Inspecting Clojure code style: #{displayed_paths.join(' ')}"

      inspect_with_kibit(paths)
    end

    def inspect_with_kibit(paths = [])
      paths = @options[:default_paths] if paths.empty?
      Compat::UI.info "No paths specified to inspect, skipping Kibit" && return if paths.empty?

      runner = Runner.new(@options)
      passed = runner.run(paths)
      throw :task_has_failed unless passed
    rescue StandardError => e
      Compat::UI.error 'The following exception occurred while running guard-kibit: ' \
               "#{e.backtrace.first} #{e.message} (#{e.class.name})"
    end

    def clean_paths(paths)
      paths = paths.dup
      paths.map! { |path| File.expand_path(path) }
      paths.uniq!
      paths.reject! do |path|
        next true unless File.exist?(path)

        included_in_other_path?(path, paths)
      end
      paths
    end

    def included_in_other_path?(target_path, other_paths)
      dir_paths = other_paths.select { |path| File.directory?(path) }
      dir_paths.delete(target_path)
      dir_paths.any? do |dir_path|
        target_path.start_with?(dir_path)
      end
    end

    def smart_path(path)
      if path.start_with?(Dir.pwd)
        Pathname.new(path).relative_path_from(Pathname.getwd).to_s
      else
        path
      end
    end
  end
end
