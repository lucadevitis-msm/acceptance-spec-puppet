require 'msmfg_spec_helper'
require 'logger'

module MSMFGSpecHelper # :nodoc:
  # Prepares and returns a customized `::Logger` instance.
  #
  # @example
  #   MSMFGSpecHelper::Logger.progname = 'msmfg-puppet-module-validate'
  #   MSMFGSpecHelper::Logger.level = ::Logger::INFO
  #
  #   MSMFGSpecHelper.logger.info 'Something is going on...'
  module Logger
    class << self
      # Returns the currently configured program name
      #
      # If it is not set, sets the value to "msmfg_spec_helper".
      #
      # @return [String]
      #   the value of `@progname` attribute
      #
      # @api private
      def progname
        @progname ||= 'msmfg_spec_helper'
      end

      attr_writer :progname

      # Returns the log level threshold
      #
      # If it is not set, tries to use the value from `LOG_THRESHOLD`
      # environment variable. If no environment variable is set, use
      # `::Logger::WARN`.
      #
      # @return [Integer]
      #   the value of `@level` attribute
      #
      # @raise [NameError]
      #   if environment variable does not match any known log level
      #
      # @api private
      def level
        @level ||= ::Logger::Severity.const_get(ENV['LOG_THRESHOLD'] || 'WARN')
      end

      attr_writer :level

      # Returns the log file object
      #
      # If not set, tries to use the value from `LOG_FILE` environment
      # variable. If no environment variable is set, use `STDOUT`.
      #
      # @return [File]
      #   the value of `@log_file` attribute
      #
      # @api private
      def log_file
        if @log_file.nil?
          @log_file = case ENV['LOG_FILE']
                      when 'STDOUT', nil then STDOUT
                      when 'STDERR' then STDERR
                      else
                        File.open(ENV['LOG_FILE'], File::WRONLY | File::APPEND)
                      end
        end
        @log_file
      end

      attr_writer :log_file

      # Returns an already confured `::Logger` instance
      #
      # @return [::Logger]
      #   The logger insance
      #
      # @api private
      def instance
        if @instance.nil?
          @instance = ::Logger.new(log_file)
          @instance.level = level
          @instance.progname = progname
          @instance.freeze
        end
        @instance
      end
    end
  end

  # Provides easy access to `::MSMFGSpecHelper::Logger.instance`
  module LoggerMixIn
    # Returns the logger instance
    #
    # @return [::Logger]
    #   the configured `Logger` instance
    #
    # @example
    #   require 'msmfg_spec_helper/logger'
    #
    #   include MSMFGSpecHelper
    #
    #   logger.info 'a useful log line'
    #
    # @api public
    def logger
      MSMFGSpecHelper::Logger.instance
    end
  end
end
