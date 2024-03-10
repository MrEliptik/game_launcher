import os
import subprocess
import zipfile
import shutil
import configparser
from datetime import datetime

godot_path = "C:\Program Files\Godot\Godot_v4_2_1-stable_win64_exe\Godot_v4.2.1-stable_win64.exe"
gh_cli_path = 'C:\Program Files\GitHub CLI\gh.exe'

build_path = "build/"

game_name = 'game_launcher'
exe_name_windows = game_name+'.exe'
exe_name_linux = game_name+'.x86_64'

project_file = "project.godot"
export_preset_file = "export_presets.cfg"

windows_template = "game_launcher_win"
linux_template = "game_launcher_linux"
mac_template = "game_launcher_mac"

templates = [windows_template, linux_template, mac_template]

def export_template(template, build_path, build_nb):
    platform = template.split('_')[2]
    exe_name = ""
    match platform:
        case "win":
            exe_name = exe_name_windows
        case "linux":
            exe_name = exe_name_linux

    build_path_template = os.path.join(build_path, template.replace(' ', '_'))
    if not os.path.isdir(build_path_template):
        os.makedirs(build_path_template)
        print("    |---> Template folder created: " + build_path_template)
    else:
        print("    |---> Template folder already exists: " + build_path_template)

    # "C:\Program Files\Godot\Godot_v4_1_3-stable_win64_exe\Godot_v4.1.3-stable_win64.exe" --headless --export-release "Linux/X11" /var/builds/project
    cmd = [godot_path, "--headless", "--export-release", template, os.path.join(build_path_template, exe_name)]
    print("    |---> Executing command: ", cmd)

    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, encoding='utf-8') as sp:
        pass
    print("    |---> Exporting template finshed: ", template)

    # List files to zip
    files_to_zip = []
    for file in os.listdir(build_path_template):
        files_to_zip.append(file)
    
    zip_file = os.path.join(build_path, game_name+"_"+platform+"_"+build_nb+".zip")
    with zipfile.ZipFile(zip_file, 'w', zipfile.ZIP_DEFLATED) as myzip:
        for file in files_to_zip:
            # File to zip, filename in zip, compression type
            myzip.write(os.path.join(build_path_template, file), file)

    print("    |---> Zip created: ", zip_file)
    return zip_file

def parse_build_nb_from_file(file):
    with open(file, 'r', encoding='UTF-8') as f:
        for line in f:
            if 'config/version' in line:
                number = line.strip().split("config/version=", 1)[1]
                number = number.replace('"', '')
                return number

def upload_gh(files, build_nb, prerelease=False):
    print("    |---> Uploading build: {}, prerelease: {}".format(build_nb, prerelease))
    cmd = [gh_cli_path, 'release', 'create', build_nb]
    for file in files:
        cmd.append(file)
    cmd.append('--generate-notes')
    if prerelease:
        cmd.append('--prerelease')

    print("    |---> Executing command: ", cmd)

    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, encoding='utf-8') as sp:
        for line in sp.stdout:
            print(line.strip())

def main():
    print("########## Export starting ##########")

    build_number = parse_build_nb_from_file(project_file)

    print("|---> Found build number: " + build_number)

    build_path_full = os.path.join(build_path, build_number)
    print("|---> Creating export build folder: " + build_path_full)

    if not os.path.isdir(build_path_full):
        os.makedirs(build_path_full)
        print("    |---> Export folder created: " + build_path_full)
    else:
        print("    |---> Export folder already exists: " + build_path_full)

    zip_files = []
    for template in templates:
        print("|---> Exporting template: " + template)
        zip_created = export_template(template, build_path_full, build_number)
        zip_files.append(zip_created)

    print("Upload to github? y/n")
    while(True):
        x = input()
        if x=='y':
            break
        elif x=='n':
            exit(0)

    print("########## Upload starting ##########")
    # Check if draft is in file number to know if it should be a prerelease or not
    upload_gh(zip_files, build_number, prerelease='draft' in build_number)

if __name__ == '__main__':
    main()