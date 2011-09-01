require 'rubygems'
require 'thor'
require 'pathname'
require 'yaml'


class VcSyncRunner < Thor
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
    scanner = Scanner.new
    scanner.sync_to_yaml
  end

  desc "list", "list all version control dirs in database file."
  def list
    scanner = Scanner.new
    alldirs = scanner.load_from_yaml
    alldirs.each do |dir|
      puts "#{dir.path}"
      dir.remotes.each do |r|
        puts "  #{r[:name]}:#{r[:url]}"
      end unless dir.remotes.empty?
      puts
    end
  end

end

VcSyncRunner.start
