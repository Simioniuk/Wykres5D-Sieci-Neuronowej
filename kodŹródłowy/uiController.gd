extends Control

@onready var wLabel = $wLabel
@onready var uLabel = $uLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wLabel.text = 'w:'+str(get_parent().get_node('MultiMeshInstance3D').obW)
	uLabel.text = 'u:'+str(get_parent().get_node('MultiMeshInstance3D').obU)
