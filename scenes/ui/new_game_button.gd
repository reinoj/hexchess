extends Button

func _on_pressed():
	SignalBus.new_game.emit()
