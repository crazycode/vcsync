module VCSYNC

  class VersionDir
    @@subclasses = nil
    attr_accessor :group_id, :path, :vc_type, :remotes

    def self.subclasses
      return @@subclasses if @@subclasses
      @@subclasses = Array.new
      ObjectSpace.each_object(Class) { |klass| @@subclasses << klass if klass < self }
      @@subclasses
    end

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

    def eql?(other)
      return false if other.nil?
      other.is_a?(VersionDir) && @group_id.eql?(other.group_id) && @path.eql?(other.path) && @vc_type == other.vc_type
    end

    def hash
      @group_id.hash * 17 + @path.hash * 7 + @vc_type.hash
    end

  end

end
