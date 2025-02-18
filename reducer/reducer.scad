use <../../gears/gears.scad>;


//8 + 2 * 24

// ring_teeth = sun_teeth + 2*planet_teeth;
// planet_distance = (sun_teeth + planet_teeth) / 2

planets = 3;
sun_teeth = 10;
planet_teeth = 20;

for (i = [0:planets-1])
    rotate([0,0,i * (360 / planets)])
        translate([(sun_teeth + planet_teeth) / 2, 0, 0])
            cylinder(d = 3.9, h = 10, $fn = 32);


planetary_gear(modul=1, 
    sun_teeth=sun_teeth, 
    planet_teeth=planet_teeth, 
    number_planets=3, 
    width=5, 
    rim_width=2, 
    bore=4, 
    pressure_angle=20, 
    helix_angle=0, 
    together_built=true, 
    optimized=true);
