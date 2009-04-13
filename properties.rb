#!/usr/bin/env ruby

require 'gtk2'
require 'yaml'

window = Gtk::Window.new
window.signal_connect("delete_event") {
  false
}

window.signal_connect("destroy") {
  Gtk.main_quit
}

table = Gtk::Table.new(20,2,true)

# Load level
hbox = Gtk::HBox.new(false,5)
level = Gtk::Entry.new
level_label = Gtk::Label.new("Level:")
hbox.pack_start_defaults(level_label)
hbox.pack_start_defaults(level)
level_button = Gtk::Button.new("Load Level")
labels = []
20.times do |x|
	labels[x] = Gtk::Label.new("")
end
entries = []
20.times do |x|
	entries[x] = Gtk::Entry.new
end
level_button.signal_connect("clicked") do
	#input = File.new "#{level.text}.lvl"
	input = File.new "levels/lvl2.lvl"
	data = YAML.load(input)
	input.close
	length = data[:sprite_files].length
	data[:sprite_files].length.times do |x|
		labels[x].text = data[:sprite_files][x]
	end
	
	begin
	input = File.new "levels/lvl2.yml"
	data = YAML.load(input)
	input.close
	data[:health].length.times do |x|
		entries[x].text = data[:health][x].to_s
	end
	rescue Errno::ENOENT
		length.times do |x|
			entries[x].text = "1"
		end
	end
end

table.attach(hbox,0,1,0,1)
table.attach(level_button,1,2,0,1)
labels.length.times do |x|
	table.attach(labels[x],0,1,1+x,2+x)
end
entries.length.times do |x|
	table.attach(entries[x],1,2,1+x,2+x)
end

window.border_width = 5
window.title = "Level Properties Editor"
window.add(table)
window.show_all

Gtk.main
