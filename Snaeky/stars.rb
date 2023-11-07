require 'gosu'
require 'rubygems'

class Star
    attr_reader :pos_x, :pos_y

    def initialize(layer, max_grid_cell, not_spawn_x, not_spawn_y)
        @layer = layer
        @image = Gosu::Image.new("images/star.png")
        @angle = 0
        @pos_x = spawn_anywhere_but(not_spawn_x, max_grid_cell)
        @pos_y = spawn_anywhere_but(not_spawn_y, max_grid_cell)
    end

    def spawn_anywhere_but(num, max)
        while(true)
            result = rand(1..max)
            if (result != num)
                return result
            end
        end
    end

    def draw(interface_gap, distance)
        true_x = @pos_x * distance + interface_gap
        true_y = @pos_y * distance + interface_gap
        @image.draw_rot(true_x, true_y, @layer, @angle)
        @angle += 1
    end

end