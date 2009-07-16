def start
	@old_speed = @ball_speed
	@ball_speed += 5
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
	@ball_speed = @old_speed
	reset_power
end

def drawing
	@font3.render(((@stop_time-@time)/30).to_i.to_s, true, [255,255,255]).blit(@screen,[40,0])
end
