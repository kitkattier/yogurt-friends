class_name Hud
extends CanvasLayer

@onready var time_label: Label = $MarginContainer/HBoxContainer/TimeLabel
@onready var money_label: Label = $MarginContainer/HBoxContainer/MoneyLabel
@onready var yogurt_icon: TextureRect = $MarginContainer/HBoxContainer/TextureRect

func update_time(seconds_left: float) -> void:
	var total_seconds: int = int(ceil(seconds_left))
	if total_seconds == 0:
		time_label.text = "0:00"
		return
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	time_label.text = "%d:%02d" % [minutes, seconds]

func update_money(amount: int) -> void:
	money_label.text = "$%d" % (amount * 5_000_000)

func update_yogurt(amount: int) -> void:
	var silhouette: bool = amount == 0
	yogurt_icon.modulate = Color.BLACK if silhouette else Color.WHITE
