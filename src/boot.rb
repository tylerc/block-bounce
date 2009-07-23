require 'rubygems'
require 'rubygame'
require 'yaml'
unless ARGV[0] == nil
	require File.dirname(RUBYSCRIPT2EXE::APPEXE) + '/' + ARGV[0]
end
