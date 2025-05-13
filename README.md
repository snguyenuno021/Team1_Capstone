Overview
The Home Layout Simulator is a 3D/VR tool designed for Quality Living, Inc. (QLI) therapists, patients, and families to plan and visualize home layouts before physical modifications. It converts 2D floor plans into 3D meshes, enables live adjustments in VR, and stores data in SQLite for persistence.

Features
- **Room Generator: Extrudes 2D floor plans into 3D rooms via mesh generation.
- **Measurement Tools: Measure clearances and distances accurately in VR.
- VR Interaction: Stream scenes to Meta Quest 2 (OpenXR) for immersive walkthroughs.
- Data Storage: Save/load layouts and measurements using SQLite.
- Automated Testing: Core logic covered by GUT unit tests and CI integration.

 Installation & Usage
•	Prerequisites
1.	Godot Engine 4.x

2.	Godot-SQLite plugin 

3.	GUT plugin

4.	OpenXR support 

5.	Meta Quest 2 headset & PC on the same Wi-Fi network

•	Clone the Repo

1.	git clone https://github.com/snguyenuno021/Team1_Capstone.git

2.	cd Team1_Capstone

•	Open in Godot

1.	Launch Godot Engine

2.	Click import, select the cloned Team1_Capstone folder, choose project. godot, and open

•	Enable and Install Plugins

1.	In AssetLib, download and install GUT

2.	Copy the godot-sqlite addon into res://addons/godot-sqlite/

3.	In Project, Project Settings , Plugins, enable:

-	GUT (res://addons/gut/)

-	Godot-SQLite (res://addons/godot-sqlite/)

•	Configure OpenXR

1.	Go to Project Settings , XR , Interfaces, Add , OpenXR

2.	Tick Enabled for OpenXR

3.	Under XR , OpenXR, Tracking, set VR device to Quest 2

•	Connect Quest 2 Over Wi-Fi

1.	Plug Quest 2 into PC via USB, enable Developer Mode in Meta app

In a terminal:

 adb tcpip 5555
adb connect <QUEST_IP_ADDRESS>:5555
2.	Run adb devices to confirm the Quest 2 is connected

•	Run the Simulator in Editor

•	Export for Desktop VR

1.	Project , Export , and then choose Linux.

2.	Click Export Project, then run the executable on your PC


 Release Notes

M1 (2/25): Basic 3D room generator running in Godot.

M2 (3/18): Created room mesh.

M3 (4/15): Created basic User interface layout.

M4 (5/1): Created a user interface with Godot, which allows our mesh to change its height and width like a building.

M5 (5/9): Connected our VR system to Godot, and allowed user to enter the mesh.

 Branches
- main: Stable code with M5 deliverables.
- Tilly1236-patch-1: Sydney's Testing branch
- furnitureTesting: Furniture-generation code
- experimental: Testing file
- master- Chris Testing branch

