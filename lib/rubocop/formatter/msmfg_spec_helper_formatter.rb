require 'msmfg_spec_helper/logger'

module RuboCop # :nodoc:
  module Formatter # :nodoc:
    # Format the offenses report
    class MSMFGSpecHelperFormatter < BaseFormatter
      include MSMFGSpecHelper::LoggerMixIn
      # Print RuboCop report for a single file, using `MSMFGSpecHelper::Logger`
      #
      # @api private
      def file_finished(file, offenses)
        report = {
          task: 'lint',
          file_path: Pathname.new(file).relative_path_from(Pathname.pwd).to_s
        }
        offenses.each do |offense|
          severity = case offense.severity.name
                     when :refactor, :convention, :warning then :warn
                     else offense.severity.name
                     end
          _, text = offense.message.split(': ', 2)
          logger.send severity, report.merge(file_line: offense.line,
                                             check_name: offense.cop_name,
                                             text: text)
        end
        logger.info(report) unless offenses.any?
      end
    end
  end
end
