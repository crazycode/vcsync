Dir[File.join(File.dirname(__FILE__), 'vcsync/*.rb')].sort.each { |lib| require lib }
