require 'vcsync/model'
module VCSYNC

  class GitDir < VersionDir
    @@git_remote_regex = /^([^\s]+)\s+([^\s]+)\s+\(fetch\)$/

    def initialize(dir)
      @vc_type = :git
      @path = dir.to_s
      check_version_dir
    end

    private
    def check_version_dir
      Dir.chdir(@path)

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
