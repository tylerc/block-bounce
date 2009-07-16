def start
	@floor = Rubygame::Surface.new [@screen.width, 5]
	@floor.fill [255,255,255]
	@time = 0
end

def updating
	@power_pos = [0,0]
	if @bally+@ball.height >= @screen.height-@floor.height
		@hope *= -1
	end
	
	@time += 1
	if @time >= 300
		stop
	end
end

def stop
	reset_power
end

def drawing
	@floor.blit @screen, [0,@screen.height-@floor.height]
end
