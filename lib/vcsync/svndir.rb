require 'vcsync/model'
module VCSYNC

  class SvnDir < VersionDir
    @@svn_url_regex = /^URL:\s+([^\s]+)$/

    def initialize(dir)
      @vc_type = :svn
      @path = dir.to_s
      check_version_dir
    end

    def update
      Dir.chdir(@path)
      if remotes.size == 0
        return
      end
      puts "update #{remotes[0][:url]}"
      system('svn update')
    end

    def cleanup
      Dir.chdir(@path)
      puts "do cleanup #{@path}"
      system('svn cleanup')
    end

    private
    def check_version_dir
      Dir.chdir(@path)

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
