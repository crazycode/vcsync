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
        scanner.sync_to_yaml(group)
      end

    end


    class ListCommand < AbstractCommand
      parameter "[action]", "Actons: {groups, dirs}", :attribute_name => :action, :default => "dirs"
      def execute
        scanner = Scanner.new
        scanner.list(action)
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
          if dir.vc_type == :git
            dir.update
          end
        end
      end

    end


    class MainCommand < AbstractCommand

      subcommand "test", "A test subcommand.", TestCommand
      subcommand "sync", "Sync Version Control Directories, if had some new repository, checkout it.", SyncCommand
      subcommand "list", "list all version control dirs in database file.", ListCommand
      subcommand "update", "update all version control dirs.", UpdateCommand
    end

  end

end

VCSYNC::Runner::MainCommand.run
