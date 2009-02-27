require 'rubygame'
require 'yaml'
Rubygame::TTF.setup

class LevelEditor
	def initialize
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
		@queue.each do |ev|
			case ev
				when Rubygame::QuitEvent
					Rubygame.quit
					exit
				when Rubygame::KeyDownEvent
					case ev.key
						when Rubygame::K_ESCAPE
							@queue.post(Rubygame::QuitEvent.new)
					end
			end
		end
	end
	
	def draw
		@screen.fill [0,0,0]
		@screen.flip
	end
end

leveler = LevelEditor.new
leveler.run
