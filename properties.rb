#!/usr/bin/env ruby

require 'gtk2'

window = Gtk::Window.new
window.signal_connect("delete_event") {
  false
}

window.signal_connect("destroy") {
  Gtk.main_quit
}

window.border_width = 5
window.set_size_request(500,300)
window.title = "Level Properties Editor"
window.show_all

Gtk.main
