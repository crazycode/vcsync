require 'rubygems'
require 'thor'
require 'pathname'
require 'yaml'

$curr_dir = nil
# Trap for Ctrl-C
trap("INT") {
  $curr_dir.cleanup unless $curr_dir.nil?
  exit!
}

class VcSyncRunner < Thor
  include VCSYNC
  argument :group, :banner=>"group", :type => :array, :required => false

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
    scanner = Scanner.new
    scanner.sync_to_yaml
  end

  desc "list", "list all version control dirs in database file."
  def list
    scanner = Scanner.new
    scanner.list
  end

  desc "update", "update all version control dirs."
  def update
    scanner = Scanner.new
    puts group
    require 'pp'
    pp ARGV
    scanner.load_from_yaml do |dir|
      puts "dir=#{dir.path}"
      $curr_dir = dir
      if dir.vc_type == :git
        dir.update
      end
    end
  end

  desc "fastupdate", "update only your changed on other computer."
  def fastupdate
  end
end

VcSyncRunner.start
