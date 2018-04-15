
class ObjectImage < Gosu::Image

	class ImageError < StandardError; end
	class NoImageError < ImageError; end

	@@draw_factor = 1
	@@images = {:junction => nil, :road => nil, :car => nil, :background => nil}
	@@images.each_key {|key|
		define_singleton_method("draw_" + key.to_s) {|*args| @@images[key].draw_on_map *args } if key != :background
	}

	def self.init_image(type, filename)
		check_image_exists type
		@@images[type] = self.new(filename) if @@images[type].nil? && !filename.nil?
	end

	def self.draw_image(type, *args)
		check_image_exists type
		send("draw_" + type.to_s, *args)
	end

	def self.get_image(type)
		@@images[type]
	end

	def self.draw_background; @@images[:background].draw(0, 0, 0); end

	def self.set_draw_factor(new_draw_factor)
		if new_draw_factor > 0
			@@draw_factor = new_draw_factor
		else
			Log.warn "draw factor #{new_draw_factor.inspect} is illegal"
		end
	end

	def draw_on_map(x, y, zlayer=1, angle=0)
		draw_rot(ObjectImage.match_to_window(x), ObjectImage.match_to_window(y), zlayer, angle)
	end

	def self.draw_line(start_pos, end_pos, color, layer=1)
		new_start_pos = start_pos.to_a.map {|n| n * @@draw_factor }
		Gosu.draw_line(*match_to_window(start_pos), color, *match_to_window(end_pos), color, layer)
	end

	private
	def self.check_image_exists(type)
		raise NoImageError, "Image #{type.inspect} does not exist" if !@@images.has_key? type
	end

	def self.match_to_window(coordinate)
		if coordinate.respond_to? :to_a
			coordinate.to_a.map {|e| e * @@draw_factor }
		else
			coordinate * @@draw_factor
		end
	end
end
