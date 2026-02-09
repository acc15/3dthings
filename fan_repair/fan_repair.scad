$fa = 0.2;
$fs = 0.2;

hole_d = 4;
thickness = 0.48*8;

h1 = 3;
h2 = 28/2 - (hole_d/2+thickness);
h3 = 10;

echo(h2);


difference() {

union() {

    cylinder(d = 28, h = h1);
    translate([0,0,h1])
    cylinder(d1 = 28, d2 = hole_d + thickness * 2, h = h2);

    translate([0,0,h1 + h2])
    cylinder(d = hole_d + thickness * 2, h = h3);
        
}
translate([0,0,-1])
cylinder(d = hole_d, h = h1+h2+h3 + 2);
}