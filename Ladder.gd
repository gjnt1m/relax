tool
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var Segments = 0 setget Segments_set, Segments_get
export var Sprite_Index = 0 setget Sprite_Index_set, Sprite_Index_get
	
func Segments_set(value):
	if get_child_count() > 0:
		$DispSprite.region_rect.size.y = stepify(value, 0.1) * 16
		if not $Climbable/Collision.shape:
			var s = RectangleShape2D.new()
			s.extents = Vector2(8, 8)
			$Climbable/Collision.shape = s
		$Climbable/Collision.shape.extents.y = stepify(value, 0.1) * 8

func Segments_get():
	if get_child_count() > 0:
		return $DispSprite.region_rect.size.y / 16
	return 2.0

func Sprite_Index_set(value):
	if get_child_count() > 0:
		$DispSprite.region_rect.position.x = int(value) * 16

func Sprite_Index_get():
	if get_child_count() > 0:
		return $DispSprite.region_rect.position.x / 16
	return 0
	
func _ready():
	pass

func _on_Climbable_body_shape_entered(body_id, body, body_shape, area_shape):
	pass # replace with function body
