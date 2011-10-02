require 'pathname'
require 'set'
require 'date'

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
          next unless dir.valid?
          yield dir
        end
      end

      save_yaml_file(sortdirs)
    end

    # Load Version Control Dirs from Database file (YAML)
    def load_from_yaml
      dirs = load_yaml_file
      if block_given?
        dirs.each do |dir|
          yield dir
        end
      end
      dirs
    end

    def remove_from_yaml(pwd, dir_path)
      dirs = load_yaml_file
      puts "try to remove <#{dir_path}> from database."
      dirs.each do |dir|
        if dir_path.eql? dir.real_path
          unless dir.dirty?
            dir.deleted_at = DateTime.now
            FileUtils.rm_rf(dir.real_path)
          else
            puts "#{dir.real_path} had something to commit! please check it first!"
          end
          save_yaml_file(dirs)
          return
        end
      end
      puts "Do nothing."
    end

    def list(action)
      if "dirs".eql?(action.downcase)
        alldirs = load_from_yaml do |dir|
          puts "#{dir.real_path} #{"DELETED" unless dir.valid?}"
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

      VersionDir.subclasses.each do |klass|
        if klass.is_a?(dir)
          vdirs << klass.new(group_id, dir)
          break
        end
      end

      if vdirs.empty?
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

    protected

    def load_yaml_file
      unless File.exists?(Configuration.dbfile)
        # puts "Not Found #{Configuration.dbfile}, please run 'vcsync sync' first!"
        return []
      end
      File.open(Configuration.dbfile, 'r') do |f|
        YAML::load(f)
      end
    end

    def save_yaml_file(dirs)
      File.open(Configuration.dbfile, 'w') do |f|
        YAML::dump(dirs, f)
      end
    end

  end

end
