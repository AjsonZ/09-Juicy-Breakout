extends RigidBody2D

export var maxspeed = 300
onready var Game = get_node("/root/World")
onready var Camera = get_node("/root/World/Camera")
onready var Starting = get_node("/root/World/Starting")

onready var Blip = get_node("/root/World/Blip")
onready var Boing = get_node("/root/World/Boing")
onready var Applause = get_node("/root/World/Applause")

var _decay_rate = 0.8
var _max_offset = 4
var trauma_color = Color(1,1,1,1)

var _start_size
var _start_position
var _rotation = 0
var _rotation_speed = 0.05
var _color = 0.0
var _color_decay = 1
var _normal_color
var _trauma = 0.0

signal lives
signal score

func _ready():
 contact_monitor = true
 set_max_contacts_reported(4)
 var WorldNode = get_node("/root/World")
 connect("score", WorldNode, "increase_score")
 connect("lives", WorldNode, "decrease_lives")
 set_max_contacts_reported(4)
 _start_position = $ColorRect.rect_position

 _normal_color = $ColorRect.color


func _physics_process(delta):
	var bodies = get_colliding_bodies()
	for body in bodies:
		Camera.add_trauma(0.2)
		if body.is_in_group("Tiles"):
			emit_signal("score",body.score)
			add_color(1.0)
			Blip.play()
			body.kill()
		add_trauma(2.0)
		if body.get_name() == "Paddle":
			Applause.play()
			pass
		if body.name == "Wall":
			Boing.play()
  
 if position.y > get_viewport_rect().end.y:
  emit_signal("lives")
  queue_free()

func _process(delta):
	if _trauma > 0:
		_decay_trauma(delta)
		_apply_shake()
	if _color > 0:
		_decay_color(delta)
		_apply_color()
	if _color == 0 and $ColorRect.color != _normal_color:
		$ColorRect.color = _normal_color

func add_color(amount):
	_color += amount
	
func _apply_color():
	var a = min(1,_color)
	$ColorRect.color = _normal_color.linear_interpolate(trauma_color, a)
	
func _decay_color(delta):
	var change = _color_decay * delta
	_color = max(_color - change,0)

func add_trauma(amount):
	_trauma = min(_trauma + amount,1)

func _decay_trauma(delta):
	var change = _decay_rate + delta
	_trauma = max(_trauma - change, 0)
	
func _apply_shake():
	var shake = _trauma * _trauma
	var o_x = _max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = _max_offset * shake * _get_neg_or_pos_scalar()

func _get_neg_or_pos_scalar():
	return rand_range(-1.0,1.0)