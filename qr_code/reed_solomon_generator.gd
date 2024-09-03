class_name ReedSolomonGenerator
extends Node


var coefficients: Array = []


func _init(degree: int) -> void:
	if degree < 1 || degree > 255:
		push_error("Degree out of range")

	for _i in range(0, degree - 1):
		coefficients.append(0)
	coefficients.append(1)

	var root: int = 1

	for _i in range(0, degree):
		for j in range(0, coefficients.size()):
			coefficients[j] = self._multiply(coefficients[j], root)
			if j + 1 < coefficients.size():
				coefficients[j] ^= coefficients[j + 1]

		root = self._multiply(root, 0x02)


func get_remainder(data: Array) -> Array:
	var result: Array = []
	for _i in coefficients.size():
		result.append(0)

	for byte in data:
		var factor = byte ^ result.pop_front()
		result.append(0);

		for index in coefficients.size():
			result[index] ^= self._multiply(coefficients[index], factor)

	return result;


func _multiply(x: int, y: int) -> int:
	if ((x >> 8) != 0 || (y >> 8) != 0):
		push_error("Byte out of range")

	var z: int = 0

	for i in range(7, -1, -1):
		z = ((z << 1)) ^ ((z >> 7) * 0x11D)
		z ^= ((y >> i) & 1) * x

	if (z >> 8) != 0:
		push_error("Assertion error")

	return z
