# Game launcher

A simple game launcher for developers to showcase their games. Especially useful during gaming conventions for example. 

*⚠ It's not aimed as being shipped with your game on Steam or other platforms.*

<p align="center">
  <img src="media/launcher_v0.0.1.gif">
</p>

## How to add games

1. If not present, create a folder called **games** next to the executable.
2. Inside, create a folder for each game you want. The name of the folder will be the name of the game.
3. Place your executable, capsule image, background image and description.txt
4. The game executable will be launched by the launcher
5. The capsule must be named **capsule** with the following extensions supported: jpg, jpeg, png
6. The background image bust be named **bg** with the following extensions supported: jpg, jpeg, png
7. In **description.txt**, put the description you want to see below your game capsule in the launcher
8. Optionally, consider adding a **config.ini** for [advanced setup](#advanced-setup).

Here's an example folder  
game_launcher.exe  
├── games  
│   ├── Game name  
│   │   ├── game_executable.exe  
│   │   ├── capsule.jpg  
│   │   ├── bg.jpg  
│   │   └── config.ini  

You can also check the [**Fake**](games/Fake) folder to see a game example

## Advanced Setup

A **config.ini** can be used to customize a game. Using the config file you can set extended information such as release date, platforms, and even a QR code.

See the example `config_fake.ini` file in the [**Fake**](games/Fake/config_fake.ini) folder for a full list of properties.

Note: If used, the "description" key will override the **description.txt**.

## Launcher configuration

The launcher itself is configured using [launcher_config.ini](launcher_config.ini). 

- `shortcut_kill_game`: global shortcut used to kill a launched game. Requires [shortcut_listener.py](shortcut_listener.py) to be running. See [shortcut configuration](Shortcut configuration)
- `fullscreen`: true|false, start the launcher in fullscreen  
- `window_title`: if windowed, the title you see in the title bar

### Shortcut configuration with Python

[shortcut_listener.py](shortcut_listener.py) is a script to listen to a specific shortcut to kill any active game started by the launcher. It communicates with the launcher using websockets (yes a bit overkill).

Requires python 3.10.x with the following package `asyncio, websockets, keyboard`

```
pip install asyncio, websockets, keyboard
```

The python script will be launched automatically by the app if you have a `shortcut_kill_game` set in [launcher_config.ini](launcher_config.ini).

## How to navigate

Navigate using keyboard or gamepad using the usual keys used for navigation (arrows keys, enter).

`alt+enter` to toggle fullscreen of the launcher

## Limitations

Right now, the launcher is only working with windows and linux. Supporting mac shouldn't be complicated but I don't have a mac nor experience with macOS. If you want to help, please see https://github.com/MrEliptik/game_launcher/issues/2.  

## Development

For development, you can use the **games** folder present in the project using the same configuration as explained above.

## Contributing
To start contributing, open an issue about what you want to do if there's not one yet, clone the repo, do you changes and create a PR!

Thanks to the contributors for their work 👇
<a href="https://github.com/MrEliptik/game_launcher/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=MrEliptik/game_launcher" />
</a>

## 💁‍♂️ About me

Full time indie gamedev. You can find me everywhere 👇

- [Discord](https://discord.gg/83nFRPTP6t)
- [YouTube - Gamedev](https://www.youtube.com/@MrEliptik)
- [YouTube - Godot related](https://www.youtube.com/@mrelipteach)
- [Twitter](https://twitter.com/mreliptik) 
- [Itch.io](https://mreliptik.itch.io/)
- [All links](https://bento.me/mreliptik)

If you enjoyed this project and want to support me:

**Get exlusive content and access to my game's source code**

<a href='https://patreon.com/MrEliptik' target='_blank'><img height='36' style='border:0px;height:36px;' src='media/become_patreon.png' border='0' alt='Patreon link' /></a>

**One time donations**

<a href='https://ko-fi.com/H2H23ODS7' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
