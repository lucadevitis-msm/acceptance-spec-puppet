require 'rake/file_list'

module MSMFGSpecHelper # :nodoc:
  # Collection of functions about files lists
  module FilesListsMixIn
    # The location of data files
    DATADIR = (ENV['DATADIR'] || Gem.datadir('msmfg_spec_helper')).freeze

    # Returns a list of files, matching a pattern
    #
    # @param [String] pattern
    #   A Ruby globbing expression
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def file_list(pattern)
      FileList[pattern].tap do |list|
        list.exclude 'vendor/**/*',       # bundler
                     'pkg/**/*',          # gem build process
                     'spec/fixtures/**/*' # puppetlabs fixtures
        list.reject! { |f| File.directory? f }
      end
    end

    # Returns the list of the repo's ruby files
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def ruby_files
      file_list '**/{*.{rb,rake,gemspec},{Gem,Rake}file,Puppetfile.*}'
    end

    # Returns the list of the repo's puppet manifests
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def manifests
      file_list '{manifests,puppet}/**/*.pp'
    end

    # Returns the list of the repo's templates
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def templates
      file_list '{templates,puppet}/**/*.{erb,epp}'
    end

    # Returns the list of the repo's fragments/hieradata/config files
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def yaml_files
      file_list('{,puppet/}{,hiera}data/**/*.{yaml,eyaml}') +
        file_list('config/**/*.yml')
    end

    # Returns the list of the repo's JSON files
    #
    # @return [Rake::FileList]
    #   A list of absolute paths
    #
    # @api private
    def json_files
      file_list '**/*.json'
    end
  end

  class << self
    include ::MSMFGSpecHelper::FilesListsMixIn
  end
end
