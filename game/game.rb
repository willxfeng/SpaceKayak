# game.rb
# Main program of the Space Kayak game
# Author: William Feng
# Last Modified 6/18/2015

require 'gosu'
require './kayak'
require './rock'
require './explosion'
require './laser'

class Game < Gosu::Window
	WIDTH = (Gosu.screen_width * 1.25).floor
	HEIGHT = (Gosu.screen_height * 1.25).floor
  
  FIRING_PERIOD = 280 # period (ms) between successive laser blasts
  FIRING_DURATION = FIRING_PERIOD / 2 # duration (ms) over which the blast flares display
  SIZEL = 1.5 # size factor of laser flare
  DIST = 20 # distance of laser flare from center of ship

  def initialize
    super WIDTH, HEIGHT, true
    self.caption = "Space Kayak!"
    @background = Gosu::Image.new('images/space_bg.jpg')
    @by = -@background.height + HEIGHT
    @bgspeed = 1
    @kayak = Kayak.new self
    @cursor = Gosu::Image.new('images/crosshair.png')

    @rockSpawnRate = 0.04 # rate at which new asteroids spawn
    @rock = [] 

    @explosion = []

    @laser = []

    @bgMusic = Gosu::Song.new('sounds/bg_music.ogg')
    @bgMusic.play true

    @laserFlare = Gosu::Image.new('images/laser_flare.png')
    @soundLaser = Gosu::Sample.new('sounds/pew.ogg')

    @cleanup = 30 # number of frams after which object cleanup is performed
    @count = 0 # count frames up to cleanup time
    @collided = [] # array of recently collided pairs

    @fireLaser = true # ready to create laser object
    @laserSoundPlaying = false # to make sure laser sound only plays once per blast

    @xl = 0 # starting x position for laser
    @yl = 0 # stariting y position for laser
  end

  def update
# End game
    if Gosu::button_down? Gosu::KbEscape
      self.close
    end

# Move/Loop background image
    if @by > 0 
      @by = -@background.height + HEIGHT
    else
      @by += @bgspeed
    end

    @kayak.update

# Create laser and determine laser flare position
    if Gosu::button_down? Gosu::MsLeft
      @startFiring ||= Gosu::milliseconds
      @xl = @kayak.x + DIST*Math.cos(@kayak.angle)
      @yl = @kayak.y + DIST*Math.sin(@kayak.angle)

      if showLaserFlare?
        if @fireLaser
          @laser.push Laser.new @xl, @yl, @kayak.rot, @kayak.angle
          @fireLaser = false
        end
      else
        @fireLaser = true
      end
    else
# Reset conditions
      @startFiring = nil
      @fireLaser = true
    end

# Create rock (asteroid) object
    if rand < @rockSpawnRate
      @rock << Rock.new
    end    

# Update rock positons and check for collisions
    for i in 0..@rock.size-1
      ri = @rock[i]
      ri.update
# Rock-on-rock collision      
      for j in i+1..@rock.size-1
        rj = @rock[j]
        if can_collide? ri, rj
          if collide? ri, rj
# Velocity after collision determined by conservation of momentum and conservation of kinetic energy
            mi = ((ri.width+ri.height)/2*ri.size)**3
            mj = ((rj.width+rj.height)/2*rj.size)**3

            xvi = ri.xv
            xvj = rj.xv
            yvi = ri.yv
            yvj = rj.yv

            ri.xv = ((mi-mj)*xvi + 2*mj*xvj)/(mi+mj)
            rj.xv = (2*mi*xvi - (mi-mj)*xvj)/(mi+mj)

            ri.yv = ((mi-mj)*yvi + 2*mj*yvj)/(mi+mj)
            rj.yv = (2*mi*yvi - (mi-mj)*yvj)/(mi+mj)

            ri.rv = rand(-15..15)
            rj.rv = rand(-15..15)
            @collided << [ri, rj]

# Determine location of collision animation
            midx = (ri.x+rj.x) / 2.0
            midy = (ri.y+rj.y) / 2.0
            scale = [ri.size, rj.size].min * 5
            @explosion.push Explosion.new 1, midx, midy, scale
          end
        end
      end

# Rock-on-laser collision
      @laser.each do |l|
        if collide? ri, l
          @explosion.push Explosion.new 2, l.x, l.y, 2.5
# Laser "pushes" rock in the direction laser was travelling in
# How hard this push is is inversely proportional to rock size
          if l.xv && l.yv
            ri.xv = ri.xv + l.xv/(ri.size*4)
            ri.yv = ri.yv + l.yv/(ri.size*4)
          end
          @laser.delete(l)
        end
      end
    end

# Update explosion animations
    @explosion.each do |e|
      e.update
    end

# Update laser movements
    @laser.each do |l|
      l.update
    end

# Clean up expired or offscreen objects every @cleanup frames
    if @count >= @cleanup

      @rock.each do |r|
        @rock.delete(r) if r.offScreen?
        @collided.shift(@collided.size/2)
      end

      @explosion.each do |e|
        @explosion.delete(e) if e.gif_complete?
      end

      @laser.each do |l|
        @laser.delete(l) if l.offScreen?
      end
      @count = 0
    else
      @count += 1
    end
  end

# Draw existing objects
  def draw
    @background.draw(0, @by, -1)
    @kayak.draw

    @cursor.draw(self.mouse_x-@cursor.width/2.0, self.mouse_y-@cursor.height/2.0, 2)

    @rock.each do |r|
      r.draw
    end
    
    @explosion.each do |e|
      e.draw
    end

    if showLaserFlare?
      @laserFlare.draw_rot(@xl, @yl, 1, @kayak.rot, 0.5, 0.5, SIZEL, SIZEL)
      if !@laserSoundPlaying
        @soundLaser.play
        @laserSoundPlaying = true
      end
    else
      @laserSoundPlaying = false
    end

    @laser.each do |l|
      l.draw
    end
  end

# Returns true if 2 objects exist, are on screen, and their centers are closer than a function of their dimensions
  def collide? obj1, obj2
    obj1 && obj2 && obj1.x>0 && obj1.x<WIDTH && obj1.y> 0 && obj1.y<HEIGHT &&
    obj2.x>0 && obj2.x<WIDTH && obj2.y> 0 && obj2.y<HEIGHT &&
    (obj1.x-obj2.x)**2 + (obj1.y-obj2.y)**2 <
    ((obj1.width+obj1.height)*obj1.size/4.0 + 
      (obj2.width+obj2.height)*obj2.size/4.0)**2
  end

# Returns true if the 2 objects have not recently collided
# Used to prevent "vibrating" effect when collide? condition remains satisfied for more than 1 frame
  def can_collide? obj1, obj2
    !@collided.include? [obj1, obj2]
  end

# Returns true if the laser flare should be shown
  def showLaserFlare?
    @startFiring &&
    (Gosu::milliseconds-@startFiring)%FIRING_PERIOD < FIRING_DURATION
  end
end

window = Game.new
window.show