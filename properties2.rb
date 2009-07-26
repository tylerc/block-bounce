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
		@font = Rubygame::TTF.new 'FreeSans.ttf', 30
		
		@files = []
		@file = ""
		Dir.foreach('levels') do |file|
			@files += [file] if file[-3..-1] == 'lvl'
		end
		@files.sort!
		@hover2 = []
		@files.each do |file|
			@hover2 += [false]
		end
		@level = {:sprite_files => []}
		@props = {}
		@hover = []
		@level[:sprite_files].length.times do |x|
			@hover[x] = false
		end
		@pos = [0,0]
		@height = @font.size_text('hello')[1]
		@hover3 = false
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
				when Rubygame::MouseMotionEvent
					@pos = ev.pos
				when Rubygame::MouseDownEvent
					@hover.length.times do |x|
						if @hover[x]
							if ev.button == Rubygame::MOUSE_LEFT
								@props[:health][x] += 1
							elsif ev.button == Rubygame::MOUSE_RIGHT
								@props[:health][x] -= 1
							end
						end
					end
					@hover2.length.times do |x|
						if @hover2[x]
							@level = YAML.load(File.read('levels/' + @files[x]))
							@file = 'levels/' + @files[x]
							if File.exists?('levels/' + @files[x].split('.')[0..-2].to_s + '.yml')
								@props = YAML.load(File.read('levels/' + @files[x].split('.')[0..-2].to_s + '.yml'))
							else
								@props = {:health => {}}
								@level[:sprite_files].length.times { |y| @props[:health][y] = 1 }
							end
						end
					end
					if @hover3
						save
					end
			end
		end
		@level[:sprite_files].length.times do |x|
			width = @font.size_text(@level[:sprite_files][x] + ': ' + @props[:health][x].to_s)[0]
			if collision_between(@pos[0],@pos[1],1,1, 200,x*@height,width, @height)
				@hover[x] = true
			else
				@hover[x] = false
			end
		end
		@files.each do |file|
			width = @font.size_text(file)[0]
			if collision_between(@pos[0],@pos[1],1,1, 0,@files.index(file)*@height,width,@height)
				@hover2[@files.index(file)] = true
			else
				@hover2[@files.index(file)] = false
			end
		end
		width = @font.size_text('Save')[0]
		if collision_between(@pos[0],@pos[1],1,1, 200, @screen.height-@height,width,@height)
			@hover3 = true
		else
			@hover3 = false
		end
	end
	
	def draw
		@screen.fill [0,0,0]
		@level[:sprite_files].length.times do |x|
			color = [0,255,0] if @hover[x]
			color = [255,255,255] if !@hover[x]
			@font.render("#{@level[:sprite_files][x]}: #{@props[:health][x]}", true, color).blit(@screen, [200,x*@height])
		end
		@files.each do |file|
			color = [0,255,0] if @hover2[@files.index(file)]
			color = [255,255,255] if !@hover2[@files.index(file)]
			@font.render(file, true, color).blit(@screen, [0,@files.index(file)*@height])
		end
		
		color = [0,255,0] if @hover3
		color = [255,255,255] if !@hover3
		@font.render("Save", true, color).blit(@screen, [200,@screen.height-@height])
		
		@screen.flip
	end
	
	def collision_between obj1x, obj1y, obj1width, obj1height, obj2x, obj2y, obj2width, obj2height
		if obj1y + obj1height < obj2y ; return false ; end
		if obj1y > obj2y + obj2height ; return false ; end
		if obj1x + obj1width < obj2x ; return false ; end
		if obj1x > obj2x + obj2width ; return false ; end
		return true
	end
	
	def save
		File.open(@file.split('.')[0..-2].to_s + '.yml','w') do |file|
			file.puts YAML.dump(@props) 
		end
	end
end

leveler = LevelEditor.new
leveler.run
