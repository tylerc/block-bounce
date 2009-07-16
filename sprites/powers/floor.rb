def start
	@floor = Rubygame::Surface.new [@screen.width, 10]
	@floor.fill [255,255,255]
	@time = 0
	@stop_time = 300
end

def updating
	@power_pos = [0,0]
	if @bally+@ball.height >= @screen.height-@floor.height
		@hope *= -1
	end
	
	@time += 1
	if @time >= @stop_time
		stop
	end
end

def stop
	reset_power
end

def drawing
	@floor.blit @screen, [0,@screen.height-@floor.height]
	@font3.render(((@stop_time-@time)/30).to_i.to_s, true, [255,255,255]).blit(@screen,[40,0])
end
