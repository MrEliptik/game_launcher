## https://github.com/Greaby/godot-qrcode-generator
class_name QrCode
extends Node


enum Encodings {NUMERIC, ALPHANUMERIC, KANJI, BYTES}

enum ErrorCorrectionLevel {
	LOW = 0,
	MEDIUM = 1,
	QUARTILE = 2,
	HIGH = 3,
}

const ERROR_CORRECT_LEVEL_BITS = {
	ErrorCorrectionLevel.LOW: 1,
	ErrorCorrectionLevel.MEDIUM: 0,
	ErrorCorrectionLevel.QUARTILE: 3,
	ErrorCorrectionLevel.HIGH: 2,
}

const MAX_CAPACTITY = {
	ErrorCorrectionLevel.LOW : [
		19,34,55,80,108,136,156,194,232,274,324,370,428,461,523,589,
		647,721,795,861,932,1006,1094,1174,1276,1370,1468,1531,1631,
		1735,1843,1955,2071,2191,2306,2434,2566,2702,2812,2956
	],
	ErrorCorrectionLevel.MEDIUM : [
		16,28,44,64,86,108,124,154,182,216,254,290,334,365,415,453,
		507,563,627,669,714,782,860,914,1000,1062,1128,1193,1267,
		1373,1455,1541,1631,1725,1812,1914,1992,2102,2216,2334
	],
	ErrorCorrectionLevel.QUARTILE: [
		13,22,34,48,62,76,88,110,132,154,180,206,244,261,295,325,
		367,397,445,485,512,568,614,664,718,754,808,871,911,985,
		1033,1115,1171,1231,1286,1354,1426,1502,1582,1666
	],
	ErrorCorrectionLevel.HIGH: [
		9,16,26,36,46,60,66,86,100,122,140,158,180,197,223,253,283,
		313,341,385,406,442,464,514,538,596,628,661,701,745,793,845,
		901,961,986,1054,1096,1142,1222,1276
	]
}

const LENGTH_INFO_BITS = {
	Encodings.NUMERIC : [10,12,14],
	Encodings.ALPHANUMERIC : [9,11,13],
	Encodings.KANJI : [8,10,12],
	Encodings.BYTES : [8,16,16],
}

const ENCODING_INFO_BITS = {
	Encodings.NUMERIC : [false, false, false, true],
	Encodings.ALPHANUMERIC: [false, false, true, false],
	Encodings.KANJI: [true, false, false, false],
	Encodings.BYTES: [false, true, false, false],
}

const ECC_CODEWORDS_PER_BLOCK: Dictionary = {
	ErrorCorrectionLevel.LOW : [
		7,10,15,20,26,18,20,24,30,18,20,24,26,30,22,24,28,30,28,28,
		28,28,30,30,26,28,30,30,30,30,30,30,30,30,30,30,30,30,30,30,
	],
	ErrorCorrectionLevel.MEDIUM: [
		10,16,26,18,24,16,18,22,22,26,30,22,22,24,24,28,28,26,26,26,
		26,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,
	],
	ErrorCorrectionLevel.QUARTILE: [
		13,22,18,26,18,24,18,22,20,24,28,26,24,20,30,24,28,28,26,30,
		28,30,30,30,30,28,30,30,30,30,30,30,30,30,30,30,30,30,30,30,
	],
	ErrorCorrectionLevel.HIGH: [
		17,28,22,16,22,28,26,26,24,28,24,28,22,24,24,30,28,28,26,28,
		30,24,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,
	],
}

const NUM_ERROR_CORRECTION_BLOCKS: Dictionary = {
	ErrorCorrectionLevel.LOW : [
		1,1,1,1,1,2,2,2,2,4,4,4,4,4,6,6,6,6,7,8,8,9,9,10,
		12,12,12,13,14,15,16,17,18,19,19,20,21,22,24,25,
	],
	ErrorCorrectionLevel.MEDIUM: [
		1,1,1,2,2,4,4,4,5,5,5,8,9,9,10,10,11,13,14,16,17,17,
		18,20,21,23,25,26,28,29,31,33,35,37,38,40,43,45,47,49,
	],
	ErrorCorrectionLevel.QUARTILE: [
		1,1,2,2,4,4,6,6,8,8,8,10,12,16,12,17,16,18,21,20,23,23,
		25,27,29,34,34,35,38,40,43,45,48,51,53,56,59,62,65,68,
	],
	ErrorCorrectionLevel.HIGH: [
		1,1,2,4,4,4,5,6,8,8,11,11,16,16,18,16,19,21,25,25,25,34,
		30,32,35,37,40,42,45,48,51,54,57,60,63,66,70,74,77,81,
	],
}

const ALIGNMENT_PATTERNS = [
		[],
		[6, 18],
		[6, 22],
		[6, 26],
		[6, 30],
		[6, 34],
		[6, 22, 38],
		[6, 24, 42],
		[6, 26, 46],
		[6, 28, 50],
		[6, 30, 54],
		[6, 32, 58],
		[6, 34, 62],
		[6, 26, 46, 66],
		[6, 26, 48, 70],
		[6, 26, 50, 74],
		[6, 30, 54, 78],
		[6, 30, 56, 82],
		[6, 30, 58, 86],
		[6, 34, 62, 90],
		[6, 28, 50, 72, 94],
		[6, 26, 50, 74, 98],
		[6, 30, 54, 78, 102],
		[6, 28, 54, 80, 106],
		[6, 32, 58, 84, 110],
		[6, 30, 58, 86, 114],
		[6, 34, 62, 90, 118],
		[6, 26, 50, 74, 98, 122],
		[6, 30, 54, 78, 102, 126],
		[6, 26, 52, 78, 104, 130],
		[6, 30, 56, 82, 108, 134],
		[6, 34, 60, 86, 112, 138],
		[6, 30, 58, 86, 114, 142],
		[6, 34, 62, 90, 118, 146],
		[6, 30, 54, 78, 102, 126, 150],
		[6, 24, 50, 76, 102, 128, 154],
		[6, 28, 54, 80, 106, 132, 158],
		[6, 32, 58, 84, 110, 136, 162],
		[6, 26, 54, 82, 110, 138, 166],
		[6, 30, 58, 86, 114, 142, 170],
	]

const TERMINATOR_BITS = [false, false, false, false]

const PADDING_BITS = [
	[true,true,true,false,true,true,false,false],
	[false,false,false,true,false,false,false,true],
]

var error_correct_level = ErrorCorrectionLevel.LOW

var type_number : int = 1

var encoding = Encodings.BYTES

var module_count : int = 0

var modules : Array = []

var qr_data_list : Array = []
var ecc_data_list : Array = []

var qr_data_length : int = 0


func get_data(input: String) -> Array:
	var mask_pattern: int = _get_mask_pattern(input)
	return generate(input, mask_pattern)


func get_texture(input: String) -> ImageTexture:
	var data: Array = get_data(input)
	return _generate_texture_image(data)

func get_num_raw_data_modules(ver: int) ->  int:
		var result: int = (16 * ver + 128) * ver + 64
		if ver >= 2:
			var num_align: int = floor(ver / 7) + 2
			result -= (25 * num_align - 10) * num_align - 55

		if ver >= 7:
			result -= 36

		return result


func generate(input: String, mask_pattern: int) -> Array:
	_set_encoding_type(input)

	_encode_data(input)

	_set_minimum_type_number()

	_set_info_segments()

	_split_data_into_blocks()

	_set_error_correction()

	module_count = type_number * 4 + 17

	modules = []
	for row in range(module_count):
		modules.insert(row , [])
		for col in range(module_count):
			modules[row].insert(col, null)

	_set_position_detection_pattern(0, 0)
	_set_position_detection_pattern(module_count - 7, 0)
	_set_position_detection_pattern(0, module_count - 7)

	_set_version_information()
	_set_alignment_pattern()
	_set_timing_pattern()

	_setup_type_info(mask_pattern)

	var zig_zag_positions = _get_data_zigzag_positions()
	_set_data(zig_zag_positions)

	_apply_mask_pattern(mask_pattern, zig_zag_positions)

	return modules


func _set_encoding_type(value: String) -> void:
	var byte_array = value.to_utf8_buffer()

	var is_numeric = true
	for byte in byte_array:
		is_numeric = is_numeric && byte >= 48 && byte <= 57

	if is_numeric:
		encoding = Encodings.NUMERIC
		return

	var is_alphanumeric = true
	for character in value:
		is_alphanumeric = is_alphanumeric && Utils.ALPHANUMERIC_CHARACTERS.has(character)

	if is_alphanumeric:
		encoding = Encodings.ALPHANUMERIC
		return

	encoding = Encodings.BYTES


func _encode_data(value: String) -> void:
	qr_data_length = len(value)

	match encoding:
		Encodings.NUMERIC:
			_encode_numeric(value)
		Encodings.ALPHANUMERIC:
			_encode_alphanumeric(value)
		Encodings.BYTES:
			_encode_bytes(value)
		Encodings.KANJI:
			_encode_kanji(value)


func _encode_numeric(value: String) -> void:
	qr_data_list = []
	var data = []
	for index in range(0, ceil(value.length() / 3.0)):
		data.append(value.substr(index * 3, 3).to_int())

	for index in data.size():
		var size = 10
		if data[index] < 100:
			size = 7

		if data[index] < 10:
			size = 4

		qr_data_list.append_array(Utils.convert_to_binary(data[index], size))


func _encode_alphanumeric(value: String) -> void:
	qr_data_list = []
	var data: Array = []
	for index in range(0, ceil(value.length() / 2.0)):
		var first_value: int = Utils.ALPHANUMERIC_CHARACTERS[value[index * 2]]
		var second_value: int = -1

		if index * 2 + 1 < value.length():
			second_value = Utils.ALPHANUMERIC_CHARACTERS[value[index * 2 + 1]]

		var result: Array
		if second_value != -1:
			result = Utils.convert_to_binary(first_value * 45 + second_value, 11)
		else:
			result = Utils.convert_to_binary(first_value, 6)

		qr_data_list.append_array(result)


func _encode_bytes(value: String) -> void:
	qr_data_list = []
	var byte_array = value.to_utf8_buffer()
	for byte in byte_array:
		qr_data_list.append_array(Utils.convert_to_binary(byte))


func _encode_kanji(_value: String) -> void:
	pass


func _set_minimum_type_number() -> void:
	var encoding_bits_size = len(ENCODING_INFO_BITS[encoding])

	for version in range(1, 41):
		var length_bits_size = _get_length_bits_size(version)

		var total_bits_size = encoding_bits_size + length_bits_size + qr_data_list.size()
		var total_bytes_size = ceil(total_bits_size / 8.0)

		if total_bytes_size <= MAX_CAPACTITY[error_correct_level][version - 1]:
			type_number = version
			return


func _get_length_bits_size(version: int) -> int:
	var length_bits_size = LENGTH_INFO_BITS[encoding][0]

	if version >= 10:
		length_bits_size = LENGTH_INFO_BITS[encoding][1]

	if version >= 27:
		length_bits_size = LENGTH_INFO_BITS[encoding][2]

	return length_bits_size


func _set_info_segments() -> void:
	var length_bits_size = _get_length_bits_size(type_number)
	var length_bits = Utils.convert_to_binary(qr_data_length, length_bits_size)

	qr_data_list = ENCODING_INFO_BITS[encoding] + length_bits + qr_data_list + TERMINATOR_BITS

	var max_capacity = MAX_CAPACTITY[error_correct_level][type_number - 1]

	if qr_data_list.size() / 8.0 > max_capacity:
		qr_data_list.resize(max_capacity * 8)
		return

	while qr_data_list.size() % 8 != 0:
		qr_data_list.append(false)

	var padding_bits: Array = PADDING_BITS.duplicate(true)

	while qr_data_list.size() / 8 < max_capacity:
		qr_data_list.append_array(padding_bits[0])
		padding_bits.reverse()


func _split_data_into_blocks() -> void:
	var num_blocks: int = NUM_ERROR_CORRECTION_BLOCKS[error_correct_level][type_number - 1]

	var block_ecc_len: int = ECC_CODEWORDS_PER_BLOCK[error_correct_level][type_number - 1]

	var raw_codewords: int = floor(get_num_raw_data_modules(type_number) / 8)
	var num_short_blocks: int = num_blocks - raw_codewords % num_blocks
	var short_block_len: int = floor(raw_codewords / num_blocks)

	var result: = []
	var off = 0

	for block_index in range(num_blocks):
		var end: int = off + (short_block_len - block_ecc_len + int(block_index >= num_short_blocks)) * 8

		var block: Array = qr_data_list.slice(off, end);

		result.push_back(block);
		off = end

	qr_data_list = result

func _set_error_correction() -> void:
	ecc_data_list = []
	var block_ecc_len: int = ECC_CODEWORDS_PER_BLOCK[error_correct_level][type_number - 1]
	var short_block_data_len: int = qr_data_list[0].size()

	var rs = ReedSolomonGenerator.new(block_ecc_len)

	for block_index in range(qr_data_list.size()):
		ecc_data_list.append([])
		var j = -1
		var block_bytes = []
		for index in qr_data_list[block_index].size():
			if index % 8 == 0:
				j += 1
				block_bytes.append([])
			block_bytes[j].append(qr_data_list[block_index][index])

		for index in block_bytes.size():
			block_bytes[index] = Utils.convert_to_decimal(block_bytes[index])

		block_bytes = rs.get_remainder(block_bytes)

		for byte in block_bytes:
			ecc_data_list[block_index].append_array(Utils.convert_to_binary(byte, 8))


func _apply_mask_pattern(mask_pattern: int, positions: Array) -> void:
	var invert: bool = false

	for position in positions:
		match mask_pattern:
			0:  invert = int(position.x + position.y) % 2 == 0
			1:  invert = int(position.y) % 2 == 0
			2:  invert = int(position.x) % 3 == 0
			3:  invert = int(position.x + position.y) % 3 == 0
			4:  invert = int(floor(position.x / 3) + floor(position.y / 2)) % 2 == 0
			5:  invert = int(position.x * position.y) % 2 + int(position.x * position.y) % 3 == 0
			6:  invert = (int(position.x * position.y) % 2 + int(position.x * position.y) % 3) % 2 == 0
			7:  invert = (int(position.x + position.y) % 2 + int(position.x * position.y) % 3) % 2 == 0

		if invert:
			modules[position.x][position.y] = !modules[position.x][position.y]


func _get_mask_pattern(input: String) -> int:
	var min_lost_point = 0
	var pattern = 0

	for index in range(8):
		generate(input, index)
		var lost_point = get_lost_point()

		if index == 0 or min_lost_point > lost_point:
			min_lost_point = lost_point
			pattern = index

	return pattern


func _set_position_detection_pattern(row, col) -> void:
	for r in range(-1, 8):
		for c in range(-1, 8):
			if row + r <= -1 or module_count <= row + r or col + c <= -1 or module_count <= col + c:
				continue

			modules[row + r][col + c] = (
				(0 <= r and r <= 6 and (c == 0 or c == 6) )
				or (0 <= c and c <= 6 and (r == 0 or r == 6) )
				or (2 <= r and r <= 4 and 2 <= c and c <= 4) )


func _set_alignment_pattern() -> void:
	var patterns = ALIGNMENT_PATTERNS[type_number - 1]

	for row in patterns:
		for col in patterns:
			if modules[row][col] != null:
				continue

			for x in range(-2, 3):
				for y in range(-2, 3):
					modules[row + x][col + y] = (
						x == -2 or x == 2 or y == -2 or y == 2
						or (x == 0 and y == 0))


func _set_timing_pattern() -> void:
	for index in range(8, module_count - 8):
		if modules[index][6] == null:
			modules[index][6] = index % 2 == 0

		if modules[6][index] == null:
			modules[6][index] = index % 2 == 0


func _set_version_information() -> void:
	if type_number < 7:
		return

	var rem: int = type_number

	for i in range(12):
		rem = (rem << 1) ^ ((rem >> 11) * 0x1F25)

	var bits: int = type_number << 12 | rem

	for index in range(18):
		var color: bool = ((bits >> index) & 1) != 0

		var a: int = modules.size() - 11 + index % 3
		var b: int = floor(index / 3)
		modules[a][b] = color
		modules[b][a] = color



func _setup_type_info(mask_pattern) -> void:
	var bits: int = 0;

	var data = (ERROR_CORRECT_LEVEL_BITS[error_correct_level] << 3) | mask_pattern

	var rem: int = data
	for i in range(10):
		rem = (rem << 1) ^ ((rem >> 9) * 0x537)
	bits = (data << 10 | rem) ^ 0x5412;

	for i in range(6):
		modules[8][i] = ((bits >> i) & 1) == 1

	modules[8][7] = ((bits >> 6) & 1) == 1
	modules[8][8] = ((bits >> 7) & 1) == 1
	modules[7][8] = ((bits >> 8) & 1) == 1

	for i in range(9, 15):
		modules[14 - i][8] = ((bits >> i) & 1) == 1

	for i in range(8):
		modules[modules.size() - 1 - i][8] = ((bits >> i) & 1) == 1

	for i in range(8, 15):
		modules[8][modules.size() - 15 + i] = ((bits >> i) & 1) == 1

	modules[8][modules.size() - 8] = true


func get_lost_point() -> int:
	var lost_point = 0

	# LEVEL1
	for row in range(module_count):
		for col in range(module_count):
			var same_count = 0
			var dark = modules[row][col]
			for r in range(-1, 2):
				if row + r < 0 or module_count <= row + r:
					continue
				for c in range(-1, 2):
					if col + c < 0 or module_count <= col + c:
						continue
					if r == 0 and c == 0:
						continue
					if dark == modules[row + r][col + c]:
						same_count += 1
			if same_count > 5:
				lost_point += (3 + same_count - 5)

	# LEVEL2
	for row in range(module_count - 1):
		for col in range(module_count - 1):
			var count = 0
			if modules[row][col]:
				count += 1
			if modules[row + 1][col]:
				count += 1
			if modules[row][col + 1]:
				count += 1
			if modules[row + 1][col + 1]:
				count += 1
			if count == 0 or count == 4:
				lost_point += 3

	# LEVEL3
	for row in range(module_count):
		for col in range(module_count - 10):
			if (
				modules[row][col]
				and not modules[row][col + 1]
				and     modules[row][col + 2]
				and     modules[row][col + 3]
				and     modules[row][col + 4]
				and not modules[row][col + 5]
				and     modules[row][col + 6]
				and not modules[row][col + 7]
				and not modules[row][col + 8]
				and not modules[row][col + 9]
				and not modules[row][col + 10]
			):
				lost_point += 40

	for col in range(module_count):
		for row in range(module_count - 10):
			if (
				modules[row][col]
				and not modules[row + 1][col]
				and     modules[row + 2][col]
				and     modules[row + 3][col]
				and     modules[row + 4][col]
				and not modules[row + 5][col]
				and     modules[row + 6][col]
				and not modules[row + 7][col]
				and not modules[row + 8][col]
				and not modules[row + 9][col]
				and not modules[row + 10][col]
			):
				lost_point += 40

	# LEVEL4
	var dark_count = 0
	for col in range(module_count):
		for row in range(module_count):
			if modules[row][col]:
				dark_count += 1

	var ratio = abs(100 * dark_count / module_count / module_count - 50) / 5
	lost_point += ratio * 10

	return lost_point


func _generate_texture_image(data: Array) -> ImageTexture:
	var image: Image = Image.create(data.size() + 2, data.size() + 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)

	for row in range(data.size()):
		for col in range(data[row].size()):
			var color = Color.BLACK if data[row][col] else Color.WHITE

			if data[row][col] == null:
				color = Color.GRAY

			image.set_pixel(row + 1, col + 1, color)

	var texture: ImageTexture = ImageTexture.new()
	return texture.create_from_image(image)


func _get_data_zigzag_positions() -> Array:
	var result := [];

	for row in range(modules.size() - 1, 1, -2):

		# test if it's ok
		if row <= 6:
			row -= 1

		for col in range(0, modules.size()):
			for index in range(0, 2):
				var position: Vector2 = Vector2(row - index, col)

				# test upward
				if ((row + 1) & 2) == 0:
					position.y = modules.size() - 1 - col

				if modules[position.x][position.y] == null:
					result.append(position);
	return result


func _set_data(zig_zag_positions: Array) -> void:
	var position_index = 0
	for index in qr_data_list[qr_data_list.size() - 1].size() / 8:
		for row in qr_data_list.size():
			if qr_data_list[row].size() > index * 8:
				for bits in range(8):
					var position = zig_zag_positions[position_index]
					modules[position.x][position.y] = qr_data_list[row][index * 8 + bits]
					position_index += 1

	for index in ecc_data_list[0].size() / 8:
		for row in ecc_data_list.size():
			if ecc_data_list[row].size() > index * 8:
				for bits in range(8):
					var position = zig_zag_positions[position_index]
					modules[position.x][position.y] = ecc_data_list[row][index * 8 + bits]
					position_index += 1

	# Add Remainder Bits if necessary.
	while position_index < zig_zag_positions.size():
		var position = zig_zag_positions[position_index]
		modules[position.x][position.y] = false
		position_index += 1
