extends Node

const MAX_PLAYERS: int = 4
var player_list: Array 

const SKINS_AMOUNT: int = 9
var skins_available_array: Array = []
var skins_available: int = 0


func initialize_skin_array(count: int) -> void:
	skins_available_array.clear()
	skins_available = 0
	for i in range(0, count):
		skins_available_array.append(i)
		skins_available += 1
	#print(skins_available_array)


func remove_skin(index: int) -> void:
	skins_available_array.erase(index)
	skins_available_array.sort()
	skins_available -= 1
	#print(skins_available_array)


func add_skin(index: int) -> void:
	skins_available_array.append(index)
	skins_available_array.sort()
	skins_available += 1
	#print(skins_available_array)


func reset() -> void:
	player_list.clear()
	initialize_skin_array(SKINS_AMOUNT)


func play_audio(audio: Node, initial_pitch: float, pitch_lower: float, pitch_upper: float) -> void:
	var value: float = initial_pitch + rand_range(pitch_lower, pitch_upper)
	audio.set_pitch_scale(value) 
	audio.play()


func wrap(value: int, min_: int, max_: int) -> int:
	var size: int = (max_ - min_) + 1
	if (value > max_):
		return int(value % size)
	if (value < min_):
		return int(max_ - ((int(abs(value - min_)) % size))) + 1
	return value 
