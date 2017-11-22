
class Junction < MapObject
	def initialize(pos_x, pos_y, road_n, road_e, road_s, road_w)
		super pos_x, pos_y, :movable => false
		roads = [road_n, road_e, road_s, road_w]
	end
	
	
end
