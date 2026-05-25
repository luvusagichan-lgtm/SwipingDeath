extends Control

var visual := {
    "scene": "court",
    "sky": Color(0.08, 0.09, 0.11),
    "ground": Color(0.13, 0.12, 0.11)
}

func set_visual(next_visual):
    visual = next_visual
    queue_redraw()

func _draw():
    var scene = visual.get("scene", "court")
    var sky = visual.get("sky", Color(0.08, 0.09, 0.11))
    var ground = visual.get("ground", Color(0.13, 0.12, 0.11))

    draw_rect(Rect2(Vector2.ZERO, size), sky)
    draw_rect(Rect2(0, size.y * 0.56, size.x, size.y * 0.44), ground)

    match scene:
        "field":
            _moon(Vector2(size.x * 0.16, size.y * 0.18), 46, Color(0.94, 0.82, 0.48, 0.82))
            for i in range(28):
                var x = size.x * (i / 27.0)
                draw_line(Vector2(x, size.y * 0.60), Vector2(x - 28, size.y), Color(0.70, 0.54, 0.20, 0.74), 4.0)
                draw_line(Vector2(x + 8, size.y * 0.62), Vector2(x + 34, size.y), Color(0.92, 0.74, 0.30, 0.48), 3.0)
        "plague":
            _city(Color(0.07, 0.10, 0.10), Color(0.52, 0.70, 0.58, 0.34))
            for i in range(18):
                draw_circle(Vector2(size.x * fmod(i * 0.17, 1.0), size.y * (0.64 + fmod(i * 0.11, 0.22))), 10, Color(0.55, 0.78, 0.60, 0.20))
        "mine":
            for i in range(10):
                var x = size.x * (i * 0.11 - 0.08)
                draw_polygon(PackedVector2Array([Vector2(x, size.y), Vector2(x + size.x * 0.13, size.y * (0.34 + 0.05 * (i % 3))), Vector2(x + size.x * 0.28, size.y)]), PackedColorArray([Color(0.04, 0.05, 0.06, 0.92)]))
            draw_line(Vector2(size.x * 0.08, size.y * 0.66), Vector2(size.x * 0.92, size.y * 0.66), Color(0.68, 0.52, 0.28, 0.72), 8.0)
        "palace":
            _moon(Vector2(size.x * 0.84, size.y * 0.18), 40, Color(0.74, 0.80, 0.98, 0.86))
            for i in range(5):
                var x = size.x * (0.08 + i * 0.19)
                draw_rect(Rect2(x, size.y * 0.30, size.x * 0.11, size.y * 0.38), Color(0.18, 0.14, 0.25, 0.94))
                draw_polygon(PackedVector2Array([Vector2(x - 18, size.y * 0.30), Vector2(x + size.x * 0.055, size.y * 0.16), Vector2(x + size.x * 0.11 + 18, size.y * 0.30)]), PackedColorArray([Color(0.31, 0.23, 0.38, 0.96)]))
        "war":
            for i in range(13):
                var x = size.x * (i / 12.0)
                draw_line(Vector2(x, size.y * 0.22), Vector2(x + 20, size.y * 0.72), Color(0.06, 0.06, 0.06, 0.86), 6.0)
                draw_polygon(PackedVector2Array([Vector2(x, size.y * 0.24), Vector2(x + 70, size.y * 0.31), Vector2(x + 5, size.y * 0.43)]), PackedColorArray([Color(0.42, 0.04, 0.04, 0.78)]))
        "market":
            _city(Color(0.18, 0.10, 0.08), Color(0.95, 0.60, 0.25, 0.40))
            draw_rect(Rect2(0, size.y * 0.60, size.x, 10), Color(0.54, 0.28, 0.12, 0.72))
        "grave":
            _moon(Vector2(size.x * 0.20, size.y * 0.18), 42, Color(0.72, 0.84, 0.84, 0.84))
            for i in range(22):
                var x = size.x * fmod(i * 0.13, 1.0)
                draw_rect(Rect2(x, size.y * (0.62 + 0.10 * (i % 2)), 34, 56), Color(0.18, 0.22, 0.21, 0.78))
        "boat":
            draw_rect(Rect2(0, size.y * 0.52, size.x, size.y * 0.48), Color(0.03, 0.09, 0.15, 1.0))
            for i in range(9):
                draw_line(Vector2(0, size.y * (0.58 + i * 0.045)), Vector2(size.x, size.y * (0.56 + i * 0.045)), Color(0.24, 0.48, 0.64, 0.27), 3.0)
            draw_polygon(PackedVector2Array([Vector2(size.x * 0.12, size.y * 0.58), Vector2(size.x * 0.72, size.y * 0.58), Vector2(size.x * 0.62, size.y * 0.73), Vector2(size.x * 0.22, size.y * 0.73)]), PackedColorArray([Color(0.10, 0.05, 0.03, 0.90)]))
        "forge":
            _city(Color(0.10, 0.10, 0.12), Color(0.95, 0.30, 0.12, 0.48))
            for i in range(5):
                draw_circle(Vector2(size.x * (0.58 + i * 0.08), size.y * 0.30), 42 + i * 8, Color(0.88, 0.18, 0.08, 0.14))
        _:
            _city(Color(0.08, 0.08, 0.10), Color(0.35, 0.42, 0.44, 0.32))

    draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.03, 0.38))

func _city(base, light):
    for i in range(9):
        var x = size.x * (i * 0.13 - 0.04)
        var w = size.x * 0.10
        var h = size.y * (0.20 + 0.06 * (i % 4))
        draw_rect(Rect2(x, size.y * 0.58 - h, w, h), base)
        draw_rect(Rect2(x + w * 0.25, size.y * 0.49, w * 0.12, size.y * 0.035), light)
        draw_rect(Rect2(x + w * 0.62, size.y * 0.42, w * 0.12, size.y * 0.035), light)

func _moon(pos, radius, color):
    draw_circle(pos, radius, color)
    draw_circle(pos + Vector2(radius * 0.35, -radius * 0.14), radius * 0.88, visual.get("sky", Color(0.08, 0.09, 0.11)))
