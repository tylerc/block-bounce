def start
	@player = @player.zoom([2,1])
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
	@player = @player.zoom([0.5,1])
	reset_power
end

def drawing
end
