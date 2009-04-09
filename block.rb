require 'rubygame'
require 'yaml'

class Game
	def initialize
		@screen = Rubygame::Screen.new [512,608], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Block Bounce!"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
		
		load_level ARGV[0]
		@player = Rubygame::Surface.load "sprites/player.bmp"
		@ball = Rubygame::Surface.load 'sprites/ball.bmp'
		@x = @screen.width/2
		@y = @screen.height-32
		@ballx = @screen.width/2
		@bally = 590
		@ball_speed = 10 # do not set to 1 (the ball wont move...)
		@angle = 220
		@hope = 1
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
					ev.pos[0] < @screen.width-@player.width ? @x = ev.pos[0] : @x = 448
			end
		end
		
		#update ball position
		@ballx += (@ball_speed * Math.sin(@angle * (3.14 / 180))).to_i
                @bally += -(@ball_speed * Math.cos(@angle * (3.14 / 180))).to_i * @hope
                # Check for collisions with borders
                
                # Left
                if @ballx <= 0
                	@angle *= -1
                end
                
                # Right
                if @ballx >= @screen.width-@ball.width
                	@angle *= -1
                end
                
                # Top
                if @bally <= 0
                	@hope *= -1
                end
                
                # Bottom
                if @bally+@ball.height >= @screen.height
                	# reset
			@ballx = @screen.width/2
			@bally = 590
			@angle = 30
                end
                
                # Check for collision with paddle
                if @bally+@ball.height >= @y and @ballx+@ball.width > @x and @ballx < @x + @player.width
                	@angle = @ballx-(@x + @player.width/2)
                	@hope = 1
                end
                
                if !@lvl_sprites[[@ballx/64,@bally/32]].nil?
                	@hope *= -1
                end
		@lvl_sprites.delete [@ballx/64,@bally/32]
	end
	
	def draw
		@screen.fill [0,0,0]
		# draw the sprites
		@lvl_sprites.each_key do |sprite|
			@sprites[@lvl_sprites[sprite]].blit @screen, [sprite[0] * 64, sprite[1] * 32]
		end
		
		# draw the player and ball
		@player.blit @screen, [@x,@y]
		@ball.blit @screen, [@ballx, @bally]
		
		@screen.flip
	end
	
	def load_level name
		@sprites = []
		@sprite_files = []
		input = File.new "#{name}.lvl"
		data = YAML.load(input)
		data[:sprite_files].length.times do |sprite|
			@sprites[sprite] = Rubygame::Surface.load data[:sprite_files][sprite]
			@sprite_files += data[:sprite_files][sprite].to_a
		end
		@lvl_sprites = data[:lvl_sprites].clone
		@name = data[:name]
		input.close
	end
end

block_bounce = Game.new
block_bounce.run
