require 'rubygems'
require 'thor'

class ThorRunner < Thor
  desc "start", "start server"
  method_option :environment,:default => "development", :aliases => "-e",:desc => "which enviroment you want server run."
  method_option :daemon, :type => :boolean, :default => false, :aliases => "-d",:desc => "runing on daemon mode?"
  def start
    puts "start #{options.inspect}"
  end
  method_option :delay,  :default => 0, :aliases => "-w",:desc => "wait server finish it's job"
  desc "stop" ,"stop server"
  def stop
    puts "stop"
  end
  desc "restart" ,"restart server"
  def restart
    puts "restart"
  end
end

ThorRunner.start
