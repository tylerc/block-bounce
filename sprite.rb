require "rubygame"
Rubygame::TTF.setup

class SpriteEditor
	def initialize width, length
		@screen = Rubygame::Screen.new [640,640], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Sprite Editor"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
		
		@tile_size_x = width
		@tile_size_y = length
		
		# This sets the scale factor by the smallest 
		# one (so it all fits on the screen)
		# This is done so that the size of the squares are uniform
		scale_x = @screen.width/@tile_size_x
		scale_y = @screen.height/@tile_size_y
		scale_x < scale_y ? @scale = scale_x : @scale = scale_y
		#@font = Rubygame::TTF.new 'FreeSans.ttf', @tile_size/2
		@selx, @sely = 0, 0
		@tiles = {}
		(@screen.width/@tile_size_x).times do |x|
			(@screen.height/@tile_size_y).times do |y|
				@tiles[[x,y]] = nil
			end
		end
		@grid_showing = true
		@cursor_showing = true
	end
	
	def run
		loop do
			update
			draw
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
						when Rubygame::K_G
							@grid_showing == true ? @grid_showing = false : @grid_showing = true
						when Rubygame::K_H
							@cursor_showing == true ? @cursor_showing = false : @cursor_showing = true
					end
			end
		end
	end
	
	def draw
		@screen.fill [0,0,0]
		# Draw the tile grid
		if @grid_showing
			@tile_size_x.times do |x|
				@tile_size_y.times do |y|
					@screen.draw_box [x * @scale, y * @scale], [x * @scale + @scale, y * @scale + @scale], [0,255,0]
					begin
						@tiles[[x,y]].blit @screen, [x * @tile_size_x, y * @tile_size_y]
					rescue NoMethodError
					end
					#@font.render("#{x.to_s}.#{y.to_s}", true, [255,0,0]).blit(@screen,[x * @tile_size, y * @tile_size])
				end
			end
		end
		if @cursor_showing
			@screen.draw_box [@selx * @scale, @sely * @scale], [@selx * @scale + @scale, @sely * @scale + @scale], [255,0,0]
		end
		@screen.flip
		#fpsUpdate
		@clock.tick
	end
end
print "Width: "
x = gets.chomp.to_i
print "Length: "
y = gets.chomp.to_i
game = SpriteEditor.new x, y
game.run
