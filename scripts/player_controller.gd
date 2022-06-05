extends KinematicBody2D
class_name Player

onready var camera: Camera2D = get_node("./../../Camera")

onready var left_wall_cast: RayCast2D = get_node("LeftWallCast")
onready var left_wall_cast2: RayCast2D = get_node("LeftWallCast2")
onready var right_wall_cast: RayCast2D = get_node("RightWallCast")
onready var right_wall_cast2: RayCast2D = get_node("RightWallCast2")

onready var sprite: AnimatedSprite = get_node("Sprite")
onready var effects_player: AnimationPlayer = get_node("EffectsAnimation")
onready var hit_box: CollisionShape2D = get_node("HitBox/CollisionShape2D")

onready var walk_particles: CPUParticles2D = get_node("Particles/WalkParticles")
onready var slide_particles: CPUParticles2D = get_node("Particles/SlideParticles")
onready var land_particles: CPUParticles2D = get_node("Particles/LandParticles")

onready var audio_jump: AudioStreamPlayer = get_node("Audio/Jump")
onready var audio_land: AudioStreamPlayer = get_node("Audio/Land")
onready var audio_hurt: AudioStreamPlayer = get_node("Audio/Hurt")
onready var audio_roll: AudioStreamPlayer = get_node("Audio/Roll")
onready var audio_dead: AudioStreamPlayer = get_node("Audio/Dead")


var player_index: int = 0
var skin_index: int = 0
var spawn_pos: Vector2 = Vector2.ZERO

var velocity: Vector2 = Vector2.ZERO
var previous_velocity: Vector2 = Vector2.ZERO
var snap: Vector2 = Vector2.ZERO
var input_movement: float = 0
var input_dive: bool = 0

var damage: int = 1
var max_health: int = 3
var health: int = max_health
var invincibility_timer: int = 0
var invincibility_time: int = 45

var move_speed: int = 205
var acceleration: int = 85
var deceleration: int = 45
var acceleration_air: int = 30
var deceleration_air: int = 10

var gravity: int = 24
var max_fall_speed: int = 450

var jump_speed: int = 440
var jumps_amount: int = 1
var jumps_available: int = 0
var jump_input_time: int = 6
var jump_input_timer: int = 0
var just_jumped_timer: int = 0
var just_jumped_time: int = 120
var variable_jump_timer: int = 0
var variable_jump_time: int = 10

var coyote_time: int = 6
var coyote_timer: int = 0
var coyote: bool = false

var on_wall_left: bool = false
var on_wall_right: bool = false
var wall_slide_speed: int = 40
var wall_jump_speed: Vector2 = Vector2(370, 400)
var wall_slide_time: int = 6
var wall_slide_timer: int = 0

var rolls_amount: int = 1
var rolls_avaialable: int = 0
var roll_speed: int = 280
var roll_direction: int = 0
var deceleration_roll: int = 2
var gravity_roll: int = 10
var roll_timer: int = 0
var roll_time: int = 15
var roll_buffer_time: int = 0
var roll_buffer_timer: int = 40

enum STATE {
	GROUND
	AIR
	WALL
	ROLL
	HURT
	DEAD
	SPAWN
	PAUSE
}
var state_dictionary = {
	0 : ["GROUND", 'state_ground'],
	1 : ["AIR", 'state_air'],
	2 : ["WALL", 'state_wall'],
	3 : ["ROLL", 'state_roll'],
	4 : ["HURT", 'state_hurt'],
	5 : ["DEAD", 'state_dead'],
	6 : ["SPAWN", 'state_spawn'],
	7 : ["PAUSE", 'state_pause']
}
var state: int = STATE.SPAWN
var prev_state: int  = STATE.SPAWN


func set_state(new_state: int) -> void:
	prev_state = state 
	state = new_state
	print(state_dictionary.get(state)[0])
	
	if (state == STATE.GROUND):
		land_particles.emitting = true
		global.play_audio(audio_land, 1, -0.1, 0.1)


func _ready():
	global_position = spawn_pos
	sprite.set_material(sprite.get_material().duplicate(true))
	sprite.material.set_shader_param("row", skin_index)


func _physics_process(delta):
	update_input()
	update_raycasts()
	update_health()
	call(state_dictionary.get(state)[1], delta)
	var _d = move_and_slide_with_snap(velocity, snap, Vector2.UP)


enum CONTROLS {
	LEFT_STICK = 0
	JUMP = 0
	ROLL = 7
}
var axis_deadzone: float = 0.1
var just_pressed_jump: bool = false
var just_pressed_dive: bool = false

func update_input() -> void:
	input_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if (Input.is_action_just_pressed("jump")):
		jump_input_timer = jump_input_time
	
	var _input = Input.get_joy_axis(player_index, CONTROLS.LEFT_STICK)
	if (abs(_input) > axis_deadzone):
		input_movement = ceil(Input.get_joy_axis(player_index, CONTROLS.LEFT_STICK))
	
	if (Input.is_joy_button_pressed(player_index, CONTROLS.JUMP)):
		if (just_pressed_jump == false):
			just_pressed_jump = true
			jump_input_timer = jump_input_time
	else:
		just_pressed_jump = false
	
	if (Input.is_joy_button_pressed(player_index, CONTROLS.ROLL)):
		if (just_pressed_dive == false):
			just_pressed_dive = true
			input_dive = true
		else:
			input_dive = false
	else:
		just_pressed_dive = false
		input_dive = false
	
	# JUMP BUFFER
	if (jump_input_timer > 0):
		jump_input_timer -= 1
	else: 
		jump_input_timer = 0


func update_raycasts() -> void:
	on_wall_left = (left_wall_cast.is_colliding() or left_wall_cast2.is_colliding()) and !is_on_floor()
	on_wall_right = (right_wall_cast.is_colliding() or right_wall_cast2.is_colliding()) and !is_on_floor()


func update_health() -> void:
	if (invincibility_timer > 0):
		invincibility_timer -= 1
		effects_player.play("invincible")
	else:
		invincibility_timer = 0
		effects_player.play("normal")


func pause() -> void:
	if (state == STATE.PAUSE):
		velocity = previous_velocity
		set_state(prev_state)
	else:
		previous_velocity = velocity
		set_state(STATE.PAUSE)


func state_pause(_delta) -> void:
	velocity = Vector2.ZERO


func state_spawn(_delta) -> void:
	global_position = spawn_pos
	sprite.play("appear", false)
	effects_player.play("normal")
	invincibility_timer = invincibility_time
	health = max_health
	velocity = Vector2.ZERO
	
	
	if (sprite.frame == 7):
		invincibility_timer = 0
		if (is_on_floor()):
			set_state(STATE.GROUND)
			snap = Vector2.DOWN
		else:
			set_state(STATE.AIR)
			snap = Vector2.ZERO


func state_ground(_delta) -> void:
	#X-AXIS
	if (input_movement != 0):
		velocity.x = move_toward(velocity.x, move_speed * input_movement, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
	
	if (velocity.x == 0):
		sprite.play("idle")
		walk_particles.emitting = false
	else:
		sprite.play("run")
		walk_particles.emitting = true
	
	if (velocity.x != 0):
		sprite.flip_h = velocity.x < 0
	
	land_particles.emitting = false
	rolls_avaialable = rolls_amount
	snap = Vector2.DOWN
	coyote_timer = coyote_time
	jumps_available = jumps_amount
	coyote = true
	
	if (is_on_wall()):
		velocity.x = 0
	
	if (!is_on_floor()):
		snap = Vector2.ZERO
		walk_particles.emitting = false
		set_state(STATE.AIR)
	
	enter_roll()
	
	# STANDARD JUMPING
	if (jump_input_timer > 0 && jumps_available > 0):
		global.play_audio(audio_jump, 0.9, -0.2, 0.2)
		snap = Vector2.ZERO
		velocity.y = -jump_speed
		jump_input_timer = 0
		if (coyote_timer >= 0):
			coyote = false
		jumps_available -= 1
		variable_jump_timer = variable_jump_time
		walk_particles.emitting = false
		set_state(STATE.AIR)


func state_air(_delta) -> void:
	#X-AXIS
	if (input_movement != 0):
		velocity.x = move_toward(velocity.x, move_speed * input_movement, acceleration_air)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration_air)
	
	if (is_on_wall()):
		velocity.x = 0
	
	#Y-AXIS
	if (is_on_floor() && snap == Vector2.ZERO):
		velocity.y = 0
		set_state(STATE.GROUND)
	
	
	coyote_timer -= 1
	if (coyote_timer <= 0 && coyote):
		jumps_available -= 1
		coyote = false
	
	# APPLY AND CLAMP GRAVITY
	velocity.y = clamp(velocity.y + gravity, -100000, max_fall_speed)
	
	if (is_on_ceiling()):
		velocity.y = 1
	
	if (velocity.y > 0):
		sprite.play("fall")
	else:
		sprite.play("jump")
	
	if (velocity.x != 0):
		sprite.flip_h = velocity.x < 0
	
	# STANDARD JUMPING
	if (jump_input_timer > 0):
		if (jumps_available > 0):
			global.play_audio(audio_jump, 0.9, -0.2, 0.2)
			
			snap = Vector2.ZERO
			velocity.y = -jump_speed
			jump_input_timer = 0
			
			if (coyote_timer >= 0):
				coyote = false
			
			variable_jump_timer = variable_jump_time
			jumps_available -= 1
	
	# VARIABLE JUMP HEIGHT
	variable_jump_timer -= 1
	if (variable_jump_timer > 0):
		if (velocity.y < 0 && !Input.is_joy_button_pressed(player_index, CONTROLS.JUMP)):
			velocity.y = velocity.y/1.2
	
	enter_roll()
	
	# WALL STATE
	if (on_wall_left and input_movement < 0):
		velocity.x = 0
		set_state(STATE.WALL)
	if (on_wall_right and input_movement > 0):
		velocity.x = 0
		set_state(STATE.WALL)


func state_wall(_delta) -> void:
	#X-AXIS
	if (input_movement != 0):
		velocity.x = move_toward(velocity.x, move_speed * input_movement, acceleration_air)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration_air)
	
	#Y-AXIS
	if (is_on_floor() && snap == Vector2.ZERO):
		velocity.y = 0
		slide_particles.emitting = false
		set_state(STATE.GROUND)
	
	sprite.play("wall slide")
	sprite.flip_h = on_wall_left
	
	slide_particles.emitting = true
	if (sprite.flip_h):
		slide_particles.position.x = -8
	else:
		slide_particles.position.x = 8
	
	
	# APPLY AND CLAMP GRAVITY
	velocity.y = clamp(velocity.y + gravity, -100000, wall_slide_speed)
	
	# WALL JUMPING
	if (jump_input_timer > 0):
		global.play_audio(audio_jump, 0.9, -0.2, 0.2)
		
		snap = Vector2.ZERO
		
		if (on_wall_left):
			velocity.x = wall_jump_speed.x
		else:
			velocity.x = -wall_jump_speed.x
		
		velocity.y = -wall_jump_speed.y
		jump_input_timer = 0
		slide_particles.emitting = false
		set_state(STATE.AIR)
	
	wall_slide_timer -= 1
	if (on_wall_left and input_movement < 0):
		wall_slide_timer = wall_slide_time
	if (on_wall_right and input_movement > 0):
		wall_slide_timer = wall_slide_time
	
	if (wall_slide_timer <= 0):
		wall_slide_timer = 0
		slide_particles.emitting = false
		set_state(STATE.AIR)


func enter_roll() -> void:
	if (roll_buffer_timer > 0):
		roll_buffer_timer -= 1
	else:
		roll_buffer_timer = 0
	
	if (input_dive && rolls_avaialable > 0 && roll_buffer_timer <= 0):
		if (input_movement == 0):
			if (sprite.flip_h):
				roll_direction = -1
			else:
				roll_direction = 1
		else:
			roll_direction = int(input_movement) 
		rolls_avaialable -= 1
		roll_timer = roll_time
		velocity.x = roll_speed * roll_direction
		velocity.y = clamp(velocity.y, -100000, 0)
		walk_particles.emitting = false
		global.play_audio(audio_roll, 1, -0.1, 0.1)
		camera.set_screenshake(Vector2(2,2), 3)
		set_state(STATE.ROLL)


func state_roll(_delta) -> void:
	#X-AXIS
	velocity.x = move_toward(velocity.x, 0, deceleration_roll)
	
	if (is_on_wall()):
		velocity.x = 0
	if (is_on_ceiling()):
		velocity.y = 1
	
	#Y-AXIS
	roll_timer -= 1
	if (roll_timer <= 0):
		roll_buffer_timer = roll_buffer_time
		
		if (is_on_floor()):
			snap = Vector2.DOWN
			velocity.y = 0
			set_state(STATE.GROUND)
		else:
			snap = Vector2.ZERO
			set_state(STATE.AIR)
	
	# APPLY AND CLAMP GRAVITY
	velocity.y = clamp(velocity.y + gravity_roll, -150, max_fall_speed)
	
	sprite.play("flip")
	sprite.flip_h = velocity.x < 0


func state_hurt(_delta) -> void:
	velocity = Vector2.ZERO
	invincibility_timer = invincibility_time 
	
	sprite.play("hit")
	if (sprite.frame == 7):
		invincibility_timer = invincibility_time 
		if (is_on_floor()):
			set_state(STATE.GROUND)
		else:
			set_state(STATE.AIR)


func state_dead(_delta) -> void:
	sprite.play("appear", true)
	effects_player.play("normal")
	velocity = Vector2.ZERO
	invincibility_timer = invincibility_time
	if (sprite.frame == 1):
		set_state(STATE.SPAWN)


func hurt(damage_taken: int):
	if (invincibility_timer <= 0):
		health -= damage_taken
		
		if (health <= 0):
			print("Player %s: Dead" %player_index)
			camera.set_screenshake(Vector2(7,7), 10)
			global.play_audio(audio_dead, 1, -0.1, 0.1)
			set_state(STATE.DEAD)
		else:
			print("Player %s: HP: %s" %[player_index, health])
			camera.set_screenshake(Vector2(5,5), 5)
			global.play_audio(audio_hurt, 1, -0.1, 0.1)
			set_state(STATE.HURT)


func _on_HitBox_area_entered(area):
	if (state == STATE.ROLL):
		var _inst = area.parent
		if (_inst != self && _inst.has_method("hurt")):
			_inst.hurt(damage)
	hit_box.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.01), "timeout")
	hit_box.set_deferred("disabled", false)

