
class ObjectImage < Gosu::Image

	class ImageError < StandardError; end
	class NoImageError < ImageError; end

	@@media_dir = "."
	@@draw_factor = 1
	@@images = {:junction => nil, :road => nil, :car => nil, :background => nil}
	@@images.each_key {|key|
		define_singleton_method("draw_" + key.to_s) {|*args| @@images[key].draw_on_map *args } if key != :background
	}

	def self.debug_images
		Log.debug @@images.inspect
	end

	def self.set_media_dir(dir_name)
		@@media_dir = dir_name.nil? ? "." : dir_name
	end

	def self.init_image(type, filename)
		check_image_exists type
		image = image_by_type(filename)
		@@images[type] = image  if @@images[type].nil?
		# @@images[type] = self.new(filename) if @@images[type].nil? && !filename.nil?
	end

	def self.draw_image(type, *args)
		check_image_exists type
		send("draw_" + type.to_s, *args)
	end

	def self.get_image(type, index=nil)
		image = @@images[type]
		image.respond_to?(:each) ? image[index] : image
	end

	def self.draw_background; @@images[:background].draw(0, 0, 0); end

	def self.set_draw_factor(new_draw_factor)
		if new_draw_factor > 0
			@@draw_factor = new_draw_factor
		else
			Log.warn "draw factor #{new_draw_factor.inspect} is illegal"
		end
		@@draw_factor
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

	def self.image_by_type(object, level=0)
		a = nil
		if object.is_a?(String)
			a = filename_to_image(object)
		elsif object.is_a?(Hash)
			a = object.transform_values {|v| image_by_type(v, level+1) }
		elsif object.respond_to?(:each)
			a = object.map {|e| image_by_type(e, level+1) }
		else
			a = nil
		end
	end

	def self.filename_to_image(filename)
		return nil  if filename.nil?
		full_name = File.join(@@media_dir, filename)
		self.new(full_name)
	rescue RuntimeError => e
		return nil
	end

	def self.match_to_window(coordinate)
		if coordinate.respond_to? :to_a
			coordinate.to_a.map {|e| e * @@draw_factor }
		else
			coordinate * @@draw_factor
		end
	end
end
