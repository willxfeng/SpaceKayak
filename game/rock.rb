class Rock
	attr_accessor :x
	attr_accessor :y
	attr_accessor :xv
	attr_accessor :yv

	attr_reader :width
	attr_reader :height
	attr_reader :size
	attr_writer :rv

	def initialize
		case rand(5)
		when 0
			@img = Gosu::Image.new('images/asteroid1.png')
		when 1
			@img = Gosu::Image.new('images/asteroid2.png')
		when 2
			@img = Gosu::Image.new('images/asteroid3.png')
		when 3
			@img = Gosu::Image.new('images/asteroid4.png')
		else
			@img = Gosu::Image.new('images/asteroid5.png')
		end

		@width = @img.width
		@height = @img.height

		vMax = 6
		side = rand(4)
		@x = 0
		@y = 0
		@xv = 0
		@yv = 0
		
		case side
		when 0
			@x = rand(Game::WIDTH - @width)
			@y = -@height
			@xv = rand(-vMax..vMax)
			@yv = rand(1..vMax)
		when 1
			@x = rand(Game::WIDTH - @width)
			@y = Game::HEIGHT
			@xv = rand(-vMax..vMax)
			@yv = rand(-vMax..-1)
		when 2
			@x = -@width
			@y = rand(Game::HEIGHT - @height)
			@xv = rand(1..vMax)
			@yv = rand(-vMax..vMax)
		else
			@x = Game::WIDTH
			@y = rand(Game::HEIGHT - @height)
			@xv = rand(-vMax..-1)
			@yv = rand(-vMax..vMax)
		end		
		@rot = 0
		@rv = rand(-15..15)
		@size = 0.2 + rand/1.5
	end

	def draw
		@img.draw_rot(@x, @y, 0, @rot, 0.5, 0.5, @size, @size)
	end

	def update
		@x += @xv
		@y += @yv
		@rot += @rv
	end

	def offScreen?
		(@x < -@width) || (@x > (Game::WIDTH+@width)) ||
		(@y < -@height) || (@y > (Game::HEIGHT+@height))
	end
end