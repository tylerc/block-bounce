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
		@font = Rubygame::TTF.new 'FreeSans.ttf', 72
		@selx, @sely = 0, 0
		@tiles = {}
		@tiles_color = {}
		@tile_size_x.times do |x|
			@tile_size_y.times do |y|
				@tiles[[x,y]] = Rubygame::Surface.new [@scale, @scale]
			end
		end
		@tile_size_x.times do |x|
			@tile_size_y.times do |y|
				@tiles_color[[x,y]] = [0,0,0,0]
			end
		end
		@grid_showing = true
		@cursor_showing = true
		@buf = " "
		@buf2 = " "
		@cur_edit = nil
		@line_color = nil
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
						when Rubygame::K_S
							@grid_showing == true ? @grid_showing = false : @grid_showing = true
						when Rubygame::K_H
							@cursor_showing == true ? @cursor_showing = false : @cursor_showing = true
						when Rubygame::K_R
							@cur_edit = 0
							@buf2 = "Red: "
						when Rubygame::K_G
							@cur_edit = 1
							@buf2 = "Green: "
						when Rubygame::K_B
							@cur_edit = 2
							@buf2 = "Blue: "
						when Rubygame::K_A
							@cur_edit = 3
							@buf2 = "Alpha: "
						when Rubygame::K_RETURN
							if @cur_edit != nil
								@tiles_color[[@selx,@sely]][@cur_edit] = @buf.to_i
								@buf = " "
								@cur_edit = nil
								@buf2 = " "
							end
						when Rubygame::K_BACKSPACE
							@buf = @buf[0..@buf.length-2]
						when Rubygame::K_Q
							@buf = " "
							@cur_edit = nil
							@buf2 = " "
						when Rubygame::K_F
							# The pixels are looped through this way
							# because @tiles_color.each didn't work
							@tile_size_x.times do |x|
								@tile_size_y.times do |y|
									@tiles_color[[x,y]] = @tiles_color[[@selx,@sely]].clone
								end
							end
						when Rubygame::K_C
							@copy = @tiles_color[[@selx,@sely]].clone
						when Rubygame::K_V
							@tiles_color[[@selx, @sely]] = @copy.clone
						when Rubygame::K_L
							@line_color == nil ? @line_color = @tiles_color[[@selx,@sely]].clone : @line_color = nil
						# Numbers
						when Rubygame::K_0
							@buf += "0"
						when Rubygame::K_1
							@buf += "1"
						when Rubygame::K_2
							@buf += "2"
						when Rubygame::K_3
							@buf += "3"
						when Rubygame::K_4
							@buf += "4"
						when Rubygame::K_5
							@buf += "5"
						when Rubygame::K_6
							@buf += "6"
						when Rubygame::K_7
							@buf += "7"
						when Rubygame::K_8
							@buf += "8"
						when Rubygame::K_9
							@buf += "9"
					end
			end
		end
		# wraps the cursor
		# 1 is minused from the tile_size because
		# the cusor numbers from 0, not 1
		if @selx < 0
			@selx = @tile_size_x - 1
		end
		if @selx > @tile_size_x -1
			@selx = 0
		end
		
		if @sely < 0
			@sely = @tile_size_y - 1
		end
		
		if @sely > @tile_size_y - 1
			@sely = 0
		end
		
		@screen.title = "Sprite Editor: [#{@selx},#{@sely}] R:#{@tiles_color[[@selx,@sely]][0]} G:#{@tiles_color[[@selx,@sely]][1]} B:#{@tiles_color[[@selx,@sely]][2]} A:#{@tiles_color[[@selx,@sely]][3]}"
		
		if @cur_edit == nil
			@buf = " "
		end
		
		@line_color != nil ? @tiles_color[[@selx,@sely]] = @line_color.clone : nil
	end
	
	def draw
		@screen.fill [0,0,0]
		# Draw the tile grid
		if @grid_showing
			@tile_size_x.times do |x|
				@tile_size_y.times do |y|
					@tiles[[x,y]].blit @screen, [x * @scale, y * @scale]
					@tiles[[x,y]].fill @tiles_color[[x,y]]
					@screen.draw_box [x * @scale, y * @scale], [x * @scale + @scale, y * @scale + @scale], [0,255,0]
					@font.render(@buf2 + @buf, true, [255,255,255]).blit(@screen,[100,100])
				end
			end
		end
		# draw cursor
		if @cursor_showing
			@screen.draw_box [@selx * @scale, @sely * @scale], [@selx * @scale + @scale, @sely * @scale + @scale], [255,0,0]
		end
		@screen.flip
	end
end
print "Width: "
x = gets.chomp.to_i
print "Length: "
y = gets.chomp.to_i
game = SpriteEditor.new x, y
game.run
