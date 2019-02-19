
include <tinylib.scad>

t = 2;


linear_extrude(t)
arc_profile(30,0,180,10, $fn = 64);

translate([-25,0,0])
cube([50,5,t]);
translate([-30,-5,0])
cube([60,5,t]);

