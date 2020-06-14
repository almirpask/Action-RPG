extends KinematicBody2D

var knockback = Vector2.ZERO

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	pass
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	knockback = area.knockback_vector * 120	
