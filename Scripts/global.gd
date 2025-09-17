extends Node
var adjectives = ["Verrin", "Drosk", "Mairuth", "Chyrel", "Onvath"]
var nouns = ["Grathul", "Pelmor", "Skendril", "Vornek", "Tralyth"]

func _ready():
	randomize()
	adjectives.shuffle()
	nouns.shuffle()
