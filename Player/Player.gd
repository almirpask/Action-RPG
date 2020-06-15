extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500
const ROLL_SPEED = 125
enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitBox = $HitboxPivot/SwordHitBox
func _ready() -> void:
	animationTree.active = true;
	swordHitBox.knockback_vector = roll_vector
	
func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) 
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()

func roll_state(_delta): 
	velocity = roll_vector * ROLL_SPEED	
	move()
	animationState.travel("Roll")
	pass
func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
	pass
	
func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity / 2
	state  = MOVE
		
func attack_animation_finished():
	state = MOVE
