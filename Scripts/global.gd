extends Node
var adjectives = ["Verrin", "Drosk", "Mairuth", "Chyrel", "Onvath"]
var nouns = ["Grathul", "Pelmor", "Skendril"]
var onTable = [-1,-1]
var noun_key: int
var adj_key: int
var money: int = 0
var landlord: bool = false
var landlordRequirement: float = 100
#func _ready():
#	randomize()
#	adjectives.shuffle()
#	nouns.shuffle()
