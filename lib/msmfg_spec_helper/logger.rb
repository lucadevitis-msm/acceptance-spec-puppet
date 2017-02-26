require 'logger'
require 'singleton'
require 'syslog/logger'
require 'rainbow/ext/string'

module MSMFGSpecHelper # :nodoc:
  # Prepares and returns a customized {::Logger} like instance.
  #
  # @example
  #   MSMFGSpecHelper::Logger.progname = 'msmfg-puppet-module-validate'
  #   MSMFGSpecHelper::Logger.level = ::Logger::INFO
  #
  #   MSMFGSpecHelper.logger.info 'Something is going on...'
  class Logger
    include Singleton
    class << self
      # Define a logging method based on the severity level
      #
      # @param [Symbol] severity
      #   the severity level
      #
      # @return [void]
      #
      # @api private
      #
      # @!macro [attach] logging_method
      #   @!method $1(log)
      #     Shortcut method to quickly log a message with $1 severity
      #
      #     @param [Hash] log
      #       the log information
      #
      #     @return [true]
      #       the result the logging
      #
      #     @api private
      def logging_method(severity)
        define_method(severity) do |*args|
          loggers.each { |logger| logger.send(severity, *args) }
        end
      end
    end

    logging_method :debug
    logging_method :info
    logging_method :warn
    logging_method :error
    logging_method :fatal
    logging_method :unknown

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

    # Returns the list of {::Logger} compatible objects
    #
    # @return [Array]
    #   the lsit of loggers
    #
    # @api private
    def loggers
      @loggers ||= []
    end

    # Returns an already confured `::Logger` instance
    #
    # @return [::Logger]
    #   The logger insance
    #
    # @api private
    def initialize
      ::Syslog::Logger.syslog = ::Syslog.open(progname,
                                              ::Syslog::LOG_PID,
                                              ::Syslog::LOG_USER)
      syslog = ::Syslog::Logger.new
      syslog.level = level
      syslog.formatter = proc { |_, _, _, log| JSON.generate(log) }
      loggers << syslog.freeze

      logger = ::Logger.new(STDOUT)
      logger.progname = progname
      logger.level = level
      logger.formatter = proc do |severity, _datetime, _progname, log|
        parts = []
        parts << case severity
                 when 'DEBUG' then severity[0].color(:green).bright
                 when 'INFO' then severity[0].color(:blue).bright
                 when 'WARN' then severity[0].color(:orangered)
                 else severity[0].color(:red)
                 end
        parts << (log[:function] || log[:task]).to_s.color(:yellow)
        parts << (log[:file_path] || '.').to_s.color(:cyan)
        parts << log[:file_line]
        parts << log[:check_name].to_s.color(:magenta) if log[:check_name]
        parts << (log[:text] || 'OK')
        parts.compact.join(': ') + "\n"
      end
      loggers << logger.freeze
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
