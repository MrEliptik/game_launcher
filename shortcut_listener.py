import asyncio
import websockets
import keyboard
import threading
import configparser

# List to hold connected WebSocket clients
connected_clients = set()
current_shortcut = None

def read_config():
    config = configparser.ConfigParser()
    config.read('launcher_config.ini')
    shortcut_kill_game = config.get('SETTINGS', 'shortcut_kill_game', fallback="ctrl+q")
    if shortcut_kill_game:
        # Strip any surrounding quotes
        shortcut_kill_game = shortcut_kill_game.strip('"\'')
    
    return shortcut_kill_game

async def handle_client(websocket, path):
    # Register the client
    connected_clients.add(websocket)
    print(f"New client connected. Total clients: {len(connected_clients)}")
    try:
        # Keep the connection open and listen for messages (though we won't use them)
        async for _ in websocket:
            pass
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")
    finally:
        # Unregister the client
        connected_clients.remove(websocket)
        print(f"Client disconnected. Total clients: {len(connected_clients)}")

async def broadcast_key_press(key_name):
    if connected_clients:  # Check if there are any connected clients
        message = f"KEY_PRESSED:{key_name}"
        print(f"Broadcasting message: {message}")
        await asyncio.gather(*[client.send(message) for client in connected_clients])
    else:
        print("No clients connected; message not sent.")

def on_shortcut_combination():
    print(f"Shortcut {current_shortcut} triggered!")
    if connected_clients:
        asyncio.run_coroutine_threadsafe(broadcast_key_press(f"KEY_COMBINATION:{current_shortcut}"), loop)
    else:
        print("No clients to send the key combination to.")

def start_websocket_server():
    global loop
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    # Start the WebSocket server
    start_server = websockets.serve(handle_client, "localhost", 65432)

    # Run the server in the event loop
    loop.run_until_complete(start_server)
    print("WebSocket server started on ws://localhost:65432")
    loop.run_forever()

def initialize_shortcut():
    global current_shortcut
    current_shortcut = read_config()
    if current_shortcut:
        keyboard.add_hotkey(current_shortcut, on_shortcut_combination)
        print(f"Listening for the shortcut from config: {current_shortcut}")
    else:
        print("No shortcut found in config.")

# Start the WebSocket server in a background thread
server_thread = threading.Thread(target=start_websocket_server)
server_thread.start()

# Initialize the shortcut from config
# Start listening for key presses
initialize_shortcut()
print("Listening for key presses...")
