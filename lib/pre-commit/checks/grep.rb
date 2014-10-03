require 'pre-commit/checks/shell'

module PreCommit
  module Checks
    class Grep < Shell
      class PaternNotSet < StandardError
        def message
          "Please define 'pattern' method."
        end
      end

    # overwrite those:

      def files_filter(staged_files)
        staged_files
      end

      def extra_grep
        @extra_grep or []
      end

      def message
        @message or ""
      end

      def pattern
        @pattern or raise PaternNotSet.new
      end

    # general code:

      def call(staged_files)
        staged_files = files_filter(staged_files)
        return if staged_files.empty?

        result =
        in_groups(staged_files).map do |files|
          args = grep + [pattern] + files
          args += ["|", "grep"] + extra_grep if !extra_grep.nil? and !extra_grep.empty?
          execute(args, success_status: false)
        end.compact

        result.empty? ? nil : "#{message}#{result.join("\n")}"
      end

    private

      def grep(grep_version = nil)
        grep_version ||= detect_grep_version
        if grep_version =~ /FreeBSD/
          %w{grep -EnIH}
        else
          %w{grep -PnIH}
        end
      end

      def detect_grep_version
        `grep --version | head -n 1 | sed -e 's/^[^0-9.]*\([0-9.]*\)$/\1/'`
      end

    end
  end
end
