require 'rubygame'
require 'yaml'
Rubygame::TTF.setup

class Game
	def initialize
		@screen = Rubygame::Screen.new [512,650], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Block Bounce!"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
		@font = Rubygame::TTF.new 'FreeSans.ttf', 56
		@font2 = Rubygame::TTF.new 'FreeSans.ttf', 25
		@font3 = Rubygame::TTF.new 'FreeSans.ttf', 20
		
		@levels = []
		if File.directory? 'levels'
			Dir.entries('levels/.').each do |x|
				if x != '..' and x != '.' and x[-3..-1] == 'lvl'
					@levels += [x]
				end
			end
		else
			puts 'Error! Could not load levels'
			exit
		end
		@powers = []
		@powers_code = []
		if File.directory? 'sprites/powers'
			Dir.entries('sprites/powers/.').each do |x|
				if x != '..' and x != '.'
					if x[-3..-1] == 'bmp'
						@powers += [x]
					end
					if x[-2..-1] == 'rb'
						File.open 'sprites/powers/' + x, 'r' do |f|
							@powers_code += [f.read]
						end
					end
				end
			end
		else
			puts 'Error! Could not load powers'
			exit
		end
		@power = nil # Power-up object
		@power_pos = [0,0]
		@power_file = ""
		@player = Rubygame::Surface.load "sprites/player.bmp"
		@ball = Rubygame::Surface.load 'sprites/ball.bmp'
		@title = Rubygame::Surface.load 'sprites/bounce.bmp'
		
		# Main menu variables
		@mouse_y = 0
		@selected = 0
		@cur_level = 0
		@mode = :pick
		@back_color = [255,255,255]
		
		# Sounds
		@sounds = {:bounce => Rubygame::Sound.load('sound/bounce.wav')}
		
		@state = :menu
		load_settings
	end
	
	def save_settings
		File.open 'settings.yml', 'w' do |f|
			f.puts YAML.dump({:cur_level => @cur_level})
		end
	end
	
	def load_settings
		File.open 'settings.yml', 'r' do |f|
			data = YAML.load(f.read)
			@cur_level = data[:cur_level]
		end
	end
	
	def reset life=false
		@x = @screen.width/2
		@y = @screen.height-32
		@ballx = @screen.width/2
		@bally = @y-@ball.height
		@ball_speed = 10 # do not set to 1 (the ball wont move...)
		@angle = 220
		@hope = 1
		@hope2 = 1
		@started = false
		if life
			@life = 3
		end
	end
	
	def run
		loop do
			if @state == :playing
				update
				draw
			end
			if @state == :paused
				update_paused
				draw_paused
			end
			if @state == :quitting
				update_quitting
				draw_quitting
			end
			if @state == :loading
				update_loading
				draw_loading
			end
			if @state == :menu
				update_menu
				draw_menu
			end
			@clock.tick
		end
	end
	
	def draw_menu
		@screen.fill [0,0,0]
		@title.blit @screen, [0,0]
		color = [255,255,255]
		color2 = [255,255,255]
		color3 = [255,255,255]
		color4 = [255,255,255]
		color5 = [255,255,255]
		y = @font2.size_text('A')[1]
		if @mouse_y > 200 and @mouse_y < y+200
			color = [0, 255, 0]
			@selected = 1
		end
		if @mouse_y > 200+y and @mouse_y < y*2+200
			color2 = [0, 255, 0]
			@selected = 2
		end
		if @mouse_y > 200+y*2 and @mouse_y < y*3+200
			color3 = [0, 255, 0]
			@selected = 3
		end
		if @mouse_y > 200+y*3 and @mouse_y < y*4+200
			color4 = [0, 255, 0]
			@selected = 4
		end
		if @mouse_y > 200+y*4 and @mouse_y < y*5+200
			color5 = [255, 0, 0]
			@selected = 5
		end
		# Borders are at 190 and 320
		@font2.render("Start", true, color).blit(@screen, [190+(65-@font2.size_text('Start')[0]/2),200])
		@font2.render("Continue", true, color2).blit(@screen, [190+(65-@font2.size_text('Continue')[0]/2),200+y])
		@font2.render("Play Level", true, color3).blit(@screen, [190+(65-@font2.size_text('Play Level')[0]/2),200+y*2])
		@font2.render("Options", true, color4).blit(@screen, [190+(65-@font2.size_text('Options')[0]/2),200+y*3])
		@font2.render("Quit", true, color5).blit(@screen, [190+(65-@font2.size_text('Quit')[0]/2),200+y*4])
		
		@screen.flip
	end
	
	def update_menu
		reset true
		@queue.each do |ev|
			case ev
				when Rubygame::QuitEvent
					save_settings
					Rubygame.quit
					exit
				when Rubygame::MouseUpEvent
					case @selected
						when 1
							@cur_level = 0
							@mode = :progress
							load_level('levels/' + @levels[@cur_level].split('.')[0..-2].to_s)
							@state = :playing
						when 2
							@mode = :progress
							load_level('levels/' + @levels[@cur_level].split('.')[0..-2].to_s)
							@state = :playing
						when 3
							@mode = :pick
							@state = :loading
						when 4
							puts "NOT IMPLEMENTED (alpha8)"
						when 5
							save_settings
							Rubygame.quit
							exit
					end
				when Rubygame::MouseMotionEvent
					@mouse_y = ev.pos[1]
				when Rubygame::KeyDownEvent
					case ev.key
						when Rubygame::K_ESCAPE
							save_settings
							@to = :exit
							@from = :menu
							@state = :quitting
					end
			end
		end
	end
	
	def draw_loading
		@screen.fill [0,0,0]
		@title.blit @screen, [0,0]
		@levels.each do |level|
			@screen.draw_box([@screen.width/2-@font3.size_text(level)[0]/2-5,35*@levels.index(level)+200],[@screen.width/2+@font3.size_text(level)[0]/2+5,35*@levels.index(level)+@font3.size_text(level)[1]+200],[0,255,255])
			@font3.render(level, true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font3.size_text(level)[0]/2,35*@levels.index(level)+200])
		end
		@font3.render('Back', true, @back_color).blit(@screen,[@screen.width/2-@font3.size_text('Back')[0]/2,@levels.length*35+200])
		@screen.flip
	end
	
	def update_loading
		x = @screen.width/2-@font3.size_text('Back')[0]/2
		y = @levels.length*35+200
		width, height = @font3.size_text('Back')
		@queue.each do |ev|
			case ev	
				when Rubygame::QuitEvent
					Rubygame.quit
					exit
				when Rubygame::KeyDownEvent
					case ev.key
						when Rubygame::K_E
							eval STDIN.gets
					end
				when Rubygame::MouseUpEvent
					begin
					load_level("levels/#{@levels[(ev.pos[1]-200)/35][0..-5]}")
					@state = :playing
					rescue
					end
					if ev.pos[0] > x and ev.pos[0] < x+width and ev.pos[1] > y and ev.pos[1] < y+height
						@state = :menu
					end
				when Rubygame::MouseMotionEvent	
					# Back to menu button
					if ev.pos[0] > x and ev.pos[0] < x+width and ev.pos[1] > y and ev.pos[1] < y+height
						@back_color = [255,0,0]
					else
						@back_color = [255,255,255]
					end
			end
		end
	end
	
	def update_quitting
		@queue.each do |ev|
			case ev	
				when Rubygame::QuitEvent
					Rubygame.quit
					exit
				when Rubygame::KeyDownEvent
					case ev.key
						when Rubygame::K_E
							eval STDIN.gets
						when Rubygame::K_Y
							if @to == :menu
								@state = @to
							else
								Rubygame.quit
								exit
							end
						when Rubygame::K_N
							@state = @from
					end
			end
		end
	end
	
	def draw_quitting
		@screen.fill [0,0,0]
		@font.render("Are you sure", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("Are you sure")[0]/2,@screen.height/2-100])
		@font.render("You want to Quit?", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("You want to Quit?")[0]/2,@screen.height/2])
		@font.render("(Y/N)", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("(Y/N)")[0]/2,@screen.height/2+100])
		@screen.flip
	end
	
	def update_paused
		@queue.each do |ev|
			case ev
				when Rubygame::QuitEvent
					Rubygame.quit
					exit
				when Rubygame::KeyDownEvent
					case ev.key
						when Rubygame::K_ESCAPE
							@from = :paused
							@to = :menu
							@state = :quitting
						when Rubygame::K_E
							eval STDIN.gets
						when Rubygame::K_P
							@state = :playing
					end
			end
		end
	end
	
	def draw_paused
		@screen.fill [0,0,0]
		@font.render("Paused", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("Paused")[0]/2,@screen.height/2])
		@screen.flip
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
							@state = :quitting
							@from = :playing
							@to = :menu
						when Rubygame::K_E
							eval STDIN.gets
						when Rubygame::K_P
							@state = :paused
					end
				when Rubygame::MouseMotionEvent
					@x = ev.pos[0]-@player.width/2
				when Rubygame::MouseUpEvent
					@started = true
					if @lvl_sprites.length == 0 or @life <= 0
						if @mode == :pick
							@state = :loading
							reset true
						elsif @mode == :progress and @cur_level+1 == @levels.length
							@state = :menu
						elsif @mode == :progress
							if @lvl_sprites.length == 0
								@cur_level += 1
							end
							load_level('levels/' + @levels[@cur_level].split('.')[0..-2].to_s)
							reset true
						end
					end
			end
		end
		
		#update ball position
		if @started
			@ballx += move[0]
			@bally += move[1]
		end
                # Check for collisions with borders
                
                # Left
                if @ballx <= 0
                	@angle *= -1
			@ballx = 1
			@sounds[:bounce].play
                end
                
                # Right
                if @ballx >= @screen.width-@ball.width
                	@angle *= -1
                	@sounds[:bounce].play
                end
                
                # Top
                if @bally <= 0
                	@hope *= -1
			@bally = 1
			@sounds[:bounce].play
                end
                
                # Bottom
                if @bally+@ball.height >= @screen.height
                	@life -= 1
                	reset
                end
                
                # Check for collision with paddle and ball
                if @bally+@ball.height >= @y and @ballx+@ball.width > @x and @ballx < @x + @player.width
                	@angle = @ballx-(@x + @player.width/2)
                	@hope = 1
                	@hope2 = 1
                end
                
                # Check for collision with paddle and power
                if @power_pos[1]+32 >= @y and @power_pos[0]+32 > @x and @power_pos[0] < @x + @player.width
                	eval @powers_code[@powers.index(@power_file)]
                	@power_file = ""
                	@power = nil
                	@power_pos = [0,0]
                end
                
		@lvl_sprites.each_key do |sprite|
			if sprite[0] * 64 > @ballx + @ball.width
				next
			end
			
			if sprite[0] * 64 + 64 < @ballx
				next
			end
			
			if sprite[1] * 32 > @bally + @ball.height
				next
			end
			
			if sprite[1] * 32 + 32 < @bally
				next
			end
			
			# Right
			if @ballx - move[0] > sprite[0] * 64 + 64
				@hope2 *= -1
			end
			
			# Left
			if @ballx - move[0] < sprite[0] * 64
				@hope2 *= -1
			end
			
			# Top
			if @bally - move[1] < sprite[1] * 32
				@hope *= -1
			end
			
			# Bottom
			if @bally - move[1] > sprite[1] * 32 + 32
				@hope *= -1
			end
			
			@sprites_health[sprite] -= 1
			
			if @sprites_health[sprite] == 0
				@lvl_sprites.delete sprite
			end
			@sounds[:bounce].play
			if @power == nil
				@power_file = @powers[rand(@powers.length)]
				@power = Rubygame::Surface.load 'sprites/powers/' + @power_file
				@power_pos = [@ballx, @bally]
			end
		end
		
		# Update power
		if @power != nil
			@power_pos[1] += 1
		end
	end
	
	def draw
		@screen.fill [0,0,0]
		if @life > 0
			# draw the sprites
			@lvl_sprites.each_key do |sprite|
				@sprites[@lvl_sprites[sprite]].blit @screen, [sprite[0] * 64, sprite[1] * 32]
			end
		
			# draw the player and ball
			@player.blit @screen, [@x,@y]
			@ball.blit @screen, [@ballx, @bally]
		
			# Draw the life "bar"
			@font.render("Life: ", true, [255,255,255]).blit(@screen,[@screen.width-220,5])
			@life.times do |x|
				@ball.blit @screen, [@screen.width-100+25*x,50]
			end
		
			if !@started
				@font.render("Click To Start...", true, [255,255,255]).blit(@screen,[@screen.width/2-@font.size_text("Click To Start...")[0]/2,@screen.height/2])
			end
		else
			@font.render("You got pwned!", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("You got pwned!")[0]/2,@screen.height/2])
			@font.render("Click To Start...", true, [255,255,255]).blit(@screen,[@screen.width/2-@font.size_text("Click To Start...")[0]/2,@screen.height/2+100])
		end
		if @lvl_sprites.length == 0 and @cur_level+1 != @levels.length
			@screen.fill [0,0,0]
			@font.render("You are an uber", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("You are an uber")[0]/2,@screen.height/2])
			@font.render("l33t player!", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("l33t player!")[0]/2,@screen.height/2+@font.size_text("l33t player!")[1]])
			@font.render("Click To Start...", true, [255,255,255]).blit(@screen,[@screen.width/2-@font.size_text("Click To Start...")[0]/2,@screen.height/2+250])
		end
		
		if @lvl_sprites.length == 0 and @cur_level+1 == @levels.length
			@screen.fill [0,0,0]
			@font.render("You beat the game!!!", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("You beat the game!!!")[0]/2,@screen.height/2-200])
			@font.render("You are the best", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("You are the best")[0]/2,@screen.height/2])
			@font.render("player ever!!!", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("player ever!!!")[0]/2,@screen.height/2+@font.size_text("player ever!!!")[1]])
			@font.render("Click To Finish...", true, [255,255,255]).blit(@screen,[@screen.width/2-@font.size_text("Click To Finish...")[0]/2,@screen.height/2+250])
		end
		unless @power == nil
			@power.blit(@screen, @power_pos)
		end
		@screen.flip
	end
	
	def load_level name
		@sprites = []
		@sprite_files = []
		begin
		input = File.new "#{name}.lvl"
		data = YAML.load(input)
		data[:sprite_files].length.times do |sprite|
			@sprites[sprite] = Rubygame::Surface.load data[:sprite_files][sprite]
			@sprite_files += data[:sprite_files][sprite].to_a
		end
		@lvl_sprites = data[:lvl_sprites].clone
		@name = data[:name]
		input.close
		rescue Errno::ENOENT
			puts "Could not load #{name}.lvl"
			exit
		end
		
		@sprites_health = {}
		begin
		input = File.new "#{name}.yml"
		data = YAML.load(input)
		input.close
		rescue Errno::ENOENT
		puts "No level properties defined (found in #{name}.yml)"
		puts 'using defaults...'
		data = {}
		data[:health] = {}
		@lvl_sprites.values.uniq.length.times do |x|
			data[:health][x] = 1
		end
		end
		@sprites_health = @lvl_sprites.clone
		@sprites_health.each_key do |key|
			if data[:health][@sprites_health[key]] != nil
				@sprites_health[key] = data[:health][@sprites_health[key]]
			else
				puts "A property wasn't defined"
				puts 'defaulting to 1...'
				@sprites_health[key] = 1
			end
		end
	end
	
	def move
		return (@ball_speed * Math.sin(@angle * (3.14 / 180))).to_i * @hope2, -(@ball_speed * Math.cos(@angle * (3.14 / 180))).to_i * @hope
	end
end

block_bounce = Game.new
block_bounce.run
