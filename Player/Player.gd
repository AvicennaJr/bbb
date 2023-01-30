extends RigidBody2D

enum {INIT, ALIVE, INVULNERUBLE, DEAD}
var state = null

# control the ship's acceleration
export (int) var engine_power
export (int) var spin_power

var thrust = Vector2() # controlled by engine_power
var rotation_dir = 0 # direction controlled by sping power

# for screen wrapping
var screensize = Vector2()

# for the bullets
signal shoot
# for lives count
signal lives_changed
# for dead
signal dead

var lives = 0 setget set_lives # save lives function called when value of lives changes

export (PackedScene) var Bullet # this will insert the bullet scene
export (float) var fire_rate

var can_shoot = true
var radius

func _ready():
	change_state(ALIVE)
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate
	# radius = int($Sprite.texture.get_size().x/2)
	radius = int($CollisionShape2D.shape.radius/2)
	
func _process(delta):
	get_input()

func _integrate_forces(physics_state):
	# this is a level physics
	set_applied_force(thrust.rotated(rotation)) # force of movement
	set_applied_torque(spin_power * rotation_dir) # that friction feel
	
	# for screen wrapping. whenever player is on the edge, he should
	# come back to the opposite of the edge
	
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x + radius:
		xform.origin.x = 0 - radius
	if xform.origin.x < 0 - radius:
		xform.origin.x = screensize.x + radius
	if xform.origin.y > screensize.y + radius:
		xform.origin.y = 0 - radius
	if xform.origin.y < 0 - radius:
		xform.origin.y = screensize.y + radius
	physics_state.set_transform(xform)

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
		ALIVE:
			$CollisionShape2D.disabled = false
			$Sprite.modulate.a = 1.0
		INVULNERUBLE:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.disabled = true
			$Sprite.hide()
			linear_velocity = Vector2()
			emit_signal("dead")
	state = new_state

func get_input():
	thrust = Vector2()
	rotation_dir = 0
	if state in [DEAD, INIT]:
		# can't move while dead or after hit
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power, 0)
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if state == INVULNERUBLE:
		return
	
	emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
	$FartSound.play()
	can_shoot = false
	$GunTimer.start()


func _on_GunTimer_timeout():
	can_shoot = true

func set_lives(value):
	lives = value
	emit_signal("lives_changed", lives)

func start():
	$Sprite.show()
	self.lives = 3 # must use self. for setgets
	change_state(ALIVE)
