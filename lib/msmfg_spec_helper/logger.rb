module MSMFGSpecHelper
  # Prepares and returns a customized `::Logger` instance.
  module Logger
    class << self

      # Sets `progname` attribute. Must be used before instance is created
      #
      # @param [String] value
      #   string to use as `progname` in `::Logger` messages
      #
      # @returns [String]
      #   the value of `progname` attribute
      #
      # @example
      #   MSMFGSpecHelper::Logger.progname = 'MyProg'
      #
      # @api public
      def progname=(value)
        @progname = value
      end

      # Returns `progname` attribute
      #
      # If it is not set, sets the value to "msmfg_spec_helper".
      #
      # @returns [String]
      #   the value of `progname` attribute
      #
      # @api private
      def progname
        @progname ||= 'msmfg_spec_helper'
      end

      # Sets `level` attribute. Must be used before instance is created
      #
      # @param [Integer] value
      #   threshold `level` to use in `::Logger` messages
      #
      # @returns [Integer]
      #   the value of `level` attribute
      #
      # @example
      #   MSMFGSpecHelper::Logger.level = ::Logger::INFO
      #
      # @api private
      def level=(value)
        @level = value
      end

      # Returns `level` attribute
      #
      # If it is not set, tryes to set the value using environment variable
      # `LOG_THRESHOLD`. If no environment variable is set, use
      # `::Logger::WARN`.
      #
      # @returns [Integer]
      #   the value of `level` attribute
      #
      # @raise [NameError]
      #   if environment variable does not match any known log level
      #
      # @api private
      def level
        @level ||= Logger::Severity.get_const(ENV['LOG_THRESHOLD'] || 'WARN')
      end


      # Returns an already confured `::Logger` instance
      #
      # @returns [::Logger]
      #   The logger insance
      #
      # @example
      #   require 'msmfg_spec_helper/logger'
      #
      #   include MSMFGSpecHelper
      #
      #   logger.info 'a useful log line'
      def instance
        unless @instance
          @instance = ::Logger.new(log_file)
          @instance.level = level
          @instance.progname = progname
          @instance.freeze
        end
        @instance
      end
    end
  end

  # Returns the logger instance
  def logger
    MSMFGSpecHelper::Logger.instance
  end
end
