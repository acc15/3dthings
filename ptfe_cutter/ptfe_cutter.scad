

d = 4;
t = 2;

l = 50;
tol = 0.1;

$fa = 0.2;
$fs = 0.2;

w = d+t*2+tol*2;

hole_t = 0.5;


difference() {
cube([l, w, d + t * 3]);

translate([-tol,t+tol+d/2,t*2+tol+d/2])
rotate([0,90,0])
cylinder(d = d+tol*2, h = l + tol*2);
    
    translate([l*2/3-hole_t/2,-d*5, t])
    cube([hole_t, d*10, t*2+tol*3+d]);
    
}



