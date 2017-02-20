require 'msmfg_spec_helper'
require 'syslog/logger'

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

      # Sets the program name to be used in log messages
      #
      # @return [String]
      #   the value of `@progname` attribute
      #
      # @api private
      attr_writer :progname

      # Returns the log level threshold
      #
      # If it is not set, tries to use the value from `LOG_LEVEL` environment
      # variable. If no environment variable is set, use `::Logger::WARN`.
      #
      # @return [Integer]
      #   the value of `@level` attribute
      #
      # @raise [NameError]
      #   if environment variable does not match any known log level
      #
      # @api private
      def level
        @level ||= ::Logger::Severity.const_get(ENV['LOG_LEVEL'] || 'WARN')
      end

      # Sets the log threshold level
      #
      # @return [Integer]
      #   the value of `@level` attribute
      #
      # @api private
      attr_writer :level

      # Returns an already confured `::Logger` instance
      #
      # @return [::Logger]
      #   The logger insance
      #
      # @api private
      def instance
        if @instance.nil?
          options = ::Syslog::LOG_PID
          options |= ::Syslog::LOG_PERROR if ENV['LOG_PERROR']
          facility = ::Syslog::LOG_USER
          ::Syslog::Logger.syslog = ::Syslog.open(progname, options, facility)
          @instance = ::Syslog::Logger.new
          @instance.level = level
          @instance.formatter = proc do |severity, datetime, _progname, msg|
            "#{%w(D I W E F U)[severity]}: #{datetime.utc}: #{msg}\n"
          end
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
