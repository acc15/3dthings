use <threads-library-by-cuiso-v1.scad>

$fa = 0.5;
$fs = 0.5;

d = 50;
t = 1.2;
h = 50;
th = 15;
tol = 0.1;

module box() {

    difference() {
        union() {
            cylinder(d = d, h = h);
            translate([0,0,h-th])
                thread_for_screw(d+5, th);
        }
        translate([0,0,t])
        cylinder(d = d - t*2, h = h);
    }

}

module lid() {

    difference() {
        cylinder(d = d + 5 + t*2, h = th+t);
        translate([0,0,-tol])
        thread_for_nut(d+5, th+tol);
    }
    
}

box();

translate([d+5+t*2,0,th+t])
rotate([180,0,0])
lid();



