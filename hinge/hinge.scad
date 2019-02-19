
d = 4;
t = 1.8;
o1 = 0.8;
o2 = 2;
h = 30;
b = 3;
s = 5;
l = 10;

d2 = d + o2 + t * 2;

h2 = (h + o1) / s;

module ch(d1, d2, h) {
    $fn = 64;
    if (d2 == 0) {
        cylinder(d = d1, h = h);
    } else {    
        tol = o1 == 0 ? 1 : o1/2;
        difference() {
            cylinder(d = d1, h = h);
            translate([0,0,-tol])
                cylinder(d = d2, h = h + tol*2);
        }
    }
}

module mount() {
    translate([d2/2,-d2/2, 0])
    difference() {
        cube([l, t, h]);
        bolt(b + o1);
        bolt(h - (b + o1));
    }
}

module bolt(bh) {
    translate([l - b - o1, 0, bh])
    rotate([-90,0,0])
    translate([0,0,-o1])
    cylinder(d = b + o1, h = t + o1 * 2, $fn = 64);
}

module hinge_item(di = 0) {
    ch(d2, di, h2 - o1);
    translate([0,-d2/2,0])
        cube([d2/2 + o1*2, t, h2 - o1]);
}

module hinge() {
    ch(d, 0, h);
    for (i = [0:s-1])
        translate([0,0,i * h2])
            mirror([i % 2 ? 1 : 0, 0, 0])
                hinge_item(i % 2 == 0 ? 0 : d + o2 );
    
    mount();
    mirror([1,0,0])
        mount();
}

rotate([90,0,0])
%hinge();