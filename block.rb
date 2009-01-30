#!/usr/bin/env ruby

require 'gosu'

class TileEngine < Gosu::Window
	def initialize title, width, height, tilesize, tiles
		super width, height, false
		self.caption = title
	end
end

class BlockGame < TileEngine
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

game = BlockGame.new "Block Bounce!", 640, 480, 32, {}
game.show
