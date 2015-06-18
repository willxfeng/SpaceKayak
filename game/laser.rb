# laser.rb
# Laser class
# Author: William Feng
# Last Modified 6/18/2015

class Laser
	attr_reader :x
	attr_reader :y
	attr_reader :xv
	attr_reader :yv

	attr_reader :width
	attr_reader :height
	attr_reader :size

	V = 16 #velocity pixels/frame
	def initialize x, y, rot, angle
		@x, @y, @rot, @angle = x, y, rot, angle
		@img = Gosu::Image.new('images/laser_beam.png')

		@width = @img.width
		@height = @img.height
		@size = 1.2 # size factor
	end

# laser travels in the direction ship faces at time of firing
	def update
		@xv = V * Math.cos(@angle)
		@yv = V * Math.sin(@angle)
		@x += @xv
		@y += @yv
	end

	def draw
		@img.draw_rot(@x, @y, 1, @rot, 0.5, 0.5, @size, @size)
	end

# returns true if laser is off screen
	def offScreen?
		dim = @width + @height
		(@x < -dim) || (@x > (Game::WIDTH+dim)) ||
		(@y < -dim) || (@y > (Game::HEIGHT+dim))
	end
end