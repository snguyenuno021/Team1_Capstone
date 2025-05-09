1. A 3D application that shows a home layout for patients. This application is used by the therapist to help formulate a home layout that suits the needs of patients based off of the diagnosis. 
Further, the patient will be able navigate the home through the use of VR.

2. Release Notes (March 27, 2025: Code Milestone 2):\
   Extending a 2D model of walls instead of using generative reductive obstacles to form the walls of the simulation. Currently, the values are hard-coded, but eventually will be dynamically set by the user through the UI.\
   Added gen_room.gd\
     gen_room.gd: Create walls

   Release Notes (February 26, 2025: Code Milestone 1):\
   Created the basic framework/environment/configuration for the application. Groundwork has been laid for future code development.\
     House.tscn: House container for other/future objects, Floor created, Moveable character created on top of floor\
     default_env.tres: Set sky background

