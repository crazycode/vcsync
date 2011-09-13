require 'rubygems'
require 'pathname'
require 'yaml'
require "clamp"

$curr_dir = nil
# Trap for Ctrl-C
trap("INT") {
  $curr_dir.cleanup unless $curr_dir.nil?
  exit!
}


module VCSYNC

  module Runner

    class AbstractCommand < Clamp::Command
    end


    class TestCommand < AbstractCommand

      def execute
        require 'pp'
        pp Configuration.config
        pp Configuration.dbfile
        pp Configuration.vc_dirs
      end

    end


    class SyncCommand < AbstractCommand

      parameter "[Group]", "Group Name", :attribute_name => :group, :default => "ALL"
      def execute
        puts "group=#{group}"
        scanner = Scanner.new
        scanner.sync_to_yaml(group) {|dir|
          # if dir exists, update it, else create it.
          dir.check? ? dir.update : dir.create
        }
      end

    end


    class ListCommand < AbstractCommand
      parameter "[action]", "Actons: {groups, dirs}", :attribute_name => :action, :default => "dirs"
      def execute
        scanner = Scanner.new
        scanner.list(action)
      end

    end


    class RemoveCommand < AbstractCommand
      parameter "dir", "the dir to remove from vcsync.", :attribute_name => :dir
      def execute
        scanner = Scanner.new
        scanner.remove_from_yaml(`pwd`, dir)
      end

    end


    class UpdateCommand < AbstractCommand
      parameter "[Group]", "Group Name", :default => "ALL"
      def execute
        scanner = Scanner.new
        puts group
        require 'pp'
        pp ARGV
        scanner.load_from_yaml do |dir|
          puts "dir=#{dir.real_path}"
          $curr_dir = dir
          dir.update
        end
      end

    end


    class MainCommand < AbstractCommand
      subcommand "test", "A test subcommand.", TestCommand
      subcommand "sync", "Sync Version Control Directories, if had some new repository, checkout it.", SyncCommand
      subcommand "list", "list all version control dirs in database file.", ListCommand
      subcommand "update", "update all version control dirs.", UpdateCommand
      subcommand "remove", "remove dir from database.", RemoveCommand
    end

  end

end

VCSYNC::Runner::MainCommand.run
