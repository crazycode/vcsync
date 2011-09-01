require 'vcsync/model'
module VCSYNC

  class SvnDir < VersionDir
    @@svn_url_regex = /^URL:\s+([^\s]+)$/

    def initialize(dir)
      @vc_type = :svn
      @path = dir.to_s
      check_version_dir
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
