require 'rubygems'
require 'redcloth'

input = File.new "README.textile", 'r'
text = input.readlines.join
input.close

output = File.new "README.html", "w"
output.puts RedCloth.new(text).to_html
output.close
