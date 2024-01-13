extends CharacterBody2D

enum {
	MOVE,
	ATTACK1,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

const SPEED = 150.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer

var health = 100
var coins = 0

var state = MOVE
var run_speed = 1
var combo = false

func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK1:
			attack1_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	
	if velocity.y > 0:
		animPlayer.play('fall')
	
	if health <= 0:
		health = 0
		animPlayer.play("death")
		await animPlayer.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")
	
	move_and_slide()


func move_state ():
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play('walk')
			else:
				animPlayer.play('run')
		
		if direction == -1:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("idle")
	
	if Input.is_action_pressed("run"):
		run_speed = 2
	else:
		run_speed = 1
	
	if Input.is_action_pressed('block'):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK1

func block_state ():
	velocity.x = 0
	animPlayer.play('block')
	if Input.is_action_just_released('block'):
		state = MOVE

func slide_state ():
	animPlayer.play('slide')
	await animPlayer.animation_finished
	state = MOVE

func attack1_state ():
	if Input.is_action_just_pressed('attack') and combo:
		state = ATTACK2
		
	velocity.x = 0
	animPlayer.play('attack1')
	await animPlayer.animation_finished
	state = MOVE

func attack2_state ():
	if Input.is_action_just_pressed('attack') and combo:
		state = ATTACK3
		
	animPlayer.play('attack2')
	await animPlayer.animation_finished
	state = MOVE

func attack3_state ():
	animPlayer.play('attack3')
	await animPlayer.animation_finished
	state = MOVE

func combo1 ():
	combo = true
	await animPlayer.animation_finished
	combo = false
