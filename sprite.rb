require "rubygame"
require 'yaml'
Rubygame::TTF.setup

class SpriteEditor
	def initialize data, dir
		@screen = Rubygame::Screen.new [640,640], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Sprite Editor"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
		
		@tile_size_x = data[:width]
		@tile_size_y = data[:height]
		
		# This sets the scale factor by the smallest 
		# one (so it all fits on the screen)
		# This is done so that the size of the squares are uniform
		scale_x = @screen.width/@tile_size_x
		scale_y = @screen.height/@tile_size_y
		scale_x < scale_y ? @scale = scale_x : @scale = scale_y
		@font = Rubygame::TTF.new 'FreeSans.ttf', 72
		@selx, @sely, @oldselx, @oldsely = 0, 0, 0, 0
		@tiles = {}
		@tile_size_x.times do |x|
			@tile_size_y.times do |y|
				@tiles[[x,y]] = Rubygame::Surface.new [@scale, @scale]
			end
		end
		if data[:colors] == nil
			@tiles_color = {}
			@tile_size_x.times do |x|
				@tile_size_y.times do |y|
					@tiles_color[[x,y]] = [0,0,0,0]
				end
			end
		else
			@tiles_color = data[:colors]
		end
		@grid_showing = true
		@cursor_showing = true
		@buf = " "
		@buf2 = " "
		@cur_edit = nil
		@line_color = nil
		@mode = :edit
		@view_scale = 1
		@name = data[:name]
		@dir = dir
		@redraw_grid = true
	end
	
	def run
		loop do
			update
			draw
			@clock.tick
		end
	end
	
	def update
		@oldselx = @selx
		@oldsely = @sely
		@queue.each do |ev|
			case ev
				when Rubygame::QuitEvent
					save
					Rubygame.quit
					exit
				when Rubygame::KeyDownEvent
					case ev.key
						when Rubygame::K_ESCAPE
							@queue.post(Rubygame::QuitEvent.new)
						when Rubygame::K_UP
							@mode == :edit ? @sely -= 1 : @view_scale += 1
						when Rubygame::K_DOWN
							@mode == :edit ? @sely += 1 : (@view_scale > 0 ? @view_scale -= 1 : nil)
						when Rubygame::K_LEFT
							@mode == :edit ? @selx -= 1 : @view_scale = 1
						when Rubygame::K_RIGHT
							if @mode == :edit
								@selx += 1
							end
							if @mode == :view
								@tile_size_x < @tile_size_y ? temp = @tile_size_x : temp = @tile_size_y
								temp2 = 1
								loop do
									temp2 += 1
									if temp2 * temp > 640
										@view_scale = temp2 - 1
										break
									end
								end
							end
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
							@redraw_grid = true
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
								@redraw_grid = true
							end
						when Rubygame::K_BACKSPACE
							@buf = @buf[0..@buf.length-2]
						when Rubygame::K_Q
							@buf = " "
							@cur_edit = nil
							@buf2 = " "
							@redraw_grid = true
						when Rubygame::K_F
							# The pixels are looped through this way
							# because @tiles_color.each didn't work
							@tile_size_x.times do |x|
								@tile_size_y.times do |y|
									@tiles_color[[x,y]] = @tiles_color[[@selx,@sely]].clone
								end
							end
							@redraw_grid = true
						when Rubygame::K_C
							@copy = @tiles_color[[@selx,@sely]].clone
						when Rubygame::K_V
							@tiles_color[[@selx, @sely]] = @copy.clone
						when Rubygame::K_L
							@line_color == nil ? @line_color = @tiles_color[[@selx,@sely]].clone : @line_color = nil
						when Rubygame::K_T
							@mode == :edit ? @mode = :view : @mode = :edit
							@screen.fill [0,0,0]
							@mode == :view ? @redraw_grid = true : nil
						when Rubygame::K_O
							@mode = :save_bmp
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
		
		if @cur_edit == nil
			@buf = " "
		end
		
		@line_color != nil ? @tiles_color[[@selx,@sely]] = @line_color.clone : nil
	end
	
	def draw
		if @mode == :edit
			@screen.title = "Sprite Editor: [#{@selx},#{@sely}] R:#{@tiles_color[[@selx,@sely]][0]} G:#{@tiles_color[[@selx,@sely]][1]} B:#{@tiles_color[[@selx,@sely]][2]} A:#{@tiles_color[[@selx,@sely]][3]}"
			
			# Draw the tile grid
			if @redraw_grid
				@tile_size_x.times do |x|
					@tile_size_y.times do |y|
						@tiles[[x,y]].blit @screen, [x * @scale, y * @scale]
						@tiles[[x,y]].fill @tiles_color[[x,y]]
						if @grid_showing
							@screen.draw_box [x * @scale, y * @scale], [x * @scale + @scale, y * @scale + @scale], [0,255,0]
						end
					end
				end
				# checking if this is the first draw is hack-ish fix for a weird error (where the sprite wouldn't be drawn)
				@first_draw.nil? ? @first_draw = false : @redraw_grid = false
			end
			
			@font.render(@buf2 + @buf, true, [255,255,255]).blit(@screen,[100,100])
			# draw cursor
		
			@tiles[[@oldselx,@oldsely]].blit @screen, [@oldselx * @scale, @oldsely * @scale]
			@tiles[[@oldselx,@oldsely]].fill @tiles_color[[@oldselx,@oldsely]]
			if @grid_showing
				@screen.draw_box [@oldselx * @scale, @oldsely * @scale], [@oldselx * @scale + @scale, @oldsely * @scale + @scale], [0,255,0]
			end
			if @cursor_showing
				@screen.draw_box [@selx * @scale, @sely * @scale], [@selx * @scale + @scale, @sely * @scale + @scale], [255,0,0]
			end
		end
		
		if @mode == :view
			@screen.fill [0,0,0]
			# Draw the sprite
			@screen.title = "Sprite Viewer Scale:#{@view_scale}"
			(@tile_size_x*@view_scale).times do |x|
				(@tile_size_y*@view_scale).times do |y|
					@screen.set_at [x,y], @tiles_color[[x/@view_scale,y/@view_scale]]
				end	
			end
		end
		
		if @mode == :save_bmp
			temp_surf = Rubygame::Surface.new [@tile_size_x,@tile_size_y]
			@tile_size_x.times do |x|
				@tile_size_y.times do |y|
					temp_surf.set_at [x,y], @tiles_color[[x/@view_scale,y/@view_scale]]
				end	
			end
			temp_surf.savebmp("#{@dir}.bmp")
			@mode = :edit
		end
		@screen.flip
	end
	
	def save
		data = {}
		data[:width] = @tile_size_x
		data[:height] = @tile_size_y
		data[:colors] = @tiles_color
		data[:name] = @name
		puts "Saving sprite"
		input = File.new "#{@dir}.sprite", "w"
		input.puts YAML.dump(data)
		input.close
		puts "Sprite saved"
	end
end
data = {}
begin
	puts "Opening file #{ARGV[0]}.sprite..."
	input = File.new "#{ARGV[0]}.sprite", "r"
	data = YAML.load(input)
	input.close
rescue Errno::ENOENT
	puts "File open failed"
	print "Name: "
	data[:name] = STDIN.gets.chomp.to_s
	print "Width: "
	data[:width] = STDIN.gets.chomp.to_i
	print "Height: "
	data[:height] = STDIN.gets.chomp.to_i
end
game = SpriteEditor.new data, ARGV[0]
game.run
