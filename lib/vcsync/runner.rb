require 'pathname'
module VCSYNC

  class Runner

    def find_vc(dir)
      puts "dir=#{dir}, check #{File.directory?(dir)}"
      return unless dir.directory?

      vdirs = []
      if File.directory?("#{dir}/.git")
        vdirs << create_git_version_dir(dir)
      elsif File.directory?("#{dir}/.svn")
        vdirs << create_svn_version_dir(dir)
      else
        # check subdir
        dir.children.each do |subdir|
          if subdir.directory?
            subvdirs = find_vc(subdir)
            vdirs += subvdirs unless subvdirs.nil?
          end
        end
      end
      vdirs
    end


    def create_git_version_dir(dir)
      puts "found #{dir}"
      GitDir.new(dir)
    end

    def create_svn_version_dir(dir)
      v = VersionDir.new
      v.vc_type = :svn
      v.path = dir.to_s
      Dir.chdir(dir)
      # todo git remote -v
      v
    end

  end

end
