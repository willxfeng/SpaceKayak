class Kayak
	attr_reader :x
	attr_reader :y
	
	def initialize window
		@img = Gosu::Image.new('images/spaceship2.png')

		@window = window
		@x = Game::WIDTH/2.0
		@y = Game::HEIGHT/2.0
		@v = 0
		@xv = 0
		@yv = 0
		@rot = 0
		@acc = 0.2
		@deacc = 0.988
		@vMax = 15
		@zone = 200
		@size = 1.25
	end

	def draw
		@img.draw_rot(@x, @y, 1, @rot, 0.5, 0.35, @size, @size)
	end

	def update
		dx = @window::mouse_x - @x
		dy = @window::mouse_y - @y

		angle = Math.atan2(dy, dx)
		dist = dx**2 + dy**2
		if  dist > @zone
			@rot = angle/Math::PI * 180 + 90
		end

		if Gosu::button_down? Gosu::MsRight
			if dist > @zone
				@img = Gosu::Image.new('images/thrusters2.png')
				if @v < @vMax
					@v += @acc
				end
				@xv = @v * Math.cos(angle)
				@yv = @v * Math.sin(angle)
				@x += @xv
				@y += @yv
			else
				@img = Gosu::Image.new('images/spaceship2.png')
			end
		else
			@img = Gosu::Image.new('images/spaceship2.png')
			@xv *= @deacc
			@yv *= @deacc
			@v *= @deacc
			@x += @xv
			@y += @yv
		end

		if @x <= @img.width/2.5 || @x >= (Game::WIDTH-@img.width/2.5)
			@xv = -@xv
		end
		if @y <= @img.height/4 || @y >= (Game::HEIGHT-@img.height/4)
			@yv = -@yv
		end
	end
end