

$fa = 0.2;
$fs = 0.2;

tol = 0.1;

module tightener(h) {

    difference() {
    union() {
    translate([-4,-4,0])
    cube([8, 8, h]);
    translate([0,0,h])
    sphere(d = 6);
    }

    sphere(d = 6 + tol*2);
    }
}

for (i = [0:3], j=[0:1]) {
    translate([i * 9, j * 9])
        tightener(3 + j*0.5);
}