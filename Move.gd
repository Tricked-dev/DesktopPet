extends Sprite2D

var t = 0.0
var clicked_since

var time_since_target = 0
var wander_target = Vector2()

var DONT_CHANGE_NUM = 30
var paused = false
var MOVEMENT_SPEED = 150
var wandering = false

var crimson_rat = preload("res://rats/crimson_rat.png")
var toxic_rat = preload("res://rats/toxic_rat.png")
var house_rat = preload("res://rats/house_rat.png")

var window_size = Vector2i()

func _ready():
	$Animations.play("walking")
	#var folder := OS.get_executable_path().get_base_dir()
	#if FileAccess.file_exists("crimson"):
		#texture = crimson_rat
	#elif FileAccess.file_exists("toxic"):
		#texture = toxic_rat
	#elif FileAccess.file_exists("house"):
		#texture = house_rat


func _process(delta):
	var now = Time.get_ticks_msec()
	var mouse = get_global_mouse_position()
	if mouse.x > window_size.x:
		window_size.x = mouse.x
	if mouse.y > window_size.y:
		window_size.y = mouse.y
	if Input.is_action_just_pressed("click"):
		print("Click")
		if clicked_since != null:
			print(clicked_since, " ", now, "  ", now - clicked_since)
		if clicked_since != null and now - clicked_since < 2000:
			paused = true
		clicked_since = now
		
	elif Input.is_action_pressed("click") or Input.is_action_pressed("jump"):
		print("ClickActive")
		t += delta * 0.03
		var loc = Vector2(get_window().position) 
		var center = loc - Vector2(get_window().size / 2) 
		var goal = Vector2(center) + mouse
		var diff = abs(loc.x - goal.x)
		if not Input.is_action_pressed("jump"):
			if diff > DONT_CHANGE_NUM:
				flip_h = loc.x > goal.x
				$Animations.play("flying")
			else:
				$Animations.play("idle")
		if clicked_since != null and now - clicked_since > 2000:
			paused = false
		get_window().position = loc.lerp(goal, t)
		wandering  = false
		 
	if Input.is_action_pressed("jump"):
		$Animations.play("jump")
	if Input.is_action_just_pressed("next"):
		if texture == crimson_rat:
			texture = toxic_rat
		elif texture == toxic_rat:
			texture = house_rat
		elif texture == house_rat:
			texture = crimson_rat
		pass
	if Input.is_action_just_pressed("wander"):
		wandering = !wandering
		create_new_target()
		time_since_target = now
		
var rng = RandomNumberGenerator.new()	
func create_new_target():
	wander_target.y = rng.randi_range(0 , window_size.y)
	wander_target.x = rng.randi_range(0 , window_size.x)
	print(wander_target)

func _physics_process(delta):
	if not paused:
		print("Not Paused")
		var loc = Vector2(get_window().position)
		var center = loc - Vector2(get_window().size / 2) 
		var goal = wander_target if wandering else Vector2(center) + get_global_mouse_position()
		var diff = abs(loc.x - goal.x)
		if not Input.is_action_pressed("jump"):
			if diff > DONT_CHANGE_NUM:
				flip_h = loc.x > goal.x
				$Animations.play("walking")
			else:
				$Animations.play("idle")
				if wandering:
					create_new_target()
		var movement = (goal - loc).normalized() * MOVEMENT_SPEED * delta
		get_window().position += Vector2i(movement)
		if wandering:
			var now = Time.get_ticks_msec()
			if time_since_target - now > 15000:
				create_new_target()
				time_since_target = now
				
	else:
		$Animations.play("idle")

