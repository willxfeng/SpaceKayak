class Explosion
	FRAME_DELAY = 40 #ms

	def initialize type
		case type
		when 1
			imgFile = 'images/explosion1.png'
			width, height = 64, 64
			soundFile = 'sounds/explosion1.ogg'
		when 2
			imgFile = 'images/explosion2.png'
			width, height = 64, 64
			soundFile = 'sounds/explosion2.ogg'
		end
		@gif = Gosu::Image::load_tiles(imgFile, width, height)
		@gifsize = @gif.size
		sound = Gosu::Sample.new(soundFile)
		sound.play

		@currentFrame = 0
		@scale = 1.5
	end

	def update
		@currentFrame += 1 if frame_expired?
	end

	def draw x, y
		return if gif_complete?
		img = @gif[@currentFrame % @gif.size]
		img.draw(x-img.width/2.0, y-img.width/2.0, 0, @scale, @scale)
	end

	def gif_complete?
		@currentFrame >= @gifsize
	end

	def frame_expired?
		now = Gosu.milliseconds
		@lastFrame ||= now
		if (now - @lastFrame) > FRAME_DELAY
			@lastFrame = now
		end
	end
end