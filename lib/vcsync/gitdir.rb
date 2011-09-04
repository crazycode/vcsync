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
