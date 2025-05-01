extends Node
class_name FurnitureDB

var db: SQLite

func _ready() -> void:
    db = SQLite.new()
    var err = db.open("user://furniture.db")
    if err != OK:
        push_error("Couldn’t open furniture.db: %s" % err)
        return
    _ensure_table()

func _ensure_table() -> void:
    var sql = """
    CREATE TABLE IF NOT EXISTS furniture (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        width       REAL    NOT NULL,
        depth       REAL    NOT NULL,
        height      REAL    NOT NULL,
        type        TEXT,
        scene_path  TEXT    NOT NULL
    );
    """
    if db.execute(sql) != OK:
        push_error("Failed to create furniture table")

func add_furniture(name:String, width:float, depth:float, height:float, type:String, scene_path:String) -> void:
    var stmt = db.prepare("INSERT INTO furniture (name,width,depth,height,type,scene_path) VALUES (?,?,?,?,?,?);")
    stmt.bind_parameter(1, name)
    stmt.bind_parameter(2, width)
    stmt.bind_parameter(3, depth)
    stmt.bind_parameter(4, height)
    stmt.bind_parameter(5, type)
    stmt.bind_parameter(6, scene_path)
    if stmt.step() != SQLite.RESULT_DONE:
        push_error("Insert failed")
    stmt.reset()

func get_all_furniture() -> Array:
    var out = []
    var q = db.prepare("SELECT id,name,width,depth,height,type,scene_path FROM furniture;")
    while q.step() == SQLite.RESULT_ROW:
        out.append({
            "id":         q.get_column_int(0),
            "name":       q.get_column_text(1),
            "width":      q.get_column_double(2),
            "depth":      q.get_column_double(3),
            "height":     q.get_column_double(4),
            "type":       q.get_column_text(5),
            "scene_path": q.get_column_text(6)
        })
    q.reset()
    return out
