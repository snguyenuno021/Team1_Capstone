extends MeshInstance3D

var room_height := 5.0
#var cam: Camera3D
var xr_origin: XROrigin3D
# var light: DirectionalLight3D
var edge_container: Node3D

func _ready():
#	get_viewport().use_xr = true ## BUG: causes errors
	_visualize()
	
	# Connect to UI
	var ui_node = get_node_or_null("../../Control")
	if ui_node:
		ui_node.connect("sides_input", _on_sides_input)
	else:
		print("UI node not found. Please check the node path.")

func _visualize():
	# Add VR capabilities
	xr_origin = XROrigin3D.new()
	var headset = XRCamera3D.new()
	headset.current = true
	xr_origin.add_child(headset)
	call_deferred("add_child", xr_origin)
	
	edge_container = Node3D.new()
	edge_container.name = "EdgeContainer"
	call_deferred("add_child", edge_container)
	
	## Add camera
	#cam = Camera3D.new()
	#cam.position = Vector3(15, 10, 20)
	#cam.look_at_from_position(cam.position, Vector3(5, 2.5, 5))
	#cam.current = true
	#call_deferred("add_child", cam)
	
	# Add light
	# light = DirectionalLight3D.new()
	# light.rotation = Vector3(deg_to_rad(-45), deg_to_rad(45), 0)
	# call_deferred("add_child", light)

func _on_sides_input(side_lengths):
	if side_lengths.size() < 2:
		print("Need both length and width.")
		return
		
	var length = side_lengths[0]
	var width = side_lengths[1]
	
	var center_x = length/2
	var center_y = width/2

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
	
	draw_3d_outline(corners, room_height)
	_position_camera(center_x, center_y, room_height)

func _position_camera(center_x, center_y, height):
	xr_origin.global_transform.origin = Vector3(center_x, height - 3, center_y)
	
	#if cam == null:
		#cam = Camera3D.new()
		#cam.current = true
		#call_deferred("add_child", cam)
	#
	#cam.position = Vector3(center_x, height - 3, center_y)
	#cam.look_at_from_position(cam.position, Vector3(0, 0, center_y))
	
	# light.shadow_enabled = false
	# light.global_transform.basis = cam.global_transform.basis

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
	
	var mesh_data = surface_tool.commit()
	var mesh_tool = MeshDataTool.new()
	mesh_tool.create_from_surface(mesh_data, 0)
	
	for i in range(mesh_tool.get_face_count()):
		var normal = mesh_tool.get_face_normal(i)
		for j in range(3):
			mesh_tool.set_vertex_normal(i * 3 + j, normal)
	
	# surface_tool.generate_normals()
	# return surface_tool.commit()
	return mesh_data
	
#func draw_outline(corners, height):
	#var immediate_mesh := ImmediateMesh.new()
	#var mat := StandardMaterial3D.new()
	#mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#mat.albedo_color = Color(0, 0, 0)
#
	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	#
	#var num_points = corners.size()
	#for i in range(num_points):
		#var next_i = (i + 1) % num_points
		#
		#var p1 = Vector3(corners[i].x, 0, corners[i].y)
		#var p2 = Vector3(corners[next_i].x, 0, corners[next_i].y)
		#var p3 = Vector3(corners[i].x, height, corners[i].y)
		#var p4 = Vector3(corners[next_i].x, height, corners[next_i].y)
		#
		## Bottom edges
		#immediate_mesh.surface_add_vertex(p1)
		#immediate_mesh.surface_add_vertex(p2)
		#
		## Top edges
		#immediate_mesh.surface_add_vertex(p3)
		#immediate_mesh.surface_add_vertex(p4)
		#
		## Vertical edges
		#immediate_mesh.surface_add_vertex(p1)
		#immediate_mesh.surface_add_vertex(p3)
#
	#immediate_mesh.surface_end()
	#
	#var mesh_instance := MeshInstance3D.new()
	#mesh_instance.mesh = immediate_mesh
	#call_deferred("add_child", mesh_instance)

# Use thin 3D boxes to simulate thick edges
func draw_3d_outline(corners, height):
	# Clear old edges
	for child in edge_container.get_children():
		child.queue_free()
	
	var edge_thickness = 0.05
	var edge_mat := StandardMaterial3D.new()
	edge_mat.albedo_color = Color(1, 1, 1)

	for i in range(corners.size()):
		var next_i = (i + 1) % corners.size()

		var base1 = Vector3(corners[i].x, 0, corners[i].y)
		var base2 = Vector3(corners[next_i].x, 0, corners[next_i].y)
		var top1 = base1 + Vector3(0, height, 0)
		var top2 = base2 + Vector3(0, height, 0)

		# Bottom edge
		_create_edge_segment(base1, base2, edge_thickness, edge_mat)
		# Top edge
		_create_edge_segment(top1, top2, edge_thickness, edge_mat)
		# Vertical edge 1
		_create_edge_segment(base1, top1, edge_thickness, edge_mat)

func _create_edge_segment(start: Vector3, end: Vector3, thickness: float, mat: Material):
	var dir = end - start
	var length = dir.length()
	var center = start + dir * 0.5

	var up = Vector3.UP
	if abs(dir.normalized().dot(up)) > 0.999:
		up = Vector3.FORWARD

	var bs = Basis.looking_at(dir.normalized(), up)
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(thickness, thickness, length)

	var edge_instance := MeshInstance3D.new()
	edge_instance.mesh = box_mesh
	edge_instance.material_override = mat
	edge_instance.transform = Transform3D(bs, center)

	# Add to container
	call_deferred("_add_child_to_edge_container", edge_instance)

func _add_child_to_edge_container(child: Node3D):
	if edge_container:
		edge_container.add_child(child)
