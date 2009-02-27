require 'rubygame'
require 'yaml'
Rubygame::TTF.setup

class LevelEditor
	def intialize
		@screen = Rubygame::Screen.new [640,640], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Level Editor"
		
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

leveler = LevelEditor.new
leveler.run
