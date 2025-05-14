extends Node
class_name FurnitureDB

var db: SQLite = SQLite.new()

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("user://")  # Ensure the directory exists
	
	# db = SQLite.new()
	db.path="user://furniture.db"
	var err = db.open_db()
	# var err = db.open("user://furniture.db")
	if err == false:
		push_error("Couldn’t open furniture.db: %s" % err)
		return
	_ensure_table()

func test_add_and_get_furniture():
    var db_node = setup_clean_db()

    db_node.add_furniture("Sofa", 2.0, 1.0, 1.5, "Seating", "res://scenes/sofa.tscn")
    var results = db_node.get_all_furniture()

    assert(results.size() == 1, "Expected one item in the DB")
    var entry = results[0]
    assert(entry["furn_name"] == "Sofa", "Expected name 'Sofa'")
    assert(entry["width"] == 2.0, "Expected width 2.0")
    assert(entry["scene_path"] == "res://scenes/sofa.tscn", "Expected correct scene path")


func _ensure_table() -> void:
	var sql = """
	CREATE TABLE IF NOT EXISTS furniture (
		id          INTEGER PRIMARY KEY AUTOINCREMENT,
		furn_name   TEXT    NOT NULL,
		width       REAL    NOT NULL,
		depth       REAL    NOT NULL,
		height      REAL    NOT NULL,
		type        TEXT,
		scene_path  TEXT    NOT NULL
	);
	"""
	if not db.query(sql):
		push_error("Failed to create furniture table")

func add_furniture(furn_name: String, width: float, depth: float, height: float, type: String, scene_path: String) -> void:
	var sql = "INSERT INTO furniture (furn_name, width, depth, height, type, scene_path) VALUES (?, ?, ?, ?, ?, ?);"
	var values = [furn_name, width, depth, height, type, scene_path]
	
	# Log the values being inserted
	print("Inserting values: %s" % str(values))
	
	var result = db.query_with_bindings(sql, values)
	if not result:
		push_error("Insert failed: %s" % sql)
	else:
		print("Insert successful")

func get_all_furniture() -> Array:
	var out = []
	var sql = "SELECT id, furn_name, width, depth, height, type, scene_path FROM furniture;"
	if not db.query(sql):
		push_error("Query failed or returned nothing")
		return []
	while db.next_row():
		out.append({
			"id":         db.get_column_int(0),
			"furn_name":  db.get_column_text(1),
			"width":      db.get_column_double(2),
			"depth":      db.get_column_double(3),
			"height":     db.get_column_double(4),
			"type":       db.get_column_text(5),
			"scene_path": db.get_column_text(6)
		})
	return out
