require 'yaml'
module VCSYNC

  class Configuration

    def self.load
      puts ENV['HOME']
      @@config = YAML.load_file "#{ENV['HOME']}/.vcsync_config"
      raise "vc_database MUST be configure." if @@config['vc_database'].nil?
      raise "vc_dir MUST be configure." if @@config['vc_dir'].nil?
      @@config
    end

    def self.config
      @@config ||= load
    end

    def self.dbfile
      dbfile = config['vc_database']
      dbfile.gsub!(/~/, ENV['HOME'])
      dbfile.gsub!(/\$HOME/, ENV['HOME'])

      dbfile
    end

    def self.vc_dirs
      config['vc_dir']
    end

    def self.save(config)
      # TODO
    end
  end

end
