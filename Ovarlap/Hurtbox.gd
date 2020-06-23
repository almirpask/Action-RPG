extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

signal invicibility_started
signal invicibility_ended

onready var timer = $Timer
onready var colisionShape = $CollisionShape2D
func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invicibility_started")
	else:
		emit_signal("invicibility_ended")
	
func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect() -> void:	
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position	


func _on_Timer_timeout() -> void:
	self.invincible = false
	
func _on_Hurtbox_invicibility_started() -> void:
	set_deferred("monitorable", false)
	colisionShape.set_deferred("disable", true)
	
func _on_Hurtbox_invicibility_ended() -> void:	
	monitorable = true
	colisionShape.set_deferred("disable", false)
