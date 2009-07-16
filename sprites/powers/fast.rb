def start
	@old_speed = @ball_speed
	@ball_speed += 5
	@time = 0
end

def updating
	@power_pos = [0,0]
	@time += 1
	if @time >= 300
		stop
	end
end

def stop
	@ball_speed = @old_speed
	reset_power
end

def drawing
end
