extends Control

const SWIPE_THRESHOLD := 170.0
const CARD_SIZE := Vector2(520, 560)

var stats := {
    "秩序": 50,
    "恐惧": 36,
    "怜悯": 42,
    "冥币": 30
}

var stat_bars := {}
var deck := []
var current_card := {}
var current_index := 0
var year := 1
var dragging := false
var drag_start := Vector2.ZERO
var card_home := Vector2.ZERO
var game_ended := false
var resolving := false

var card_panel
var title_label
var body_label
var left_label
var right_label
var hint_label
var year_label
var omen_label
var outcome_label
var world_bg
var illustration
var restart_button

func _ready():
    randomize()
    _build_deck()
    _build_ui()
    _position_card()
    _show_card(deck[current_index])

func _notification(what):
    if what == NOTIFICATION_RESIZED and card_panel:
        _position_card()

func _build_ui():
    set_anchors_preset(Control.PRESET_FULL_RECT)

    world_bg = preload("res://scripts/scene_background.gd").new()
    world_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    world_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(world_bg)

    var veil := ColorRect.new()
    veil.color = Color(0.11, 0.15, 0.17, 0.38)
    veil.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(veil)

    var top := VBoxContainer.new()
    top.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 56
    top.offset_right = -56
    top.offset_top = 26
    top.offset_bottom = 152
    top.add_theme_constant_override("separation", 10)
    add_child(top)

    var header := HBoxContainer.new()
    header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(header)

    year_label = Label.new()
    year_label.text = "第 1 夜"
    year_label.add_theme_font_size_override("font_size", 28)
    year_label.add_theme_color_override("font_color", Color(0.90, 0.96, 0.91))
    year_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(year_label)

    omen_label = Label.new()
    omen_label.text = "亡者排队，生者等候"
    omen_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    omen_label.add_theme_font_size_override("font_size", 18)
    omen_label.add_theme_color_override("font_color", Color(0.68, 0.76, 0.76))
    omen_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(omen_label)

    var stat_row := GridContainer.new()
    stat_row.columns = 4
    stat_row.add_theme_constant_override("h_separation", 16)
    stat_row.add_theme_constant_override("v_separation", 8)
    top.add_child(stat_row)

    for stat_name in stats.keys():
        stat_row.add_child(_make_stat_widget(stat_name))

    card_panel = PanelContainer.new()
    card_panel.custom_minimum_size = CARD_SIZE
    card_panel.gui_input.connect(_on_card_input)
    card_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    card_panel.add_theme_stylebox_override("panel", _style(Color(0.86, 0.84, 0.75), Color(0.20, 0.16, 0.12), 3, 8))
    add_child(card_panel)

    var inside := VBoxContainer.new()
    inside.add_theme_constant_override("separation", 18)
    inside.set_anchors_preset(Control.PRESET_FULL_RECT)
    inside.offset_left = 26
    inside.offset_right = -26
    inside.offset_top = 24
    inside.offset_bottom = -24
    card_panel.add_child(inside)

    illustration = preload("res://scripts/card_illustration.gd").new()
    illustration.custom_minimum_size = Vector2(0, 210)
    inside.add_child(illustration)

    title_label = Label.new()
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title_label.add_theme_font_size_override("font_size", 30)
    title_label.add_theme_color_override("font_color", Color(0.09, 0.075, 0.06))
    inside.add_child(title_label)

    body_label = Label.new()
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    body_label.clip_text = true
    body_label.add_theme_font_size_override("font_size", 22)
    body_label.add_theme_color_override("font_color", Color(0.13, 0.11, 0.09))
    body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    inside.add_child(body_label)

    var choice_row := HBoxContainer.new()
    choice_row.add_theme_constant_override("separation", 14)
    inside.add_child(choice_row)

    var left_choice = _choice_widget(Color(0.22, 0.35, 0.55))
    var right_choice = _choice_widget(Color(0.54, 0.18, 0.14))
    left_label = left_choice.get_node("Text")
    right_label = right_choice.get_node("Text")
    choice_row.add_child(left_choice)
    choice_row.add_child(right_choice)

    hint_label = Label.new()
    hint_label.text = "拖动卡片：左滑或右滑作出判决"
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.add_theme_font_size_override("font_size", 16)
    hint_label.add_theme_color_override("font_color", Color(0.54, 0.48, 0.39))
    inside.add_child(hint_label)

    outcome_label = Label.new()
    outcome_label.text = ""
    outcome_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    outcome_label.offset_left = 80
    outcome_label.offset_right = -80
    outcome_label.offset_top = -76
    outcome_label.offset_bottom = -22
    outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    outcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outcome_label.add_theme_font_size_override("font_size", 18)
    outcome_label.add_theme_color_override("font_color", Color(0.82, 0.91, 0.88))
    add_child(outcome_label)

    restart_button = Button.new()
    restart_button.text = "重新执镰"
    restart_button.visible = false
    restart_button.custom_minimum_size = Vector2(170, 46)
    restart_button.pressed.connect(_restart)
    restart_button.add_theme_font_size_override("font_size", 18)
    add_child(restart_button)

func _make_stat_widget(stat_name):
    var panel := PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_theme_stylebox_override("panel", _style(Color(0.09, 0.10, 0.12, 0.86), Color(0.24, 0.29, 0.30), 1, 6))

    var box := VBoxContainer.new()
    box.offset_left = 10
    box.offset_right = -10
    box.offset_top = 8
    box.offset_bottom = -8
    panel.add_child(box)

    var label := Label.new()
    label.text = stat_name
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 16)
    label.add_theme_color_override("font_color", Color(0.84, 0.88, 0.83))
    box.add_child(label)

    var bar := ProgressBar.new()
    bar.min_value = 0
    bar.max_value = 100
    bar.value = stats[stat_name]
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0, 12)
    box.add_child(bar)
    stat_bars[stat_name] = bar
    return panel

func _choice_widget(color):
    var panel := PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.custom_minimum_size = Vector2(0, 74)
    panel.add_theme_stylebox_override("panel", _style(color, Color(0, 0, 0, 0), 0, 6))

    var label := Label.new()
    label.name = "Text"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", Color.WHITE)
    panel.add_child(label)
    return panel

func _style(fill, border, width, radius):
    var box := StyleBoxFlat.new()
    box.bg_color = fill
    box.border_color = border
    box.set_border_width_all(width)
    box.set_corner_radius_all(radius)
    return box

func _position_card():
    if not card_panel:
        return
    var card_w = min(CARD_SIZE.x, size.x - 36)
    var card_h = min(CARD_SIZE.y, size.y - 188)
    card_panel.size = Vector2(card_w, card_h)
    card_home = Vector2((size.x - card_w) * 0.5, max(150.0, (size.y - card_h) * 0.5 + 30.0))
    card_panel.position = card_home
    card_panel.pivot_offset = card_panel.size * 0.5
    restart_button.position = Vector2((size.x - restart_button.custom_minimum_size.x) * 0.5, size.y - 84)
    _apply_responsive_type()

func _on_card_input(event):
    if game_ended or resolving:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            dragging = true
            drag_start = get_global_mouse_position()
            card_panel.scale = Vector2(1.02, 1.02)
        else:
            _release_card()
    elif event is InputEventMouseMotion and dragging:
        _drag_to(get_global_mouse_position())
    elif event is InputEventScreenTouch:
        if event.pressed:
            dragging = true
            drag_start = event.position
            card_panel.scale = Vector2(1.02, 1.02)
        else:
            _release_card()
    elif event is InputEventScreenDrag and dragging:
        _drag_to(event.position)

func _drag_to(pointer):
    var delta = pointer - drag_start
    card_panel.position = card_home + Vector2(delta.x, delta.y * 0.16)
    card_panel.rotation = deg_to_rad(clamp(delta.x / SWIPE_THRESHOLD, -1.0, 1.0) * 8.0)
    var bias = clamp(delta.x / SWIPE_THRESHOLD, -1.0, 1.0)
    left_label.modulate.a = 0.35 + max(-bias, 0.0) * 0.65
    right_label.modulate.a = 0.35 + max(bias, 0.0) * 0.65
    illustration.pulse(bias)

func _release_card():
    if not dragging or resolving:
        return
    dragging = false
    var delta_x = card_panel.position.x - card_home.x
    if abs(delta_x) >= SWIPE_THRESHOLD:
        _commit_choice(delta_x > 0)
    else:
        var tween := create_tween()
        tween.set_parallel(true)
        tween.tween_property(card_panel, "position", card_home, 0.18).set_trans(Tween.TRANS_SINE)
        tween.tween_property(card_panel, "rotation", 0.0, 0.18).set_trans(Tween.TRANS_SINE)
        tween.tween_property(card_panel, "scale", Vector2.ONE, 0.18)
        tween.tween_property(left_label, "modulate:a", 1.0, 0.18)
        tween.tween_property(right_label, "modulate:a", 1.0, 0.18)

func _commit_choice(is_right):
    if resolving:
        return
    resolving = true
    var choice = current_card["right"] if is_right else current_card["left"]
    var end_x = size.x + 280 if is_right else -card_panel.size.x - 280
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(card_panel, "position:x", end_x, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
    tween.tween_property(card_panel, "rotation", deg_to_rad(18 if is_right else -18), 0.24)
    tween.tween_property(card_panel, "modulate:a", 0.0, 0.20)
    await tween.finished
    _apply_choice(choice)

func _apply_choice(choice):
    for key in choice["effect"].keys():
        stats[key] = clamp(stats[key] + choice["effect"][key], 0, 100)
    outcome_label.text = choice["outcome"]
    _update_stats()

    var ending = _ending_text()
    if ending != "":
        _end_game(ending)
        return

    current_index += 1
    year += 1
    if current_index >= deck.size():
        _add_late_game_cards()
    await get_tree().create_timer(0.28).timeout
    _show_card(deck[current_index])

func _show_card(card):
    resolving = false
    current_card = card
    year_label.text = "第 %d 夜" % year
    omen_label.text = _omen()
    var visual = _visual_for_card(card["title"])
    world_bg.set_visual(visual)
    illustration.set_visual(visual)
    title_label.text = card["title"]
    body_label.text = card["body"]
    left_label.text = "左滑处死\n" + card["left"]["target"]
    right_label.text = "右滑处死\n" + card["right"]["target"]
    left_label.modulate.a = 1.0
    right_label.modulate.a = 1.0
    card_panel.position = card_home
    card_panel.rotation = 0.0
    card_panel.scale = Vector2.ONE
    card_panel.modulate.a = 1.0
    _apply_responsive_type()

func _update_stats():
    for key in stats.keys():
        stat_bars[key].value = stats[key]

func _ending_text():
    if stats["秩序"] <= 0:
        return "结局：城邦撕碎了法典。亡魂不再排队，它们撞开冥河，连你的渡船也开始漏水。"
    if stats["秩序"] >= 100:
        return "结局：世界像钟表一样服从死亡。没有哭声，也没有选择，只剩完美而空洞的寂静。"
    if stats["恐惧"] <= 0:
        return "结局：凡人不再怕你。他们把墓碑改成餐桌，把审判厅改成剧院。死神被迫退休。"
    if stats["恐惧"] >= 100:
        return "结局：恐惧吞掉了梦。活人提前为自己下葬，冥界反而收不到新故事。"
    if stats["怜悯"] <= 0:
        return "结局：你的镰刀从不迟疑，于是世界学会了从不求饶。最后一盏灯自己熄灭了。"
    if stats["怜悯"] >= 100:
        return "结局：你赦免了太多罪，也宽待了太多债。冥河涨满，彼岸失去重量。"
    if stats["冥币"] <= 0:
        return "结局：冥府破产。摆渡人罢工，亡魂挤在河岸，没人愿意收你的死亡通知书。"
    if stats["冥币"] >= 100:
        return "结局：每一次死亡都被标价。你成了账本的奴仆，而不是命运的主人。"
    return ""

func _end_game(text):
    game_ended = true
    resolving = false
    title_label.text = "审判终局"
    var end_visual = {
        "scene": "court",
        "person": "reaper",
        "accent": Color(0.72, 0.92, 0.86),
        "sky": Color(0.08, 0.09, 0.11),
        "ground": Color(0.14, 0.12, 0.12)
    }
    world_bg.set_visual(end_visual)
    illustration.set_visual(end_visual)
    body_label.text = text
    left_label.text = "这不是失败"
    right_label.text = "只是另一个传说"
    hint_label.text = "你的死神统治持续了 %d 夜" % year
    outcome_label.text = "点击下方按钮重新开始。"
    restart_button.visible = true
    card_panel.position = card_home
    card_panel.rotation = 0.0
    card_panel.scale = Vector2.ONE
    card_panel.modulate.a = 1.0

func _restart():
    stats = {"秩序": 50, "恐惧": 36, "怜悯": 42, "冥币": 30}
    current_index = 0
    year = 1
    game_ended = false
    resolving = false
    outcome_label.text = ""
    restart_button.visible = false
    _build_deck()
    _update_stats()
    _show_card(deck[current_index])

func _unhandled_input(event):
    if game_ended or resolving:
        return
    if event.is_action_pressed("ui_left"):
        _commit_choice(false)
    elif event.is_action_pressed("ui_right"):
        _commit_choice(true)

func _omen():
    if stats["恐惧"] > 70:
        return "窗户紧闭，祈祷声很轻"
    if stats["怜悯"] > 70:
        return "亡魂学会了喊你的名字"
    if stats["冥币"] < 18:
        return "摆渡人敲着空钱袋"
    if stats["秩序"] < 25:
        return "法官们开始梦游"
    return "亡者排队，生者等候"

func _apply_responsive_type():
    if not card_panel or not title_label or not body_label or not left_label or not illustration:
        return
    var compact = card_panel.size.y < 520 or card_panel.size.x < 460
    title_label.add_theme_font_size_override("font_size", 25 if compact else 30)
    body_label.add_theme_font_size_override("font_size", 18 if compact else 22)
    left_label.add_theme_font_size_override("font_size", 16 if compact else 18)
    right_label.add_theme_font_size_override("font_size", 16 if compact else 18)
    hint_label.add_theme_font_size_override("font_size", 14 if compact else 16)
    illustration.custom_minimum_size = Vector2(0, 150 if compact else 210)

func _visual_for_card(title):
    match title:
        "黑麦田的饥荒":
            return {"scene": "field", "person": "noble", "accent": Color(0.92, 0.72, 0.24), "sky": Color(0.13, 0.13, 0.11), "ground": Color(0.28, 0.22, 0.10)}
        "瘟疫医生的面具":
            return {"scene": "plague", "person": "doctor", "accent": Color(0.62, 0.86, 0.68), "sky": Color(0.11, 0.17, 0.16), "ground": Color(0.13, 0.16, 0.13)}
        "银矿下的歌声":
            return {"scene": "mine", "person": "miner", "accent": Color(0.95, 0.68, 0.22), "sky": Color(0.08, 0.09, 0.11), "ground": Color(0.18, 0.16, 0.14)}
        "王后的第七个梦":
            return {"scene": "palace", "person": "queen", "accent": Color(0.86, 0.70, 0.96), "sky": Color(0.13, 0.10, 0.22), "ground": Color(0.23, 0.17, 0.30)}
        "无名军团":
            return {"scene": "war", "person": "soldier", "accent": Color(0.76, 0.08, 0.07), "sky": Color(0.20, 0.16, 0.13), "ground": Color(0.18, 0.16, 0.13)}
        "金杯里的毒":
            return {"scene": "market", "person": "merchant", "accent": Color(0.95, 0.74, 0.34), "sky": Color(0.24, 0.15, 0.12), "ground": Color(0.23, 0.13, 0.09)}
        "墓园里的婚礼":
            return {"scene": "grave", "person": "bride", "accent": Color(0.84, 0.92, 0.86), "sky": Color(0.08, 0.14, 0.15), "ground": Color(0.13, 0.17, 0.15)}
        "孩子们的黑船":
            return {"scene": "boat", "person": "orphan", "accent": Color(0.52, 0.72, 0.92), "sky": Color(0.06, 0.10, 0.17), "ground": Color(0.06, 0.11, 0.17)}
        "机械圣徒":
            return {"scene": "forge", "person": "saint", "accent": Color(0.60, 0.86, 0.95), "sky": Color(0.15, 0.13, 0.15), "ground": Color(0.18, 0.12, 0.10)}
        "最后一张赦令":
            return {"scene": "court", "person": "warden", "accent": Color(0.78, 0.72, 0.56), "sky": Color(0.12, 0.12, 0.16), "ground": Color(0.17, 0.15, 0.13)}
        "冥河涨潮":
            return {"scene": "boat", "person": "reaper", "accent": Color(0.50, 0.88, 0.88), "sky": Color(0.04, 0.09, 0.13), "ground": Color(0.05, 0.10, 0.15)}
        "你的影子":
            return {"scene": "court", "person": "reaper", "accent": Color(0.45, 0.48, 0.90), "sky": Color(0.07, 0.06, 0.10), "ground": Color(0.10, 0.08, 0.10)}
        _:
            return {"scene": "court", "person": "reaper", "accent": Color(0.72, 0.92, 0.86), "sky": Color(0.12, 0.15, 0.18), "ground": Color(0.20, 0.18, 0.14)}

func _build_deck():
    deck = [
        _card("黑麦田的饥荒", "粮仓只够撑过一个冬天。贵族囤粮，饥民抢粮，两个队伍都站在你的门前。", "囤粮贵族", {"秩序": -8, "恐惧": 10, "怜悯": 8, "冥币": 6}, "粮仓打开了，但贵族开始雇佣刺客研究永生。", "抢粮饥民", {"秩序": 10, "恐惧": 8, "怜悯": -12, "冥币": 4}, "街道安静了，面包也安静了。"),
        _card("瘟疫医生的面具", "一群医生隐瞒了病源，另一群病人拒绝隔离。活人的哭声挤满审判厅。", "隐瞒病源的医生", {"秩序": -5, "恐惧": 12, "怜悯": 4, "冥币": 8}, "真相被钉在城门上，药箱旁多了几支白花。", "拒绝隔离的病人", {"秩序": 12, "恐惧": 9, "怜悯": -10, "冥币": 7}, "瘟疫止住脚步，幸存者不再直视你的眼睛。"),
        _card("银矿下的歌声", "矿主把矿工锁进塌方的坑道，矿工首领则准备炸掉整座山。", "贪婪矿主", {"秩序": -7, "恐惧": 8, "怜悯": 7, "冥币": -8}, "矿井归还给黑暗，穷人第一次为死亡鼓掌。", "暴动矿工", {"秩序": 11, "恐惧": 7, "怜悯": -8, "冥币": 10}, "银脉继续流动，只是歌声从此变低。"),
        _card("王后的第七个梦", "王后梦见七名婴儿会推翻王权。占星师说梦是真的，产婆说梦是谎言。", "占星师", {"秩序": -4, "恐惧": -8, "怜悯": 7, "冥币": -3}, "星图被烧成灰，孩子们暂时只需要学会走路。", "七名婴儿", {"秩序": 12, "恐惧": 16, "怜悯": -18, "冥币": 9}, "王座稳了，摇篮空了。"),
        _card("无名军团", "前线需要一个替罪者。将军要求处决逃兵，逃兵指认将军故意送他们赴死。", "屠城将军", {"秩序": -10, "恐惧": 11, "怜悯": 8, "冥币": 5}, "军旗降半，士兵们第一次把活着当成命令。", "逃兵", {"秩序": 10, "恐惧": 8, "怜悯": -8, "冥币": 5}, "军纪回到营帐，梦魇也回到枕边。"),
        _card("金杯里的毒", "商会用毒酒清理竞争者，乞丐团偷走解药换取赎金。两边都说自己只是求生。", "商会会长", {"秩序": -6, "恐惧": 7, "怜悯": 5, "冥币": -10}, "市场失去主人，价格像幽灵一样乱飘。", "乞丐团首领", {"秩序": 8, "恐惧": 8, "怜悯": -7, "冥币": 8}, "解药回来了，街角的手少了一双。"),
        _card("墓园里的婚礼", "新娘用禁术唤回亡夫，牧师召集村民准备烧死所有见证者。", "禁术新娘", {"秩序": 9, "恐惧": 7, "怜悯": -6, "冥币": 8}, "婚纱没有染上泥土，爱情却被重新埋好。", "狂热牧师", {"秩序": -8, "恐惧": -6, "怜悯": 9, "冥币": -4}, "火刑架拆了，村民开始害怕自己的梦。"),
        _card("孩子们的黑船", "孤儿们偷船逃离征税，税吏说没有钱冥河的桥就会断。", "税吏", {"秩序": -9, "恐惧": -4, "怜悯": 9, "冥币": -12}, "孩子们驶向雾里，账本少了一页。", "偷船孤儿", {"秩序": 8, "恐惧": 8, "怜悯": -14, "冥币": 10}, "桥还在，海面少了笑声。"),
        _card("机械圣徒", "工匠造出不会死的圣徒，修士认为这是亵渎；工匠认为这是终结你的统治。", "造圣徒的工匠", {"秩序": 6, "恐惧": 12, "怜悯": -4, "冥币": 8}, "机器停止呼吸，人们重新记起死亡的重量。", "焚工坊的修士", {"秩序": -7, "恐惧": -6, "怜悯": 6, "冥币": -6}, "齿轮继续转动，祷告变得更像说明书。"),
        _card("最后一张赦令", "老国王临终前签下大赦，监狱长却说里面关着会毁掉王国的人。", "监狱长", {"秩序": -10, "恐惧": -5, "怜悯": 11, "冥币": -5}, "铁门打开，风也带着罪名离开。", "死囚们", {"秩序": 13, "恐惧": 10, "怜悯": -10, "冥币": 9}, "王国安全了，赦令像一片枯叶落地。")
    ]
    deck.shuffle()

func _card(title, body, left_target, left_effect, left_outcome, right_target, right_effect, right_outcome):
    return {
        "title": title,
        "body": body,
        "left": {
            "target": left_target,
            "effect": left_effect,
            "outcome": left_outcome
        },
        "right": {
            "target": right_target,
            "effect": right_effect,
            "outcome": right_outcome
        }
    }

func _add_late_game_cards():
    var late_cards := [
        _card("冥河涨潮", "亡魂太多，摆渡人要求牺牲一座村庄来换船；村庄愿意献出摆渡人。", "摆渡人", {"秩序": -8, "恐惧": -8, "怜悯": 8, "冥币": -14}, "船桨沉进水里，亡魂开始自己游泳。", "河岸村民", {"秩序": 9, "恐惧": 14, "怜悯": -13, "冥币": 12}, "船队重新启程，岸边只剩湿冷的灯。"),
        _card("你的影子", "你的影子学会独立审判。它处死人不问理由，祭司们却已经开始崇拜它。", "死神的影子", {"秩序": -6, "恐惧": -10, "怜悯": 7, "冥币": -8}, "影子缩回脚下，但每个黄昏都更长了一点。", "崇影祭司", {"秩序": 7, "恐惧": 12, "怜悯": -8, "冥币": 8}, "神殿安静了，影子却笑得更像你。")
    ]
    deck.append_array(late_cards)
    deck.shuffle()
    current_index = 0
