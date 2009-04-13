#!/usr/bin/env ruby

require 'gtk2'

window = Gtk::Window.new
window.signal_connect("delete_event") {
  false
}

window.signal_connect("destroy") {
  Gtk.main_quit
}

table = Gtk::Table.new(1,2,true)

hbox = Gtk::HBox.new(false,5)
level = Gtk::Entry.new
level_label = Gtk::Label.new("Level:")
hbox.pack_start_defaults(level_label)
hbox.pack_start_defaults(level)
level_button = Gtk::Button.new("Load Level")
level_button.signal_connect("clicked") do
	
end

table.attach(hbox,0,1,0,1)
table.attach(level_button,1,2,0,1)


window.border_width = 5
window.title = "Level Properties Editor"
window.add(table)
window.show_all

Gtk.main
