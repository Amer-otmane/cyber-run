extends Node3D

# ─────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────
func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _find_anim_player(child)
		if result:
			return result
	return null

func _apply_mat(node: Node, mat: StandardMaterial3D):
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		_apply_mat(child, mat)

# ─────────────────────────────────────────
# Frame-perfect : sort 1 frame avant la fin
# ─────────────────────────────────────────
func _wait_anim_end(anim: AnimationPlayer, anim_name: String) -> void:
	if not anim or not anim.has_animation(anim_name):
		return
	var length := anim.get_animation(anim_name).length
	while true:
		await get_tree().process_frame
		if not anim.is_playing() or anim.current_animation != anim_name:
			return
		if anim.current_animation_position >= length - get_process_delta_time():
			return

# ─────────────────────────────────────────
# VARIABLES
# ─────────────────────────────────────────
var cam         : Camera3D
var anim_sec    : AnimationPlayer
var anim_pl     : AnimationPlayer
var anim_throw  : AnimationPlayer
var anim_yell   : AnimationPlayer
var anim_run    : AnimationPlayer
var anim_jump   : AnimationPlayer
var vase_node   : Node3D
var conv_center : Vector3

var _securite    : Node3D
var _yell        : Node3D
var _player      : Node3D
var _throw_player: Node3D
var _run_player  : Node3D
var _jump_player : Node3D

# Sous-titres
var subtitle_label : Label
var subtitle_layer : CanvasLayer

# ─────────────────────────────────────────
# READY
# ─────────────────────────────────────────
func _ready():
	var bi_scene = load("res://models/Futuristic Apartment_Cycles.glb")
	var bi = bi_scene.instantiate()
	add_child(bi)
	bi.position = Vector3(0, 0, 0)
	bi.scale    = Vector3(0.1, 0.1, 0.1)

	var light = DirectionalLight3D.new()
	add_child(light)
	light.rotation_degrees = Vector3(-45, 0, 0)
	light.light_energy     = 1.5

	var tex_sec = load("res://models/securite(1)_texture_pbr_20250901.png")
	var mat_sec = StandardMaterial3D.new()
	mat_sec.albedo_texture = tex_sec

	var tex_player = load("res://models/player(1)_texture_pbr_20250901.png")
	var mat_pl = StandardMaterial3D.new()
	mat_pl.albedo_texture = tex_player

	# ── Talking sécurité ──
	var securite_scene = load("res://models/Talking.fbx")
	var securite = securite_scene.instantiate()
	bi.add_child(securite)
	securite.position         = Vector3(-2.0, 2.8, 12.0)
	securite.scale            = Vector3(1.5, 1.5, 1.5)
	securite.rotation_degrees = Vector3(0, 90, 0)
	securite.visible          = true
	_apply_mat(securite, mat_sec)
	anim_sec = _find_anim_player(securite)

	# ── Yelling sécurité ──
	var yell_scene = load("res://models/Yelling.fbx")
	var yell = yell_scene.instantiate()
	bi.add_child(yell)
	yell.position         = Vector3(-2.0, 2.8, 12.0)
	yell.scale            = Vector3(1.5, 1.5, 1.5)
	yell.rotation_degrees = Vector3(0, 90, 0)
	yell.visible          = false
	_apply_mat(yell, mat_sec)
	anim_yell = _find_anim_player(yell)

	# ── Talking player ──
	var player_scene = load("res://models/Talking_player.fbx")
	var player = player_scene.instantiate()
	bi.add_child(player)
	player.position         = Vector3(2.0, 2.8, 12.0)
	player.scale            = Vector3(1.5, 1.5, 1.5)
	player.rotation_degrees = Vector3(0, -90, 0)
	player.visible          = true
	_apply_mat(player, mat_pl)
	anim_pl = _find_anim_player(player)

	# ── Throw player ──
	var throw_scene = load("res://models/Throw Object.fbx")
	var throw_player = throw_scene.instantiate()
	bi.add_child(throw_player)
	throw_player.position         = Vector3(2.0, 2.8, 12.0)
	throw_player.scale            = Vector3(1.5, 1.5, 1.5)
	throw_player.rotation_degrees = Vector3(0, -90, 0)
	throw_player.visible          = false
	_apply_mat(throw_player, mat_pl)
	anim_throw = _find_anim_player(throw_player)

	# ── Running player ──
	var run_scene = load("res://models/Running (3).fbx")
	var run_player = run_scene.instantiate()
	bi.add_child(run_player)
	run_player.position         = Vector3(2.0, 2.8, 12.0)
	run_player.scale            = Vector3(1.5, 1.5, 1.5)
	run_player.rotation_degrees = Vector3(0, 0, 0)
	run_player.visible          = false
	_apply_mat(run_player, mat_pl)
	anim_run    = _find_anim_player(run_player)
	_run_player = run_player

	# ── Jumping Down player ──
	var jump_scene = load("res://models/Jumping Down.fbx")
	var jump_player = jump_scene.instantiate()
	bi.add_child(jump_player)
	jump_player.position         = Vector3(2.0, 2.8, 12.0)
	jump_player.scale            = Vector3(1.5, 1.5, 1.5)
	jump_player.rotation_degrees = Vector3(0, 0, 0)
	jump_player.visible          = false
	_apply_mat(jump_player, mat_pl)
	anim_jump    = _find_anim_player(jump_player)
	_jump_player = jump_player

	# ── Vase ──
	var vase_scene = load("res://models/vase(2).glb")
	var vase = vase_scene.instantiate()
	bi.add_child(vase)
	vase.position = Vector3(3.5, 2.8, 12.0)
	vase.scale    = Vector3(0.15, 0.15, 0.15)
	vase.visible  = false
	vase_node     = vase

	_securite     = securite
	_yell         = yell
	_player       = player
	_throw_player = throw_player

	conv_center = Vector3(0.0, 0.42, 1.2)

	cam = Camera3D.new()
	add_child(cam)
	var center  = Vector3(0, 0.5, 0)
	var radius  = 28.0
	var top_y   = 10.0
	cam.position = Vector3(0, top_y, radius)
	cam.look_at(center)
	cam.make_current()

	await get_tree().process_frame

	if anim_sec:   anim_sec.stop()
	if anim_pl:    anim_pl.stop()
	if anim_throw: anim_throw.stop()
	if anim_yell:  anim_yell.stop()
	if anim_run:   anim_run.stop()
	if anim_jump:  anim_jump.stop()

	_run_cinematic(center, radius, top_y)
	_build_subtitles()


# ─────────────────────────────────────────
# CINÉMATIQUE — tour complet lent autour de la maison
# ─────────────────────────────────────────
func _run_cinematic(center, radius, top_y):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)   # vitesse constante, pas d'accélération

	# Tour complet : 8 positions régulières autour de la maison
	# Chaque segment = 45° → 8 × 45° = 360° complet
	# Durée par segment = 3.5s → tour complet en ~28 secondes
	var steps = [
		Vector3(0,          top_y, radius),           # départ : face avant
		Vector3(radius * 0.7,  top_y, radius * 0.7),  # 45°
		Vector3(radius,     top_y, 0),                 # 90° côté droit
		Vector3(radius * 0.7,  top_y, -radius * 0.7), # 135°
		Vector3(0,          top_y, -radius),           # 180° derrière
		Vector3(-radius * 0.7, top_y, -radius * 0.7), # 225°
		Vector3(-radius,    top_y, 0),                 # 270° côté gauche
		Vector3(-radius * 0.7, top_y, radius * 0.7),  # 315°
		Vector3(0,          top_y, radius),            # 360° retour face avant
	]

	for pos in steps:
		tween.tween_property(cam, "position", pos, 5.0)
		tween.tween_callback(func(): cam.look_at(center + Vector3(0, 1.5, 0)))

	# Zoom final direct vers la scène conversation
	tween.tween_property(cam, "position", Vector3(0.0, 0.42, 1.6), 3.0)
	tween.tween_callback(func():
		cam.look_at(conv_center)
		_securite.visible     = true
		_yell.visible         = false
		_player.visible       = true
		_throw_player.visible = false
		_run_player.visible   = false
		_jump_player.visible  = false
		vase_node.visible     = false
		_conversation()
	)


# ─────────────────────────────────────────
# SOUS-TITRES
# ─────────────────────────────────────────
func _build_subtitles() -> void:
	subtitle_layer       = CanvasLayer.new()
	subtitle_layer.layer = 5
	add_child(subtitle_layer)

	# Fond semi-transparent derrière le texte
	var bg = ColorRect.new()
	var vp = get_viewport().get_visible_rect().size
	bg.color    = Color(1, 1, 1, 0.85)
	bg.size     = Vector2(vp.x * 0.72, 52)
	bg.position = Vector2(vp.x * 0.14, vp.y - 95)
	bg.modulate.a = 0.0   # invisible au départ
	subtitle_layer.add_child(bg)

	subtitle_label = Label.new()
	subtitle_label.text                 = ""
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 17)
	subtitle_label.add_theme_constant_override("shadow_offset_x", 1)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 1)
	subtitle_label.add_theme_constant_override("shadow_outline_size", 3)
	subtitle_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	subtitle_label.size     = Vector2(vp.x * 0.72, 52)
	subtitle_label.position = Vector2(vp.x * 0.14, vp.y - 95)
	subtitle_label.modulate.a = 0.0
	subtitle_layer.add_child(subtitle_label)


func _show_sub(speaker: String, line: String, color: Color) -> void:
	subtitle_label.add_theme_color_override("font_color", color)
	subtitle_label.text = speaker + ":  " + line
	var tw = create_tween()
	tw.tween_property(subtitle_label, "modulate:a", 1.0, 0.25)


func _hide_sub() -> void:
	var tw = create_tween()
	tw.tween_property(subtitle_label, "modulate:a", 0.0, 0.25)


# ─────────────────────────────────────────
# CONVERSATION
# ─────────────────────────────────────────
func _conversation():
	# ① Security parle
	_show_sub("Security", "Hello, sir! Can I see your work ID, please?", Color(0, 0, 0))
	anim_sec.play("mixamo_com")
	await _wait_anim_end(anim_sec, "mixamo_com")
	_hide_sub()
	await get_tree().create_timer(0.3).timeout

	# ② Player répond
	_show_sub("Player", "No… I don't have it. That's what I forgot.", Color(0, 0, 0))
	anim_sec.stop()
	anim_pl.play("mixamo_com")
	await _wait_anim_end(anim_pl, "mixamo_com")
	_hide_sub()
	await get_tree().create_timer(0.3).timeout

	# ③ Security crie + vase apparaît
	_show_sub("Security", "Why don't you have it? Are you trying to drive me crazy?", Color(0, 0, 0))
	anim_pl.stop()
	_securite.visible = false
	_yell.visible     = true
	_player.visible   = true
	vase_node.visible = true
	anim_yell.play("mixamo_com")
	await _wait_anim_end(anim_yell, "mixamo_com")
	_hide_sub()
	await get_tree().create_timer(0.2).timeout

	# ④ Player — dernière réplique avant throw
	_show_sub("Player", "Just go away… AHHH!", Color(0, 0, 0))
	await get_tree().create_timer(1.2).timeout
	_hide_sub()
	await get_tree().create_timer(0.2).timeout

	# ⑤ Throw
	_phase_throw()


# ─────────────────────────────────────────
# THROW
# ─────────────────────────────────────────
func _phase_throw():
	anim_yell.stop()
	_securite.visible     = false
	_yell.visible         = true
	_player.visible       = false
	_throw_player.visible = true

	# Caméra recule légèrement pour voir le throw
	var t2 = create_tween()
	t2.set_ease(Tween.EASE_IN_OUT)
	t2.set_trans(Tween.TRANS_LINEAR)
	t2.tween_property(cam, "position", Vector3(0.0, 0.45, 2.2), 1.0)
	t2.tween_callback(func(): cam.look_at(conv_center))

	anim_throw.stop()
	anim_throw.play("mixamo_com")

	# Lancer le vase à 40% du throw
	var throw_length := anim_throw.get_animation("mixamo_com").length if anim_throw.has_animation("mixamo_com") else 2.0
	var throw_moment  := throw_length * 0.4
	while anim_throw.is_playing():
		if anim_throw.current_animation_position >= throw_moment:
			break
		await get_tree().process_frame
	_throw_vase()

	# Attendre fin complète du throw
	while anim_throw.is_playing():
		await get_tree().process_frame

	vase_node.visible = false
	_phase_run()


# ─────────────────────────────────────────
# RUNNING
# ─────────────────────────────────────────
func _phase_run():
	anim_throw.stop()
	_throw_player.visible = false
	_yell.visible         = false

	_run_player.position         = Vector3(2.0, 2.8, 12.0)
	_run_player.rotation_degrees = Vector3(0, 0, 0)
	_run_player.visible          = true

	# Caméra vue latérale stable
	var cam_tween = create_tween()
	cam_tween.set_ease(Tween.EASE_IN_OUT)
	cam_tween.set_trans(Tween.TRANS_LINEAR)
	cam_tween.tween_property(cam, "position", Vector3(-0.4, 0.5, 1.15), 0.8)
	cam_tween.tween_callback(func(): cam.look_at(Vector3(0.20, 0.25, 1.40)))

	var run_tween = create_tween()
	run_tween.set_ease(Tween.EASE_IN)
	run_tween.set_trans(Tween.TRANS_QUAD)
	run_tween.tween_property(_run_player, "position",
		Vector3(2.0, 2.8, 13.5), 1.0)

	anim_run.play("mixamo_com")
	await _wait_anim_end(anim_run, "mixamo_com")

	_phase_jump()


# ─────────────────────────────────────────
# JUMPING DOWN
# ─────────────────────────────────────────
func _phase_jump():
	anim_run.stop()
	_run_player.visible  = false
	_jump_player.visible = true

	_jump_player.position         = Vector3(2.0, 2.8, 13.5)
	_jump_player.rotation_degrees = Vector3(0, 0, 0)

	var fall_tween = create_tween()
	fall_tween.set_ease(Tween.EASE_IN)
	fall_tween.set_trans(Tween.TRANS_QUAD)
	fall_tween.tween_property(_jump_player, "position",
		Vector3(2.0, 0.0, 16.0), 1.5)

	anim_jump.play("mixamo_com")

	while anim_jump.is_playing():
		await get_tree().process_frame

	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main2.tscn")


# ─────────────────────────────────────────
# THROW VASE
# ─────────────────────────────────────────
func _throw_vase():
	var peak_pos = Vector3(
		(vase_node.position.x + (-2.0)) / 2.0,
		vase_node.position.y + 2.5,
		vase_node.position.z
	)
	var end_pos = Vector3(-2.0, 2.8, 12.0)

	vase_node.rotation_degrees = Vector3(0, 0, 0)

	var t = create_tween()
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_QUAD)
	t.tween_property(vase_node, "position", peak_pos, 0.5)
	t.tween_property(vase_node, "position", end_pos, 0.6)
	t.parallel().tween_property(vase_node, "rotation_degrees",
		Vector3(360, 270, 0), 1.1)
