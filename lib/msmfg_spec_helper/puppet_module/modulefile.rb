module MSMFGSpecHelper
  module PuppetModule
    # Modulefile DSL parser
    module Modulefile
      class << self
        include MSMFGSpecHelper::LoggerMixIn
        # `Modulefile` metadata and respective defaults
        METADATA = {
          name: nil,
          version: nil,
          summary: nil,
          description: nil,
          project_page: nil,
          license: nil,
          author: nil,
          source: nil,
          dependencies: []
        }.freeze

        # Easy access to the list of dependencies
        #
        # @return [Array]
        #   list of dependencies
        #
        # @example
        #   Modulefile.dependencies.each do |name, version, git|
        #     print "requires #{name} #{version}"
        #     print " from #{git}" if git
        #     puts
        #   end
        #
        # @api public
        attr_accessor :dependencies

        # Automatically generates DSL methods for the `Modulefile`
        METADATA.keys.reject { |m| m == :dependencies }.each do |name|
          define_method(name) do |value = nil|
            if value
              logger.debug("Modulefile: #{name}: #{value}")
              instance_variable_set("@#{name}", value)
            end
            instance_variable_get("@#{name}")
          end
        end

        # DSL method for `dependency` must be handled separatly
        #
        # @param [Array<String>] args
        #   dependency attributes
        #
        # @return [Array]
        #   added dependency
        #
        # @api private
        def dependency(*args)
          logger.debug("Modulefile: dependency: #{args.join(', ')}")
          @dependencies << args
          args
        end

        # Read Modulefile
        #
        # @param [String] modulefile
        #   path to the Modulefile
        #
        # @return nil
        #
        # @api private
        def read(modulefile = 'Modulefile')
          METADATA.each { |k, v| instance_variable_set("@#{k}", v) }
          # This is unsecure, but:
          #
          # - This class should not be used outside of this context
          # - This class is not meant to deal malicious configurations
          # - Modulefile content should have already been reviewed by members
          #   of the staff
          logger.debug("Modulefile: reading #{modulefile}")
          instance_eval File.read(modulefile)
          logger.info("Modulefile: #{modulefile} loaded succefully")
        rescue Errno::ENOENT
          logger.info("Modulefile: #{modulefile} not found")
        end
      end
    end
  end
end
