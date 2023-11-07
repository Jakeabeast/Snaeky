require 'gosu'
require 'rubygems'

class Button
    attr_accessor :direction #*** SUBSTITUE FOR ALL GETTERS AND SETTERS IN ALL CLASSES
    
    def initialize(starting_direction)
        @image_arrow = Gosu::Image.new("images/arrow.png")
        @image_arrow_selected = Gosu::Image.new("images/arrowPressed.png")
        @direction = Gosu::KB_UP
        @angle = 0
        rotate(starting_direction)
    end

    def get_direction()
        return @direction
    end
    
    def rotate(new_direction)
        if (new_direction == Gosu::KB_UP)
            @angle = 0
        elsif (new_direction == Gosu::KB_RIGHT)
            @angle = 90
        elsif (new_direction == Gosu::KB_DOWN)
            @angle = 180
        elsif (new_direction == Gosu::KB_LEFT)
            @angle = 270
        else 
            puts "ERROR: Invalid Direction"
        end
        @direction = new_direction
    end

    def draw(action, pos_x, pos_y, length, layer)
        if (action == @direction)
            @image_arrow_selected.draw_rot(pos_x + length/2, pos_y + length/2, layer, @angle)
        else
            @image_arrow.draw_rot(pos_x + length/2, pos_y + length/2, layer, @angle)
        end
    end
end
