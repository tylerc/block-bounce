require "rubygame"
Rubygame::TTF.setup

class TileManager
	def initialize
		@screen = Rubygame::Screen.new [640,640], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Block Bounce"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
		
		@tile_size_x = 32
		@tile_size_y = 32
		#@font = Rubygame::TTF.new 'FreeSans.ttf', @tile_size/2
		@selx, @sely = 0, 0
		@tiles = {}
		(@screen.width/@tile_size_x).times do |x|
			(@screen.height/@tile_size_y).times do |y|
				@tiles[[x,y]] = nil
			end
		end
		#puts @tiles.inspect.sort
		puts @tiles.length
		puts @tiles[[0,0]]
		puts @tiles[[19,19]]
	end
	
	def run
		loop do
			@queue.each do |ev|
				case ev
					when Rubygame::QuitEvent
						Rubygame.quit
						exit
					when Rubygame::KeyDownEvent
						case ev.key
							when Rubygame::K_ESCAPE
								Rubygame.quit
								exit
							when Rubygame::K_UP
								@sely -= 1
							when Rubygame::K_DOWN
								@sely += 1
							when Rubygame::K_LEFT
								@selx -= 1
							when Rubygame::K_RIGHT
								@selx += 1
							when Rubygame::K_SPACE
								puts @selx.to_s + '.' + @sely.to_s
							when Rubygame::K_E
								begin
									eval gets.chomp
								rescue
									puts 'ERROR!'
								end
						end
				end
			end
			# Draw the tile grid
			(@screen.width/@tile_size_x).times do |x|
				(@screen.height/@tile_size_y).times do |y|
					@screen.draw_box [x * @tile_size_x, y * @tile_size_y], [x * @tile_size_x + @tile_size_x, y * @tile_size_y + @tile_size_y] , [0,255,0]
					begin
						@tiles[[x,y]].blit @screen, [x * @tile_size_x, y * @tile_size_y]
					rescue NoMethodError
					end
					#@font.render("#{x.to_s}.#{y.to_s}", true, [255,0,0]).blit(@screen,[x * @tile_size, y * @tile_size])
				end
			end
			@screen.draw_box [@selx * @tile_size_x, @sely * @tile_size_y], [@selx * @tile_size_x + @tile_size_x, @sely * @tile_size_y + @tile_size_y], [255,0,0]
			@screen.flip
			#fpsUpdate
			@clock.tick
		end
	end
end

game = TileManager.new
game.run
