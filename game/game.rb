require 'gosu'
require './kayak'
require './rock'
require './explosion'

class Game < Gosu::Window
	WIDTH = 1920
	HEIGHT = 1080
  
  def initialize
    super WIDTH, HEIGHT, true
    self.caption = "Space Kayak!"
    @background = Gosu::Image.new('images/space_bg.jpg')
    @by = -@background.height + HEIGHT
    @bgspeed = 1
    @kayak = Kayak.new self
    @cursor = Gosu::Image.new('images/crosshair.png')

    @rockSpawnRate = 0.1
    @rock = []

    @bgMusic = Gosu::Sample.new('sounds/bg_music.ogg')
    @bgMusic.play 1, 1, true

    @explode = false
    @explosion = Explosion.new 1

    @cleanup = 60 * 1 #frames
    @count = 0
    @collided = []
  end

  def update
    if Gosu::button_down? Gosu::KbEscape
      self.close
    end

    if @by > 0 
      @by = -@background.height + HEIGHT
    else
      @by += @bgspeed
    end

    @kayak.update

    if rand < @rockSpawnRate
      @rock << Rock.new
    end    

    for i in 0..@rock.size-1
      ri = @rock[i]
      ri.update
      for j in i+1..@rock.size-1
        rj = @rock[j]
        if can_collide? ri, rj
          if collide? ri, rj
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
            @collided << [ri, rj];
          end
        end
      end
    end

    if Gosu.milliseconds > 2000
      @explode = true
      @explosion.update
    end

    if @count >= @cleanup
      @rock.each do |r|
        @rock.delete(r) if r.offScreen?
        @collided.shift(@collided.size/2)
      end
      @count = 0
    else
      @count += 1
    end

    # @explode = 1
    # @explosion = Explosion.new WIDTH/2.0, HEIGHT/2.0, 1
  end

  def draw
    @background.draw(0, @by, -1)
    @kayak.draw
    @cursor.draw(self.mouse_x-@cursor.width/2.0, self.mouse_y-@cursor.height/2.0, 2)
    @rock.each do |r|
      r.draw
    end

    # if @explode == 1
    #   @explosion.draw
    #   @count = 1
    #   @explode = 0
    # end
    if @explode
      @explosion.draw WIDTH/2, HEIGHT/2
    end
  end

  def collide? obj1, obj2
    obj1.x>0 && obj1.x<WIDTH && obj1.y> 0 && obj1.y<HEIGHT &&
    obj2.x>0 && obj2.x<WIDTH && obj2.y> 0 && obj2.y<HEIGHT &&
    (obj1.x-obj2.x)**2 + (obj1.y-obj2.y)**2 <
    ((obj1.width+obj1.height)*obj1.size/4.0 + 
      (obj2.width+obj2.height)*obj2.size/4.0)**2
  end

  def can_collide? obj1, obj2
    !@collided.include? [obj1, obj2]
  end
end

window = Game.new
window.show