# explosion.rb
# Explosion class
# Author: William Feng
# Last Modified 6/18/2015

class Explosion
	FRAME_DELAY = 40 #amount of time (ms) to hold each frame

	def initialize type, x, y, scale
# input determines gif and sound of explosion
		case type
		when 1
			imgFile = 'images/explosion1.png'
			width, height = 64, 64
			soundFile = 'sounds/explosion1.ogg'
		when 2
			imgFile = 'images/explosion3.png'
			width, height = 64, 64
			soundFile = 'sounds/explosion2.ogg'
		end
		@x,@y = x, y
		@gif = Gosu::Image::load_tiles(imgFile, width, height)
		@gifsize = @gif.size
		@sound = Gosu::Sample.new(soundFile)
		@exploded = false # to make sure sound only plays once

		@currentFrame = 0
		@scale = scale # size factor of explosion
	end

# Move onto next frame when current frame expires
	def update
		@currentFrame += 1 if frame_expired?
	end

	def draw
		return if gif_complete?
# Ensure sound only plays once
		if !@exploded
			@sound.play
			@exploded = true
		end
# Draw gif frame
		img = @gif[@currentFrame % @gif.size]
		img.draw(@x-img.width*@scale/2.0, @y-img.height*@scale/2.0, 0, @scale, @scale)
	end

# Returns true when all frames have been played
	def gif_complete?
		@currentFrame >= @gifsize
	end

# Returns true when ready to move onto next frame
	def frame_expired?
		now = Gosu.milliseconds
		@lastFrame ||= now
		if (now - @lastFrame) > FRAME_DELAY
			@lastFrame = now
		end
	end
end