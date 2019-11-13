extends KinematicBody2D

onready var _shape = $ColorRect.get_rect().size
onready var _view = get_viewport().get_visible_rect().size
onready var _collision_transform = $CollisionShape2D.get_transform().get_scale()

export var distort_x = 2.0
export var distort_y = 1.2

var _target = position

func _ready():
	set_process(true)
	position.y = -30
	$Tween.interpolate_property(self, "position", position, _target, 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()

var new_ball = preload("res://Scenes/Ball.tscn")



func _physics_process(delta):
	var mouse_x = get_viewport().get_mouse_position().x
	var shape = $ColorRect.get_rect().size
	var view = get_viewport().get_visible_rect().size
	var target = get_viewport().get_mouse_position().x
	if target < shape.x/2:
		target = shape.x/2
	if target > view.x - shape.x/2:
		target = view.x - shape.x/2

 	# stretch paddle
	if target != position.x:
		var x  = position.x + ((target - position.x)*0.2)
		var w = 1 + (distort_x * (abs(target - position.x)/ _view.x))
		var h = 1 - (1/distort_y * (abs(target - position.x)/ _view.y))
		_change_size(w,h)
		position = Vector2(mouse_x, position.y)
	else:
		_change_size(1,1)

func _input(event):
 if event is InputEventMouseButton and event.pressed:
  if not get_parent().has_node("Ball"):
   var ball = new_ball.instance()
   ball.position = position - Vector2(0, 32)
   ball.name = "Ball"
   ball.linear_velocity = Vector2(200, -200)
   get_parent().add_child(ball)

func _change_size(w,h):
	$ColorRect.rect_scale = Vector2(w,h)
	$CollisionShape2D.set_scale(Vector2(_collision_transform.x*w, _collision_transform.y*h))