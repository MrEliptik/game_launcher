class_name UpdateChecker extends Node2D

signal release_parsed(latest_release)

var repo_url: String = "https://api.github.com/repos/MrEliptik/GameLauncher/releases/latest"

var latest_release: Dictionary

func get_latest_version() -> void:
	var req: HTTPRequest = HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(on_request_completed)
	req.request(repo_url)

func new_version_available(project_version: String, latest_version: String) -> bool:
	var project_numbers: Array = project_version.split(".")
	var latest_numbers: Array = latest_version.split(".")
	
	# We assume versions will have the same amount of numbers, otherwise IT BREAKS
	for i in range(project_numbers.size()):
		if int(latest_numbers[i]) > int(project_numbers[i]):
			return true
	
	return false

func on_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has("message"):
		print(json["message"])
		return
	
	# Remove the "v" for comparison
	var release_version: String = json["tag_name"].replace("v", "")
	
	latest_release = {
		"version": json["tag_name"],
		"url": json["html_url"],
		"new": new_version_available(ProjectSettings.get_setting("application/config/version"), release_version)
	}
	
	release_parsed.emit(latest_release)

func test_version_comparison() -> void:
	var release_version: String = "0.0.4"
	print(new_version_available("0.0.1", release_version))
	print(new_version_available("0.0.7", release_version))
	print(new_version_available("0.1.1", release_version))
	print(new_version_available("3.1.1", release_version))
	print(new_version_available("4.0.0", release_version))
	print(new_version_available("4.0.1", release_version))
	print(new_version_available("4.1.1", release_version))
	print(new_version_available("6.1.1", release_version))
