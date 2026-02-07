# IOS-UnityChams: Advanced Shader Chams

This project implements a high-performance, dynamic Shader Chams system for Unity games on iOS. It uses IL2CPP reflection to find game objects and apply built-in game shaders in real-time.
No Jailbreak \ No JiT 

<img width="1450" height="775" alt="Zrzut ekranu 2026-02-7 o 12 13 46" src="https://github.com/user-attachments/assets/22034498-b6f0-419b-a562-73778e40dc72" />


## Features

- **Dynamic Shader Injection**: Apply any built-in game shader to any object.
- **Real-time Target Selection**: No hardcoding required! Select Assemblies and Classes dynamically from the menu.
- **Renderer Filtering**: Fine-tune exactly which parts of a model glow (e.g., exclude weapons or accessories).
- **Z-Buffer Control**: Customize Z-Test (Depth Test) and Z-Write.
- **Color Customization**: Full RGB+Alpha control for the chams color (supported shaders only).

## How to Use

### 1. Enable Chams
Go to the **Chams** tab and toggle **"Enable Chams"**.

### 2. Select a Shader
- Click **"Refresh Shaders"** to scan the game for available shaders.
- Use the **< Left** and **Right >** arrow buttons to cycle through them.
- *Note: Only shaders already present in the game (built-in) can be used.*

### 3. Select Target Class (Crucial!)
To make chams appear, you must tell the tool *what* to highlight.
1.  **Assembly**: Select the game's assembly from the dropdown (e.g., `_CombatMaster.Battle` or `Assembly-CSharp`).
2.  **Class**: Select the specific class of the object (e.g., `PlayerRoot`, `EnemyController`, `BP_Soldier`).

### 4. Customize Renderers (Optional)
By default, the chams apply to *all* renderers on the found objects. If you want more control:
1.  Click **"Refresh Renderers"**.
2.  A list of all found renderers (meshes, skins, accessories) will appear.
3.  **Uncheck** any parts you don't want to highlight (e.g., backpacks, guns).
4.  Use **Select All** / **Deselect All** for quick mass-toggling.

### 5. Settings
- **Color**: Pick the highlight color.
    - *Note: Some shaders may ignore this setting if they do not support color properties.*
- **Z-Test**: Controls visibility through walls.
    - *Note: Many shaders ignore manual Z-Test settings.*
    - `0` (Always): Visible through everything (Wallhack).
    - `4` (LEqual): Standard visibility (occluded by walls).
    - `8` (Always): Alternative wallhack mode.
- **Z-Write**: Controls whether the object writes to the depth buffer.
    - *Note: Many shaders ignore manual Z-Write settings.*

## Troubleshooting

**"Nothing happens when I enable Chams!"**
- Did you select a valid **Target Class**?
- Try a different **Shader**. Some shaders don't support color overrides or are invisible on certain meshes.
- Check the **Debug Logs** panel on the right side of the menu for errors (e.g., "0 objects found").

**"The game crashes when I click Refresh Renderers!"**
- This can happen if the selected Class is not a Unity `Component` (e.g., it's a plain C# class). Ensure you select a class that inherits from `MonoBehaviour` or is attached to a GameObject.

---
**Credits:**
- **GoodFeelings**: Release & UI
- **Leeksov**: Shader Chams Source
- **Hao Dam**: IL2CPP Framework
