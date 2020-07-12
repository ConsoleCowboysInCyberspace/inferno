extends ProgressBar

onready var timer = $Timer

func _ready():
	visible = false

func onDigAmountChanged(newValue):
	print("digamount ", newValue)
	
	if newValue == 0:
		visible = false
	elif newValue == 100:
		timer.start()
	else:
		value = newValue
	
	if not visible and newValue > 0:
		visible = true

func onTimerTimeout():
	visible = false
