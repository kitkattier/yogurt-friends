class_name Hud
extends CanvasLayer

@onready var time_label: Label = $MarginContainer/HBoxContainer/TimeLabel
@onready var money_label: Label = $MarginContainer/HBoxContainer/MoneyLabel

func update_time(seconds_left: float) -> void:
	var total_seconds: int = int(ceil(seconds_left))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	time_label.text = "%d:%02d" % [minutes, seconds]

func update_money(amount: int) -> void:
	money_label.text = "$%d" % amount
