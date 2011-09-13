require 'pathname'
require 'set'

module VCSYNC

  class Scanner


    def sync_to_yaml(group = nil)
      alldirs = Set.new load_from_yaml

      Configuration.vc_dirs.each do |group_id, dir_str|
        next if !group.nil? && group.eql?(group_id)
        puts "group_id=#{group_id}, dir=#{dir_str}"
        next if dir_str.nil?

        dir_str.gsub!(/~/, ENV['HOME'])
        dir_str.gsub!(/\$HOME/, ENV['HOME'])
        dir = Pathname.new(dir_str)
        vdirs = find_vc(group_id, dir)

        alldirs += vdirs unless vdirs.nil?
      end

      sortdirs = alldirs.to_a.sort {|x, y| x.real_path <=> y.real_path}

      if block_given?
        sortdirs.each do |dir|
          yield dir
        end
      end

      File.open(Configuration.dbfile, 'w') do |f|
        YAML::dump(sortdirs, f)
      end
    end

    # Load Version Control Dirs from Database file (YAML)
    def load_from_yaml
      unless File.exists?(Configuration.dbfile)
        # puts "Not Found #{Configuration.dbfile}, please run 'vcsync sync' first!"
        return []
      end
      dirs = File.open(Configuration.dbfile, 'r') do |f|
        YAML::load(f)
      end
      if block_given?
        dirs.each do |dir|
          yield dir
        end
      end
      dirs
    end

    def list(action)
      if "dirs".eql?(action.downcase)
        alldirs = load_from_yaml do |dir|
          puts "#{dir.real_path}"
          dir.remotes.each do |r|
            puts "  #{r[:name]}: #{r[:url]}"
          end unless dir.remotes.empty?
          puts
        end

      elsif "groups".eql?(action.downcase)
        Configuration.groups.each {|group_id, dir|
          puts "#{group_id}: #{dir}"
        }
      end
    end

    def find_vc(group_id, dir)
      return unless dir.directory?

      vdirs = []
      if File.directory?("#{dir}/.git")
        vdirs << create_git_version_dir(group_id, dir)
      elsif File.directory?("#{dir}/.svn")
        vdirs << create_svn_version_dir(group_id, dir)
      else
        # check subdir
        dir.children.each do |subdir|
          if subdir.directory?
            subvdirs = find_vc(group_id, subdir)
            vdirs += subvdirs unless subvdirs.nil?
          end
        end
      end
      vdirs
    end


    def create_git_version_dir(group_id, dir)
      GitDir.new(group_id, dir)
    end

    def create_svn_version_dir(group_id, dir)
      SvnDir.new(group_id, dir)
    end

  end

end
