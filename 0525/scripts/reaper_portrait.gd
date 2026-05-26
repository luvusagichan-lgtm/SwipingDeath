extends Control

var mood := 0.0

func _process(delta):
    mood = lerp(mood, 0.0, delta * 2.0)
    queue_redraw()

func pulse(direction):
    mood = clamp(direction, -1.0, 1.0)

func _draw():
    var w = size.x
    var h = size.y
    var center = Vector2(w * 0.5, h * 0.54)
    var accent = Color(0.72, 0.92, 0.86, 1.0).lerp(Color(0.98, 0.33, 0.24, 1.0), max(mood, 0.0))
    accent = accent.lerp(Color(0.46, 0.68, 1.0, 1.0), max(-mood, 0.0))

    draw_arc(center + Vector2(w * 0.26, -h * 0.03), h * 0.42, deg_to_rad(210), deg_to_rad(330), 32, Color(0.82, 0.88, 0.92, 0.82), 5.0, true)
    draw_line(center + Vector2(w * 0.10, h * 0.02), center + Vector2(w * 0.32, h * 0.34), Color(0.82, 0.88, 0.92, 0.78), 4.0, true)

    var hood = PackedVector2Array([
        center + Vector2(-w * 0.23, h * 0.24),
        center + Vector2(-w * 0.18, -h * 0.23),
        center + Vector2(0.0, -h * 0.36),
        center + Vector2(w * 0.20, -h * 0.20),
        center + Vector2(w * 0.24, h * 0.25)
    ])
    draw_colored_polygon(hood, Color(0.05, 0.055, 0.07, 1.0))
    draw_polyline(hood, Color(0.20, 0.23, 0.27, 1.0), 2.0, true)

    draw_circle(center + Vector2(-w * 0.07, -h * 0.03), 5.0 + abs(mood) * 2.0, accent)
    draw_circle(center + Vector2(w * 0.07, -h * 0.03), 5.0 + abs(mood) * 2.0, accent)

    draw_arc(center + Vector2(0.0, h * 0.07), w * 0.08, deg_to_rad(22), deg_to_rad(158), 16, Color(0.74, 0.79, 0.80, 0.72), 2.0, true)
    draw_line(center + Vector2(-w * 0.30, h * 0.30), center + Vector2(w * 0.30, h * 0.30), Color(0.14, 0.16, 0.19, 1.0), 10.0, true)

