$fn = 128;

translate([0,12,0])
cube([124, 6, 14]);

t = 1.6;

translate([(124 - 108) / 2,0,0])
union() {


    difference() {

        linear_extrude(8)
        offset(2)
        offset(-2)
        square([108, 12+2]);

        translate([t,t,t])
        cube([104, 12, 8]);
    }

    translate([-7,t + 4.25 / 2,4])
    rotate([0,90,0])
    cylinder(d = 4.25, h = 7);

    translate([108,t + 4.25 / 2,4])
    rotate([0,90,0])
    cylinder(d = 4.25, h = 7);
    
}