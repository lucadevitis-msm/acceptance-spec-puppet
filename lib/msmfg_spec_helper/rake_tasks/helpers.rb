require 'rake/file_list'

module MSMFGSpecHelper
  module RakeTasks
    module Helpers
      # Returns the module path
      #
      # @param  [Rake::TaskArguments] args  The task arguments
      # @return [String]                    The module path
      def module_path(args)
        args[:module_path] || '.'
      end

      # Returns a list of module's files, matching a pattern
      #
      # @param  [Rake::TaskArguments] args      The task arguments
      # @param  [String]              pattern   A Ruby globbing expression
      # @param  [Array<String>]       *exclude  Globbing patterns to exclude
      # @return [Rake::FileList]                A list of absolute paths
      def file_list(args, pattern, *exclude)
        path = module_path(args)
        unwanted = exclude.map { |f| "#{path}/#{f}" }
        Rake::FileList["#{path}/#{pattern}"].tap do |list|
          list.exclude(*unwanted).reject { |f| File.directory? f }
        end
      end

      # Returns the list of module's ruby files
      # @param  [Rake::TaskArguments] args  The task arguments
      #
      # @return [Rake::FileList]            A list of absolute paths
      def ruby_files(args)
        pattern = '**/{*.rb,{Gem,Rake}file,{,*}.gemspec,*.rake}'
        exclude = ['bundle/**/*',         # bundler
                   'vendor/**/*',         # bundler
                   'pkg/**/*',            # gem build process
                   'spec/fixtures/**/*']  # puppetlabs fixtures
        file_list(args, pattern, *exclude)
      end

      # Returns the list of module's puppet manifests
      # @param  [Rake::TaskArguments] args  The task arguments
      #
      # @return [Rake::FileList]            A list of absolute paths
      def manifests(args)
        file_list(args, '{manifests,puppet/}/**/*.pp')
      end

      # Returns the list of module's templates
      # @param  [Rake::TaskArguments] args  The task arguments
      #
      # @return [Rake::FileList]            A list of absolute paths
      def templates(args)
        file_list(args, '{templates,puppet/modules}/**/*.{erb,epp}')
      end

      # Returns the list of module's hieradata/config files
      # @param  [Rake::TaskArguments] args  The task arguments
      #
      # @return [Rake::FileList]            A list of absolute paths
      def hieradata(args)
        file_list(args, '{,puppet/}{,hiera}data/**/*.{yaml,eyaml}')
      end

      # Returns the list of repo's fragments files
      # @param  [Rake::TaskArguments] args  The task arguments
      #
      # @return [Rake::FileList]            A list of absolute paths
      def fragments(args)
        file_list(args, 'config/**/*.yml')
      end
    end
  end
end
