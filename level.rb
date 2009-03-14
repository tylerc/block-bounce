require 'rubygame'
require 'yaml'
Rubygame::TTF.setup

class LevelEditor
	def initialize
		@screen = Rubygame::Screen.new [512,700], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Level Editor"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
		@font = Rubygame::TTF.new 'FreeSans.ttf', 72
		
		@tile_size_x = 64
		@tile_size_y = 32
		@grid_width = 512
		@grid_height = 512
		@scale_x = @grid_width/@tile_size_x
		@scale_y = @grid_height/@tile_size_y
		@selx, @sely = 0, 0
		@buf, @buf2 = ' ', ' '
		@cur_edit = nil
		@sprites = []
		@grid_showing = true
		@lvl_sprites = {}
		@sprite_files = []
		@name = ''
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
					if @cur_edit != nil
						if @buf == ' ' and
							@buf = ev.string.chomp
						elsif ev.key == 8
							@buf.chop!
						else
							@buf += ev.string.chomp
						end
					end
					case ev.key
						when Rubygame::K_ESCAPE
							@queue.post(Rubygame::QuitEvent.new)
						when Rubygame::K_LSHIFT
							@cur_edit = :load_sprite
							@buf2 = "load: "
						when Rubygame::K_RETURN
							if @cur_edit != nil
								if @cur_edit == :load_sprite
									@sprites[@sprites.length] = Rubygame::Surface.load @buf
									@sprite_files += [@buf]
								end
								if @cur_edit == :save_level_with_name
									@name = @buf
									data = {}
									data[:sprite_files] = @sprite_files.clone
									puts "Saving level..."
									input = File.new "#{@buf}.lvl", "w"
									input.puts YAML.dump(data)
									input.close
									puts "Level saved!"
								end
								if @cur_edit == :load_level
									@sprites = []
									@sprite_files = []
									input = File.new "#{@buf}.lvl"
									data = YAML.load(input)
									data[:sprite_files].length.times do |sprite|
										@sprites[sprite] = Rubygame::Surface.load data[:sprite_files][sprite]
										@sprite_files += data[:sprite_files][sprite].to_a
									end
									input.close
								end
								@buf = " "
								@cur_edit = nil
								@buf2 = " "
							end
						when Rubygame::K_Q
							@buf = " "
							@cur_edit = nil
							@buf2 = " "
						when Rubygame::K_E
							if @cur_edit == nil
								eval gets
							end
						when Rubygame::K_H
							if @cur_edit == nil
								@grid_showing ? @grid_showing = false : @grid_showing = true
							end
						when Rubygame::K_A
							if @cur_edit == nil
								@cur_edit = :save_level_with_name
								@buf2 = "name: "
							end
						when Rubygame::K_L
							if @cur_edit == nil
								@cur_edit = :load_level
								@buf2 = "level: "
							end
					end
				when Rubygame::MouseDownEvent
					case ev.button
						when 1
							@selx = (ev.pos[0]/@tile_size_x).to_i
							@sely = (ev.pos[1]/@tile_size_y).to_i
							puts "#{@selx}, #{@sely}"
							if @sely >= 17
								@sel = @sprites[@sely-17+(5*@selx)]
							elsif @sely <= 15
								@sel != nil ? @lvl_sprites[[@selx,@sely]] = @sel : nil
							end
						when 3
							@selx = (ev.pos[0]/@tile_size_x).to_i
							@sely = (ev.pos[1]/@tile_size_y).to_i
							if @sely <= 15
								@lvl_sprites.delete [@selx,@sely]
							end
							if @sely >= 17
								@sprites.delete @sprites[@selx * ((700/@tile_size_y)-@scale_y)]
							end
					end
					
			end
		end
	end
	
	def draw
		@screen.fill [0,0,0]
		# draw the sprites
		@lvl_sprites.each_key do |sprite|
			@lvl_sprites[sprite].blit @screen, [sprite[0] * 64, sprite[1] * 32]
		end
		# draw the level map grid
		@scale_x.times do |x|
			@scale_y.times do |y|
				@grid_showing ? @screen.draw_box([x * @tile_size_x, y * @tile_size_y], [x * @tile_size_x + @tile_size_x, y * @tile_size_y + @tile_size_y], [0,255,0]) : nil
			end
		end
		
		# draw the loaded sprite grid
		# x * 3 + y
		@scale_x.times do |x|
			((700/@tile_size_y)-@scale_y).times do |y|
				begin
				@sprites[x * ((700/@tile_size_y)-@scale_y) + y].blit @screen, [x * @tile_size_x, y * @tile_size_y + 544]
				rescue
				end
				@grid_showing ? @screen.draw_box([x * @tile_size_x, y * @tile_size_y + 544], [x * @tile_size_x + @tile_size_x, y * @tile_size_y + @tile_size_y + 544], [0,0,255]) : nil
			end
		end
		
		# draw the cursor
		@screen.draw_box [@selx * @tile_size_x, @sely * @tile_size_y], [@selx * @tile_size_x + @tile_size_x, @sely * @tile_size_y + @tile_size_y], [255,0,0]
		
		# draw text
		@font.render(@buf2 + @buf, true, [255,255,255]).blit(@screen,[10,100])
		
		@screen.flip
	end
end

leveler = LevelEditor.new
leveler.run
