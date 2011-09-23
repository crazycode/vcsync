require 'yaml'
module VCSYNC

  class Configuration

    def self.load
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

    def self.groups
      config['vc_dir']
    end

    def self.find_group_path(group_id)
      if self.groups[group_id].nil?
        return nil
      end

      path = self.groups[group_id]
      path.gsub!(/~/, ENV['HOME'])
      path.gsub!(/\$HOME/, ENV['HOME'])
      unless path.end_with?('/')
        path += '/'
      end
      path
    end

    def self.save(config)
      # TODO
    end
  end

end
