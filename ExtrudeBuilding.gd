extends MeshInstance3D

var room_height = 5.0

func _ready():
	# Connect to UI
	var ui_node = get_node_or_null("../../Control")
	if ui_node:
		ui_node.connect("sides_input", _on_sides_input)
	else:
		print("UI node not found. Please check the node path.")

	_visualize()

func _visualize():
	# Add camera
	var cam = Camera3D.new()
	cam.position = Vector3(15, 10, 20)
	cam.look_at_from_position(cam.position, Vector3(5, 2.5, 5), Vector3.UP)
	cam.current = true
	call_deferred("add_child", cam)
	
	# Add light
	var light = DirectionalLight3D.new()
	light.rotation = Vector3(deg_to_rad(-45), deg_to_rad(45), 0)
	call_deferred("add_child", light)

func _on_sides_input(side_lengths):
	if side_lengths.size() < 2:
		print("Need both length and width.")
		return
		
	var length = side_lengths[0]
	var width = side_lengths[1]

	var corners = [
		Vector2(0, 0),
		Vector2(length, 0),
		Vector2(length, width),
		Vector2(0, width),
	]

	var gen_mesh = extrude(corners, room_height)
	self.mesh = gen_mesh

	# Add material for visibility
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.4, 0.4)
	# Temporarily disable culling if faces appear reversed:
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0, mat)

# Creates side walls and top/bottom caps
func extrude(points, ext_height):
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var num_points = points.size()
	for i in range(num_points):
		var next_point = (i + 1) % num_points
		var p1 = points[i]
		var p2 = points[next_point]
		
		var b1 = Vector3(p1.x, 0, p1.y)
		var b2 = Vector3(p2.x, 0, p2.y)
		var t1 = Vector3(p1.x, ext_height, p1.y)
		var t2 = Vector3(p2.x, ext_height, p2.y)
		
		# Side face (2 triangles)
		surface_tool.add_vertex(b1)
		surface_tool.add_vertex(b2)
		surface_tool.add_vertex(t2)
		
		surface_tool.add_vertex(b1)
		surface_tool.add_vertex(t2)
		surface_tool.add_vertex(t1)
	
	# Top cap
	var top_points = []
	for p in points:
		top_points.append(Vector3(p.x, ext_height, p.y))
	
	var tris = Geometry2D.triangulate_polygon(points)
	for i in range(0, tris.size(), 3):
		surface_tool.add_vertex(top_points[tris[i]])
		surface_tool.add_vertex(top_points[tris[i + 1]])
		surface_tool.add_vertex(top_points[tris[i + 2]])
		
	# Bottom cap
	var bottom_points = []
	for p in points:
		bottom_points.append(Vector3(p.x, 0, p.y))
	
	for i in range(0, tris.size(), 3):
		surface_tool.add_vertex(bottom_points[tris[i]])
		surface_tool.add_vertex(bottom_points[tris[i + 1]])
		surface_tool.add_vertex(bottom_points[tris[i + 2]])
	
	surface_tool.generate_normals()
	return surface_tool.commit()
