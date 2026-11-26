$fa = 0.4;
$fs = 0.1;

h = 2;
w = 4;
l = 50;

linear_extrude(h)
difference() {
    offset(1)
    offset(-1)
    square([l, w]);
    
    translate([0,w/2])
    scale([l/w,1])
    circle(d=w/2);
    
    translate([l,w/2])
    scale([l/w,1])
    circle(d=w/2);
}
