extends RigidBody2D

signal exploded

var screensize = Vector2()
var size
var radius
var scale_factor = 0.2

func start(pos, vel, _size):
	position = pos
	size = _size
	mass = 1.5 * size
	$Sprite.scale = Vector2(1,1) * scale_factor * size
	radius = int($Sprite.texture.get_size().x/2 * scale_factor * size)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = vel 
	angular_velocity = rand_range(-1.5, 1.5)
	$Explosion.scale = Vector2(0.75, 0.75) * size
	

func _integrate_forces(physics_state):
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

func explode():
	layers = 0 # ensure its drawn above all images
	$Sprite.hide()
	$Explosion/AnimationPlayer.play("explosion")
	emit_signal("exploded", size, radius, position, linear_velocity)
	linear_velocity = Vector2()
	angular_velocity = 0


func _on_AnimationPlayer_animation_finished(_name):
	queue_free()
