extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	randomize()
	state = pick_random_state([IDLE, WANDER])
func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				pick_and_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				pick_and_wander()

			accelarate_towards_pointd(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				pick_and_wander()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:				
				accelarate_towards_pointd(player.global_position, delta)
			else:
				state = IDLE 
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func pick_and_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))
	

func accelarate_towards_pointd(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward( direction * MAX_SPEED, ACCELERATION * delta )
	sprite.flip_h = velocity.x < 0 
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area: Area2D) -> void:	
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	
	


func _on_Stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position



func _on_Hurtbox_invicibility_started() -> void:
	animationPlayer.play("Start")


func _on_Hurtbox_invicibility_ended() -> void:
	animationPlayer.play("Stop")
