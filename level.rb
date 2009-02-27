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
		
		@tile_size_x = 64
		@tile_size_y = 32
		@scale_x = @screen.width/@tile_size_x
		@scale_y = @screen.height/@tile_size_y
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
		# draw the grid
		@scale_x.times do |x|
			@scale_y.times do |y|
				@screen.draw_box [x * @tile_size_x, y * @tile_size_y], [x * @tile_size_x + @tile_size_x, y * @tile_size_y + @tile_size_y], [0,255,0]
			end
		end
		@screen.flip
	end
end

leveler = LevelEditor.new
leveler.run
