extends MultiMeshInstance3D

var numberInput : int = 0
var numberOutput : int = 0

var weightStart : Array = []
var biasStart : Array = []
var tab : PackedVector4Array = []

@export var obW : float = -1.0 # Kontroluje weight[1]
@export var obU : float = -1.0 # Kontroluje weight[2]

func _ready() -> void:
	initNN(3, 1)
	ustaw_material_w_kodzie()
	odswiez_wykres()

func _process(delta: float) -> void:
	var zmieniono : bool = false

	if Input.is_key_pressed(KEY_Z):
		obW += 0.5 * delta
		zmieniono = true
	if Input.is_key_pressed(KEY_X):
		obW -= 0.5 * delta
		zmieniono = true

	if Input.is_key_pressed(KEY_B):
		obU += 0.5 * delta
		zmieniono = true
	if Input.is_key_pressed(KEY_N):
		obU -= 0.5 * delta
		zmieniono = true

	if zmieniono:
		obW = clamp(obW, -1.0, 1.0)
		obU = clamp(obU, -1.0, 1.0)
		odswiez_wykres()


func odswiez_wykres() -> void:
	tab.clear()
	calculate(weightStart, biasStart)
	render()

func initNN(inputCount : int, outputCount :int) -> void:
	numberInput = inputCount
	numberOutput = outputCount
	for i in range(numberInput*numberOutput):
		weightStart.append(-1.0)
	for i in range(numberOutput):
		biasStart.append(-1.0)

func calculate(weightS : Array, biasS : Array):
	var weight = weightS.duplicate()
	var bias = biasS.duplicate()

	weight[1] = obW
	weight[2] = obU

	for wOne in range(20):
		bias[0] = biasS[0]
		for biass in range(20):
			var loss = calculateMedianLoss(weight, bias)

			tab.append(Vector4(weight[0], loss, bias[0], loss))
			bias[0] += 0.1
		weight[0] += 0.1

func render() -> void:
	multimesh.instance_count = tab.size()

	if multimesh.use_colors == false:
		multimesh.use_colors = true

	for i in range(tab.size()):
		var tra : Transform3D = Transform3D.IDENTITY
		tra.origin = Vector3(tab[i][0] * 5.0, tab[i][1] * 2.0, tab[i][2] * 5.0)
		multimesh.set_instance_transform(i, tra)

	
		var current_loss = abs(tab[i][3])
		var kolor = Color.GREEN.lerp(Color.RED, clamp(current_loss, 0.0, 1.0))
		kolor.a = 1.0 # USUNIĘTO PRZEZROCZYSTOŚĆ (100% krycia)

		multimesh.set_instance_color(i, kolor)

func calculateMedianLoss(weights : Array, bias: Array) -> float:
	var loss : float = 0.0
	for i in range(7):
		var bin_str = String.num_int64(i+1, 2)
		while bin_str.length() < 3:
			bin_str = "0" + bin_str

		var input : Array = Array(bin_str.to_ascii_buffer()).map(func(x): return x - 48)
		loss += abs(calculateLossFor(input, weights, bias))
	loss = loss / 7.0
	return loss

func calculateLossFor(input : Array, weights : Array, bias : Array) -> float:
	var string_elements = []
	for element in input:
		string_elements.append(str(element))

	var inputDz = ''.join(string_elements)
	inputDz = inputDz.bin_to_int()

	var output : float = calculateSumFor(input, weights, bias)

	var loss : float = 0.0
	if inputDz % 2 == 0:
		inputDz = 1
	else:
		inputDz = -1

	loss = inputDz - output
	return loss

func calculateSumFor(input : Array, weights : Array, bias : Array) -> float:
	var sum : float = 0
	for i in range(weights.size()):
		sum += input[i] * weights[i]

	sum += bias[0]
	return sum

func ustaw_material_w_kodzie() -> void:
	if multimesh and multimesh.mesh:
		var mat = StandardMaterial3D.new()
		mat.transparency = StandardMaterial3D.TRANSPARENCY_DISABLED # Wymuszenie braku przezroczystości
		mat.vertex_color_use_as_albedo = true
		multimesh.mesh.material = mat

#przeredagowany wygląd przez geminaja (dodał mi super fajne kolorki :P
