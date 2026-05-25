extends Control

var visual := {
    "person": "reaper",
    "accent": Color(0.72, 0.92, 0.86),
    "sky": Color(0.12, 0.15, 0.18),
    "ground": Color(0.20, 0.18, 0.14)
}
var mood := 0.0

func set_visual(next_visual):
    visual = next_visual
    queue_redraw()

func pulse(direction):
    mood = clamp(direction, -1.0, 1.0)
    queue_redraw()

func _process(delta):
    mood = lerp(mood, 0.0, delta * 2.2)
    queue_redraw()

func _draw():
    if size.x <= 1.0 or size.y <= 1.0:
        return
    var accent = visual.get("accent", Color(0.72, 0.92, 0.86))
    accent = accent.lerp(Color(0.96, 0.30, 0.22), max(mood, 0.0) * 0.45)
    accent = accent.lerp(Color(0.38, 0.64, 1.0), max(-mood, 0.0) * 0.45)

    _draw_person(visual.get("person", "reaper"), accent)
    draw_line(Vector2(size.x * 0.18, size.y - 4), Vector2(size.x * 0.82, size.y - 4), Color(0.20, 0.16, 0.12, 0.35), 8.0)

func _draw_scene(scene, accent):
    match scene:
        "field":
            _draw_moon(Vector2(size.x * 0.15, size.y * 0.22), 20, Color(0.94, 0.86, 0.62, 0.86))
            for i in range(9):
                var x = size.x * (0.08 + i * 0.11)
                draw_line(Vector2(x, size.y * 0.65), Vector2(x - 10, size.y * 0.92), Color(0.72, 0.61, 0.31), 2.0)
                draw_line(Vector2(x, size.y * 0.66), Vector2(x + 12, size.y * 0.88), Color(0.87, 0.74, 0.36), 2.0)
        "plague":
            _draw_buildings(Color(0.12, 0.13, 0.13), Color(0.70, 0.82, 0.75, 0.34))
            for i in range(5):
                draw_circle(Vector2(size.x * (0.18 + i * 0.16), size.y * 0.70), 5, Color(0.63, 0.82, 0.68, 0.30))
        "mine":
            for i in range(6):
                var base = Vector2(size.x * (0.06 + i * 0.18), size.y * 0.86)
                draw_polygon(PackedVector2Array([base, base + Vector2(55, -72 - i % 2 * 22), base + Vector2(120, 0)]), PackedColorArray([Color(0.09, 0.10, 0.11)]))
            draw_line(Vector2(size.x * 0.12, size.y * 0.70), Vector2(size.x * 0.88, size.y * 0.70), Color(0.72, 0.62, 0.39, 0.72), 3.0)
        "palace":
            _draw_moon(Vector2(size.x * 0.82, size.y * 0.20), 18, Color(0.77, 0.84, 0.98, 0.78))
            for i in range(3):
                var x = size.x * (0.22 + i * 0.24)
                draw_rect(Rect2(x, size.y * 0.32, 48, size.y * 0.35), Color(0.28, 0.22, 0.34))
                draw_polygon(PackedVector2Array([Vector2(x - 10, size.y * 0.32), Vector2(x + 24, size.y * 0.16), Vector2(x + 58, size.y * 0.32)]), PackedColorArray([Color(0.40, 0.31, 0.44)]))
        "war":
            for i in range(5):
                var x = size.x * (0.12 + i * 0.18)
                draw_line(Vector2(x, size.y * 0.30), Vector2(x, size.y * 0.78), Color(0.10, 0.10, 0.11), 4.0)
                draw_polygon(PackedVector2Array([Vector2(x, size.y * 0.31), Vector2(x + 48, size.y * 0.39), Vector2(x, size.y * 0.47)]), PackedColorArray([Color(0.42, 0.08, 0.08)]))
        "market":
            _draw_buildings(Color(0.22, 0.13, 0.12), Color(0.95, 0.68, 0.30, 0.45))
            draw_rect(Rect2(size.x * 0.08, size.y * 0.58, size.x * 0.84, 7), Color(0.58, 0.31, 0.16))
        "grave":
            _draw_moon(Vector2(size.x * 0.20, size.y * 0.20), 19, Color(0.76, 0.86, 0.86, 0.82))
            for i in range(6):
                var x = size.x * (0.12 + i * 0.15)
                draw_rect(Rect2(x, size.y * 0.62, 28, 34), Color(0.34, 0.37, 0.36))
                draw_arc(Vector2(x + 14, size.y * 0.62), 14, PI, TAU, 18, Color(0.34, 0.37, 0.36), 8.0)
        "boat":
            draw_rect(Rect2(0, size.y * 0.65, size.x, size.y * 0.35), Color(0.06, 0.11, 0.17))
            for i in range(4):
                draw_line(Vector2(0, size.y * (0.72 + i * 0.06)), Vector2(size.x, size.y * (0.70 + i * 0.06)), Color(0.35, 0.55, 0.68, 0.20), 2.0)
            draw_polygon(PackedVector2Array([Vector2(size.x * 0.18, size.y * 0.66), Vector2(size.x * 0.72, size.y * 0.66), Vector2(size.x * 0.60, size.y * 0.80), Vector2(size.x * 0.28, size.y * 0.80)]), PackedColorArray([Color(0.14, 0.08, 0.04)]))
        "forge":
            _draw_buildings(Color(0.13, 0.13, 0.15), Color(0.97, 0.42, 0.20, 0.42))
            for i in range(3):
                draw_circle(Vector2(size.x * (0.62 + i * 0.08), size.y * 0.26), 18 + i * 5, Color(0.88, 0.22, 0.10, 0.18))
        _:
            _draw_buildings(Color(0.13, 0.12, 0.15), accent.darkened(0.25))

func _draw_buildings(base, light):
    for i in range(5):
        var x = size.x * (0.04 + i * 0.20)
        var h = size.y * (0.24 + 0.07 * (i % 3))
        draw_rect(Rect2(x, size.y * 0.62 - h, size.x * 0.16, h), base)
        draw_rect(Rect2(x + 14, size.y * 0.48, 10, 16), light)
        draw_rect(Rect2(x + 44, size.y * 0.41, 10, 16), light)

func _draw_moon(pos, radius, color):
    draw_circle(pos, radius, color)
    draw_circle(pos + Vector2(radius * 0.35, -radius * 0.18), radius * 0.88, visual.get("sky", Color(0.12, 0.15, 0.18)))

func _draw_person(person, accent):
    var scale_factor = min(size.x / 300.0, size.y / 245.0)
    scale_factor = clamp(scale_factor, 0.64, 1.05)
    var c := Vector2(size.x * 0.50, size.y * 0.58)
    match person:
        "noble":
            _body(c, scale_factor, Color(0.42, 0.12, 0.16), Color(0.96, 0.82, 0.42), "crown")
        "doctor":
            _body(c, scale_factor, Color(0.20, 0.25, 0.23), Color(0.72, 0.82, 0.72), "mask")
        "miner":
            _body(c, scale_factor, Color(0.32, 0.23, 0.15), Color(0.95, 0.68, 0.22), "lamp")
        "queen":
            _body(c, scale_factor, Color(0.25, 0.15, 0.42), Color(0.92, 0.78, 0.93), "veil")
        "soldier":
            _body(c, scale_factor, Color(0.18, 0.24, 0.23), Color(0.74, 0.76, 0.70), "helmet")
        "merchant":
            _body(c, scale_factor, Color(0.45, 0.22, 0.12), Color(0.94, 0.75, 0.34), "goblet")
        "bride":
            _body(c, scale_factor, Color(0.78, 0.78, 0.70), Color(0.92, 0.96, 0.91), "flower")
        "orphan":
            _body(c + Vector2(-32, 8) * scale_factor, scale_factor * 0.78, Color(0.22, 0.25, 0.28), Color(0.65, 0.76, 0.86), "small")
            _body(c + Vector2(48, 20) * scale_factor, scale_factor * 0.72, Color(0.27, 0.20, 0.18), Color(0.78, 0.64, 0.44), "small")
        "saint":
            _body(c, scale_factor, Color(0.34, 0.36, 0.40), Color(0.60, 0.86, 0.95), "gear")
        "warden":
            _body(c, scale_factor, Color(0.11, 0.13, 0.16), Color(0.80, 0.78, 0.70), "keys")
        _:
            _body(c, scale_factor, Color(0.06, 0.06, 0.08), accent, "scythe")

func _body(c, s, robe, accent, prop):
    draw_circle(c + Vector2(0, -64) * s, 36 * s, Color(0.70, 0.62, 0.52))
    draw_polygon(PackedVector2Array([
        c + Vector2(-88, 92) * s,
        c + Vector2(-52, -32) * s,
        c + Vector2(0, -66) * s,
        c + Vector2(52, -32) * s,
        c + Vector2(88, 92) * s
    ]), PackedColorArray([robe]))
    draw_line(c + Vector2(-52, -8) * s, c + Vector2(52, -8) * s, accent, 7.0 * s)
    draw_circle(c + Vector2(-12, -72) * s, 5.0 * s, Color(0.05, 0.05, 0.05))
    draw_circle(c + Vector2(12, -72) * s, 5.0 * s, Color(0.05, 0.05, 0.05))

    match prop:
        "crown":
            draw_polygon(PackedVector2Array([c + Vector2(-36, -92) * s, c + Vector2(-16, -122) * s, c + Vector2(0, -96) * s, c + Vector2(16, -122) * s, c + Vector2(36, -92) * s]), PackedColorArray([accent]))
        "mask":
            draw_polygon(PackedVector2Array([c + Vector2(10, -64) * s, c + Vector2(82, -54) * s, c + Vector2(12, -44) * s]), PackedColorArray([Color(0.86, 0.82, 0.66)]))
        "lamp":
            draw_line(c + Vector2(44, -8) * s, c + Vector2(106, -42) * s, accent, 6.0 * s)
            draw_circle(c + Vector2(116, -48) * s, 18 * s, Color(1.0, 0.72, 0.22, 0.85))
        "veil":
            draw_arc(c + Vector2(0, -68) * s, 54 * s, PI, TAU, 24, Color(0.93, 0.88, 0.96, 0.72), 12.0 * s)
        "helmet":
            draw_arc(c + Vector2(0, -66) * s, 39 * s, PI, TAU, 24, Color(0.54, 0.56, 0.54), 14.0 * s)
            draw_line(c + Vector2(0, -104) * s, c + Vector2(0, -136) * s, accent, 6.0 * s)
        "goblet":
            draw_rect(Rect2(c + Vector2(64, -54) * s, Vector2(24, 36) * s), accent)
            draw_line(c + Vector2(76, -18) * s, c + Vector2(76, 24) * s, accent, 5.0 * s)
        "flower":
            for i in range(6):
                draw_circle(c + Vector2(70, -48) * s + Vector2(cos(i) * 12, sin(i) * 12) * s, 7 * s, Color(0.92, 0.92, 0.88))
            draw_circle(c + Vector2(70, -48) * s, 8 * s, accent)
        "gear":
            draw_circle(c + Vector2(72, -54) * s, 28 * s, accent)
            draw_circle(c + Vector2(72, -54) * s, 14 * s, Color(0.12, 0.15, 0.17))
        "keys":
            draw_line(c + Vector2(62, -28) * s, c + Vector2(110, 0) * s, accent, 6.0 * s)
            draw_circle(c + Vector2(118, 8) * s, 13 * s, accent, false, 4.0 * s)
        "small":
            draw_circle(c + Vector2(0, -54) * s, 24 * s, Color(0.70, 0.62, 0.52))
        "scythe":
            draw_line(c + Vector2(72, -32) * s, c + Vector2(120, 92) * s, Color(0.82, 0.88, 0.90), 6.0 * s)
            draw_arc(c + Vector2(116, -52) * s, 62 * s, deg_to_rad(205), deg_to_rad(326), 24, Color(0.82, 0.88, 0.90), 6.0 * s)
