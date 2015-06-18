# rock.rb
# Rock (asteroid) class
# Author: William Feng
# Last Modified 6/18/2015

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
# Randomize one of five types of asteroids
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

		vMax = 6 # max velocity for randomization
		side = rand(4) # rock can originate from any side of screen
		@x = 0
		@y = 0
		@xv = 0 # x velocity
		@yv = 0 #y velocity
	
# Beginning position and velocity depends on which side rock originates
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
		@rv = rand(-15..15) # random rotation velocity
		@size = 0.2 + rand/1.5 # random size factor
	end

	def draw
		@img.draw_rot(@x, @y, 0, @rot, 0.5, 0.5, @size, @size)
	end

	def update
		@x += @xv
		@y += @yv
		@rot += @rv
	end

# returns true if rock is off screen
	def offScreen?
		dim = @width + @height
		(@x < -dim) || (@x > (Game::WIDTH+dim)) ||
		(@y < -dim) || (@y > (Game::HEIGHT+dim))
	end
end