def start
	@player = @player.zoom([0.5,1])
	@time = 0
	@stop_time = 300
end

def updating
	@power_pos = [0,0]
	@time += 1
	if @time >= @stop_time
		stop
	end
end

def stop
	@player = @player.zoom([2,1])
	reset_power
end

def drawing
	@font3.render(((@stop_time-@time)/30).to_i.to_s, true, [255,255,255]).blit(@screen,[40,0])
end
