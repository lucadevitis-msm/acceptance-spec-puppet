require 'rake/file_list'

module MSMFGSpecHelper
  # Collection of functions about files lists
  module FilesListsMixIn
    # The location of data files
    DATADIR = (ENV['GEM_DATADIR'] || Gem.datadir('msmfg_spec_helper')).freeze

    # Returns a list of files, matching a pattern
    #
    # @param [String] pattern
    #   A Ruby globbing expression
    # @param [Array<String>] unwanted
    #   Globbing patterns to exclude
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def file_list(pattern, *unwanted)
      FileList[pattern].exclude(*unwanted).reject { |f| File.directory? f }
    end

    # Returns the list of the repo's ruby files
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def ruby_files
      pattern = '**/{*.rb,{Gem,Rake}file,{,*}.gemspec,*.rake}'
      exclude = ['vendor/**/*',         # bundler
                 'pkg/**/*',            # gem build process
                 'spec/fixtures/**/*']  # puppetlabs fixtures
      file_list(pattern, *exclude)
    end

    # Returns the list of the repo's puppet manifests
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def manifests
      file_list('{manifests,puppet}/**/*.pp')
    end

    # Returns the list of the repo's templates
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def templates
      file_list('{templates,puppet}/**/*.{erb,epp}')
    end

    # Returns the list of the repo's hieradata/config files
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def hieradata
      file_list('{,puppet/}{,hiera}data/**/*.{yaml,eyaml}')
    end

    # Returns the list of the repo's fragments files
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def fragments
      file_list('config/**/*.yml')
    end
  end
end
