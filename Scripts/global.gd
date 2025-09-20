extends Node
var adjectives = ["Verrin", "Drosk", "Mairuth", "Chyrel", "Onvath"]
var nouns = ["Grathul", "Pelmor", "Skendril", "Thundrith", "Canoth"]
var onTable = -1
var NPC_Visits = [false, false, false]
var noun_key: int
var money: int = 0
var landlord: bool = false
var landlordRequirement: float = 100

func _ready():
	randomize()
	adjectives.shuffle()
	nouns.shuffle()

var dialog = {
	"0" = ["My Jagol is craving a NOUN"],
	"1" = ["Urg just get me a NOUN!"],
	"2" = ["Hello! Your new here right? can I just have a NOUN please!"],
	"NPCG" = ["Please may I have NOUN in ADJ", "That NOUN looks cool!", "Do you have anything in ADJ?", "I DEMAND NOUN", "Hey Cutie got any NOUN?"]
}
