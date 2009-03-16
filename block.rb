require 'rubygame'

class Game
	def initialize
		@screen = Rubygame::Screen.new [512,544], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Block Bounce!"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
	end
	
	def run
		loop do
			update
			draw
			@clock.tick
		end
	end
	
	def update
	end
	
	def draw
	end
end

block_bounce = Game.new
block_bounce.run
