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

func _ready():
	change_state(ALIVE)
	screensize = get_viewport().get_visible_rect().size 
	
func _process(delta):
	get_input()

func _integrate_forces(physics_state):
	# this is a level physics
	set_applied_force(thrust.rotated(rotation)) # force of movement
	set_applied_torque(spin_power * rotation_dir) # that friction feel
	
	# for screen wrapping. whenever player is on the edge, he should
	# come back to the opposite of the edge
	
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	physics_state.set_transform(xform)

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
		ALIVE:
			$CollisionShape2D.disabled = false
		INVULNERUBLE:
			$CollisionShape2D.disabled = true
		DEAD:
			$CollisionShape2D.disabled = true
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
