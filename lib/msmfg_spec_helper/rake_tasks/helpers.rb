require 'rake/file_list'

# Collection of modules and classes to help writing MSMFG puppet modules.
module MSMFGSpecHelper
  # Collection of rake tasks.
  module RakeTasks
    # Collection of helper functions.
    module Helpers
      DATADIR = (ENV['GEM_DATADIR'] || Gem.datadir('msmfg_spec_helper')).freeze

      # Returns a list of module's files, matching a pattern
      #
      # @param  [String]              pattern   A Ruby globbing expression
      # @param  [Array<String>]       *unwanted Globbing patterns to exclude
      # @return [Rake::FileList]                A list of absolute paths
      def file_list(pattern, *unwanted)
        FileList[pattern].exclude(*unwanted).reject { |f| File.directory? f }
        # unwanted = exclude.map { |f| "#{path}/#{f}" }
        # Rake::FileList[pattern].tap do |list|
        #   list.exclude(*unwanted).reject { |f| File.directory? f }
        # end
      end

      # Returns the list of module's ruby files
      #
      # @return [Rake::FileList]            A list of absolute paths
      def ruby_files
        pattern = '**/{*.rb,{Gem,Rake}file,{,*}.gemspec,*.rake}'
        exclude = ['bundle/**/*',         # bundler
                   'vendor/**/*',         # bundler
                   'pkg/**/*',            # gem build process
                   'spec/fixtures/**/*']  # puppetlabs fixtures
        file_list(pattern, *exclude)
      end

      # Returns the list of module's puppet manifests
      #
      # @return [Rake::FileList]            A list of absolute paths
      def manifests
        file_list('{manifests,puppet}/**/*.pp')
      end

      # Returns the list of module's templates
      #
      # @return [Rake::FileList]            A list of absolute paths
      def templates
        file_list('{templates,puppet}/**/*.{erb,epp}')
      end

      # Returns the list of module's hieradata/config files
      #
      # @return [Rake::FileList]            A list of absolute paths
      def hieradata
        file_list('{,puppet/}{,hiera}data/**/*.{yaml,eyaml}')
      end

      # Returns the list of repo's fragments files
      #
      # @return [Rake::FileList]            A list of absolute paths
      def fragments
        file_list('config/**/*.yml')
      end
    end
  end
end
