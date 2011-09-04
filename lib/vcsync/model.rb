module VCSYNC

  class VersionDir
    attr_accessor :group_id, :path, :vc_type, :remotes

    def get_relation_path(dir)
      group_path = Configuration.find_group_path(@group_id)
      unless dir.index(group_path) == 0
        raise "#{dir} Not Start with #{group_path}!"
      end
      dir.sub(group_path, "")
    end

    def real_path
      Configuration.find_group_path(@group_id) + @path
    end
  end

end
