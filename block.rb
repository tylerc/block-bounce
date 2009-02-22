require 'rubygems'
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
						end
				end
			end
			# Draw the tile grid
			(@screen.width/@tile_size_x).times do |x|
				(@screen.height/@tile_size_y).times do |y|
					@screen.draw_box [x * @tile_size_x, y * @tile_size_y], [x * @tile_size_x + @tile_size_x, y * @tile_size_y + @tile_size_y] , [0,255,0]
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

class World
	def initialize
		@screen = Rubygame::Screen.new [800,600], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Block Bounce"
		
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
	end
	def fpsUpdate
		@screen.title = "FPS: #{@clock.framerate}"
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
						@screen.title = "UP KEY PRESSED"
						@myY -= 1
					when Rubygame::K_DOWN
						@screen.title = "DOWN KEY PRESSED"
						@myY += 1
					when Rubygame::K_RIGHT
						@screen.title = "RIGHT KEY PRESSED"
						@myX += 1
					when Rubygame::K_LEFT
						@screen.title = "LEFT KEY PRESSED"
						@myX -= 1
					when Rubygame::K_R
						@screen.fill [255,0,0]
					when Rubygame::K_B
						@screen.fill [0,0,255]
					when Rubygame::K_G 
						@screen.fill [0,255,0]
					when Rubygame::K_SPACE
						
					end
				end
			end
			
			@mySq.blit(@screen, [@myX, @myY])
			@screen.flip
			#fpsUpdate
			@clock.tick
		end
	end
end

game = TileManager.new
game.run
