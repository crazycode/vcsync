module VCSYNC
  module ClassMethods
    def log(message)
      puts message
    end

    def verbose(message)
      if false
        puts message
      end
    end
  end

  module InstanceMethods

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
