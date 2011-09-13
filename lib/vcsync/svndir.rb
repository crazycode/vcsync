# -*- coding: utf-8 -*-
require 'vcsync/model'
module VCSYNC

  class SvnDir < VersionDir
    @@svn_url_regex = /^URL:\s+([^\s]+)$/

    def initialize(group_id, dir)
      @vc_type = :svn
      @group_id = group_id
      @path = get_relation_path(dir.to_s)
      check_version_dir
    end

    def update
      Dir.chdir(real_path)
      if @remotes.size == 0
        return
      end
      puts "    update #{@remotes[0][:url]}"
      system('svn update')
    end


    def check?
      File.directory?("#{real_path}") && File.directory?("#{real_path}/.svn")
    end


    def dirty?
      Dir.chdir(real_path)
      `svn status`.chomp.split("\n").size > 0
    end

    def create
      FileUtils.mkdir_p(real_path)
      return if @remotes.empty?

      # find default url
      default_url = @remotes[0][:url]

      system("svn checkout #{default_url} #{real_path}")
    end

    def cleanup
      Dir.chdir(real_path)
      puts "do cleanup #{real_path}"
      system('svn cleanup')
    end

    private
    def check_version_dir
      Dir.chdir(real_path)

      @remotes = []
      # TODO: 测试windows环境LANG=en svn info是否正常
      `svn info`.chomp.split('\n').each do |line|
        if line =~ @@svn_url_regex
          remote = Hash.new
          remote[:name] = "url"
          remote[:url] = $1
          @remotes << remote
        end
      end
    end
  end

end
