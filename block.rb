#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'

class GameWindow < Gosu::Window
	def initialize
		super 640, 480, false
		self.caption = "Block Bounce!"
	end
	
	def update
	end
	
	def draw
	end
	
	def button_down id
		if id == Gosu::Button::KbEscape
			close
		end
	end
end

module ZOrder
	Background, Objects = *0..1
end

window = GameWindow.new
window.show
