t = 3;
w = 20;

o1 = 12;
d1 = 6;
o2 = 12;
d2 = 6.2;
l2 = 7;

$fa = 0.1;
$fs = 0.1;

module mount_shape(corner = false) {
    a1 = [
        [0,0],
        [20,0],
        [20,t],
    ];
    a2 = corner ? [[t,t]] : [];
    a3 = [
        [t, 20],
        [0, 20]
    ];
    polygon(concat(a1,a2,a3));
}

difference() {
    union() {
        linear_extrude(t)
        mount_shape(false);
        linear_extrude(w)
        mount_shape(true);
        translate([0,0,w-t])
        linear_extrude(t)
        mount_shape(false);
        
        translate([t,10,10])
        rotate([0,-90,0])
        cylinder(d = 6, h = 10+t);
    }
    
    #translate([11,-1,10]) rotate([-90,0,0]) cylinder(d = 6, h = t+2);
}