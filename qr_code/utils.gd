class_name Utils
extends Node


const ALPHANUMERIC_CHARACTERS: Dictionary = {
	"0" : 0,
	"1" : 1,
	"2" : 2,
	"3" : 3,
	"4" : 4,
	"5" : 5,
	"6" : 6,
	"7" : 7,
	"8" : 8,
	"9" : 9,
	"A" : 10,
	"B" : 11,
	"C" : 12,
	"D" : 13,
	"E" : 14,
	"F" : 15,
	"G" : 16,
	"H" : 17,
	"I" : 18,
	"J" : 19,
	"K" : 20,
	"L" : 21,
	"M" : 22,
	"N" : 23,
	"O" : 24,
	"P" : 25,
	"Q" : 26,
	"R" : 27,
	"S" : 28,
	"T" : 29,
	"U" : 30,
	"V" : 31,
	"W" : 32,
	"X" : 33,
	"Y" : 34,
	"Z" : 35,
	" " : 36,
	"$" : 37,
	"%" : 38,
	"*" : 39,
	"+" : 40,
	"-" : 41,
	"." : 42,
	"/" : 43,
	":" : 44,
}

static func convert_to_binary(data: int, size: int = 8) -> Array:
	var result := []
	for index in range(size - 1, -1, -1): # range size to 0
		result.append(data >> index & 1 == 1)

	return result

static func convert_to_decimal(binary_value: Array):
	var result = 0
	for c in binary_value:
		result = (result << 1) + int(c)
	return result
