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
19.times do |x|
	labels[x] = Gtk::Label.new("")
end
entries = []
19.times do |x|
	entries[x] = Gtk::Entry.new
end
level_button.signal_connect("clicked") do
	begin
		input = File.new "#{level.text}.lvl"
		data = YAML.load(input)
		input.close
		length = data[:sprite_files].length
		data[:sprite_files].length.times do |x|
			labels[x].text = data[:sprite_files][x]
		end
	rescue
		puts "Could not load level"
		length = 0
	end
	begin
		input = File.new "#{level.text}.yml"
		data = YAML.load(input)
		input.close
		data[:health].length.times do |x|
			entries[x].text = data[:health][x].to_s
		end
		@health = data[:health].clone
		rescue Errno::ENOENT
			@health = {}
			length.times do |x|
				entries[x].text = "1"
				@health[x] = 1
			end
	end
end
save_button = Gtk::Button.new("Save")
save_button.signal_connect("clicked") do
	save = true
	@health.length.times do |x|
		@health[x] = entries[x].text.to_i
		@health[x] == 0 ? save = false : nil
	end
	if save
		data = {}
		data[:health] = @health.clone
	
		output = File.new "#{level.text}.yml", 'w'
		output.puts YAML.dump(data)
		output.close
	else
		puts "Values can't be Strings or 0"
	end
end

table.attach(hbox,0,1,0,1)
table.attach(level_button,1,2,0,1)
table.attach(save_button,1,2,1,2)
labels.length.times do |x|
	table.attach(labels[x],0,1,2+x,3+x)
end
entries.length.times do |x|
	table.attach(entries[x],1,2,2+x,3+x)
end

window.border_width = 5
window.title = "Level Properties Editor"
window.add(table)
window.show_all

Gtk.main
