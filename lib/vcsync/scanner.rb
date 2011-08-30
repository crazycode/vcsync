require 'pathname'
module VCSYNC

  class Scanner


    def sync_to_yaml

      alldirs = Array.new
      Configuration.vc_dirs.each do |id, dir_str|
        puts "id=#{id}, dir=#{dir_str}"
        next if dir_str.nil?

        dir_str.gsub!(/~/, ENV['HOME'])
        dir_str.gsub!(/\$HOME/, ENV['HOME'])
        dir = Pathname.new(dir_str)
        vdirs = find_vc(dir)

        alldirs += vdirs
      end

      File.open(Configuration.dbfile, 'w') do |f|
        YAML::dump(alldirs, f)
      end

    end

    # Load Version Control Dirs from Database file (YAML)
    def load_from_yaml
      unless File.exists?(Configuration.dbfile)
        puts "Not Found #{Configuration.dbfile}, please run 'vcsync sync' first!"
        return []
      end
      File.open(Configuration.dbfile, 'r') do |f|
        YAML::load(f)
      end
    end

    def find_vc(dir)
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
      GitDir.new(dir)
    end

    def create_svn_version_dir(dir)
      v = VersionDir.new
      v.vc_type = :svn
      v.path = dir.to_s
      Dir.chdir(dir)
      # todo svn info
      v
    end

  end

end
