# kayak.rb
# Kayak (spaceship) class
# Author: William Feng
# Last Modified 6/18/2015

class Kayak
	attr_reader :x
	attr_reader :y
	attr_reader :rot
	attr_reader :angle

	FRAME_DELAY = 40 # amount time (ms) to hold each thruster image

	ACC = 0.1 # ship acceleration (pixels/frame^2) when thrusters on
	VMAX = 14 # ship max velocity (pixels/frame)
	ZONE = 200 # radius (pixles) around ship in which cursor does not move ship
	DEACC = 0.988 # ship deacceleration when thrusters off

	SIZE = 1.25 # ship scale factor
	
	def initialize window
# @gif contains sequence of images for thruster animation
		@gif = []
		@gif << Gosu::Image.new('images/thrusters0_25.png')
		@gif << Gosu::Image.new('images/thrusters0_5.png')
		@gif << Gosu::Image.new('images/thrusters0_75.png')
		@gif << Gosu::Image.new('images/thrusters1.png')
		@gif << Gosu::Image.new('images/thrusters0_75.png')
		@gif << Gosu::Image.new('images/thrusters0_5.png')
# resting image (no thrusters)
		@rest = Gosu::Image.new('images/thrusters0.png')

		@soundThrusters = Gosu::Sample.new('sounds/thrusters.ogg')

		@window = window
		@x = Game::WIDTH/2.0
		@y = Game::HEIGHT/2.0
		@v = 0 # ship velocity (pixels/frame)
		@xv = 0 # ship x velocity
		@yv = 0 # ship y velocity
		@rot = 0

		@xl = 0 # laser flare x location
		@yl = 0 # laser flare y location

		@currentFrame = 0
	end

	def update
# Cursor position relative to ship		
		dx = @window::mouse_x - @x
		dy = @window::mouse_y - @y

		@angle = Math.atan2(dy, dx)
		dist = dx**2 + dy**2 # distance between ship and cursor
		if  dist > ZONE
# Rotate ship to match cursor
			@rot = @angle/Math::PI * 180 + 90
		end

# Update image and acceleration ship when right mouse button held down
		if Gosu::button_down? Gosu::MsRight
			@currentFrame += 1 if frame_expired?
			@inst ||= @soundThrusters.play 1, 1, true
			@inst.resume if !@inst.playing?
			if dist > ZONE
				@img = @gif[@currentFrame % @gif.size]
				if @v < VMAX
					@v += ACC
				end
				@xv = @v * Math.cos(@angle)
				@yv = @v * Math.sin(@angle)
				@x += @xv
				@y += @yv
			else
				@img = @rest
			end
# Update image and deaccelerate ship when RMB released
		else
			@inst.pause if @inst && @inst.playing?
			@img = @rest
			@xv *= DEACC
			@yv *= DEACC
			@v *= DEACC
			@x += @xv
			@y += @yv
		end

# "Bounce" ship back when it hits an edge of the window
		if @x <= @img.width/2.5 || @x >= (Game::WIDTH-@img.width/2.5)
			@xv = -@xv
		end
		if @y <= @img.height/4 || @y >= (Game::HEIGHT-@img.height/4)
			@yv = -@yv
		end
	end

# Draw ship
	def draw
		@img.draw_rot(@x, @y, 1, @rot, 0.5, 0.35, SIZE, SIZE)
	end

# Returns true when reading to move on to next frame in thruster animation
	def frame_expired?
		now = Gosu.milliseconds
		@lastFrame ||= now
		if (now - @lastFrame) > FRAME_DELAY
			@lastFrame = now
		end
	end
end