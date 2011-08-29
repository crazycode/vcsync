require 'rubygems'
require 'thor'
require 'pathname'

class ThorRunner < Thor
  include VCSYNC
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

  desc "test", "test some code"
  def test
    require 'pp'
    pp Configuration.config
    pp Configuration.dbfile
    pp Configuration.vc_dirs
  end

  desc "sync", "sync all vc dir."
  def sync
    require 'pp'
    require 'yaml'
    runner = Runner.new

    alldirs = Array.new
    Configuration.vc_dirs.each do |id, dir_str|
      puts "id=#{id}, dir=#{dir_str}"
      dir = Pathname.new(dir_str)
      vdirs = runner.find_vc(dir)
      puts "================ #{dir} ================"
      alldirs += vdirs
    end

    File.open(Configuration.dbfile, 'w') do |f|
      YAML::dump(alldirs, f)
    end

  end
end

ThorRunner.start
