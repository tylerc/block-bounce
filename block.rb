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
		Rubygame::Surface.load "player.bmp"
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
		# draw the sprites
		@lvl_sprites.each_key do |sprite|
			@sprites[@lvl_sprites[sprite]].blit @screen, [sprite[0] * 64, sprite[1] * 32]
		end
		
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
