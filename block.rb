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
		
		load_level ARGV[0]
		@player = Rubygame::Surface.load "sprites/player.bmp"
		@ball = Rubygame::Surface.load 'sprites/ball.bmp'
		reset true
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
						when Rubygame::K_E
							eval STDIN.gets
					end
				when Rubygame::MouseMotionEvent
					ev.pos[0] < @screen.width-@player.width ? @x = ev.pos[0]-@player.width/2 : @x = 448
				when Rubygame::MouseUpEvent
					@started = true
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
                end
                
                # Right
                if @ballx >= @screen.width-@ball.width
                	@angle *= -1
                end
                
                # Top
                if @bally <= 0
                	@hope *= -1
					@bally = 1
                end
                
                # Bottom
                if @bally+@ball.height >= @screen.height
                	@life -= 1
                	reset
                end
                
                # Check for collision with paddle
                if @bally+@ball.height >= @y and @ballx+@ball.width > @x and @ballx < @x + @player.width
                	@angle = @ballx-(@x + @player.width/2)
                	@hope = 1
                	@hope2 = 1
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
		end
		if @lvl_sprites.length == 0
			@screen.fill [0,0,0]
			@font.render("You are an uber", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("You are an uber")[0]/2,@screen.height/2])
			@font.render("l33t player!", true, [255, 255, 255]).blit(@screen,[@screen.width/2-@font.size_text("l33t player!")[0]/2,@screen.height/2+@font.size_text("l33t player!")[1]])
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
