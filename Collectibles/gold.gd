extends Area2D




func _on_body_entered(body):
	if body.name == 'Player':
		var tween1 = get_tree().create_tween()
		tween1.tween_property(self, "position", position - Vector2(0, 100), 0.5)
		
		var tween2 = get_tree().create_tween()
		tween2.tween_property(self, "modulate:a", 0, 0.5)
		
		await tween1.finished
		await tween2.finished
		
		body.coins += 1
		queue_free()
