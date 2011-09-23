require 'fileutils'
require 'vcsync/model'
module VCSYNC

  class GitDir < VersionDir
    @@git_remote_regex = /^([^\s]+)\s+([^\s]+)\s+\(fetch\)$/

    def initialize(group_id, dir)
      @vc_type = :git
      @group_id = group_id
      @path = get_relation_path(dir.to_s)
      check_version_dir
    end

    def update
      return unless check?

      Dir.chdir(real_path)
      # check if had some nocommit workings.
      had_changed = `git status`.chomp.split('\n').grep(/nothing/).empty?
      had_origin = false
      @remotes.each do |remote|
        if "origin".eql? remote[:name]
          had_origin = true
        end
        puts "fetching #{remote[:name]}(#{remote[:url]})..."
        system("git fetch #{remote[:name]}")
      end
      if !had_changed and had_origin
        "merge origin/master ..."
        system("git merge origin/master")
      end
    end

    def check?
      File.directory?("#{real_path}") && File.directory?("#{real_path}/.git")
    end

    # Had something to commit?
    def dirty?
      Dir.chdir(real_path)
      `git status`.chomp.split("\n").grep(/nothing/).empty?
    end


    def create
      FileUtils.mkdir_p(real_path)
      return if @remotes.empty?
      # find default url
      default_url = @remotes[0][:url]
      @remotes.each do |remote|
        if "origin".eql?(remote[:name])
          default_url = remote[:url]
        end
      end

      system("git clone #{default_url} #{real_path}")
      Dir.chdir(real_path)
      @remotes.each do |remote|
        unless "origin".eql?(remote[:name])
          system("git remote add #{remote[:name]} #{remote[:url]}")
          system("git fetch #{remote[:name]}")
        end
      end

    end

    def self.is_a?(dir)
      File.directory?("#{dir}/.git")
    end

    def cleanup
      Dir.chdir(real_path)
      puts "do cleanup #{real_path}"
    end

    private
    def check_version_dir
      Dir.chdir(real_path)

      @remotes = []
      `git remote -v`.chomp.split('\n').each do |line|
        if line =~ @@git_remote_regex
          remote = Hash.new
          remote[:name] = $1
          remote[:url] = $2
          @remotes << remote
        end
      end
    end
  end

end
