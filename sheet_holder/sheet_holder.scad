
$fs=0.1;
$fa = 0.2;

d = 16;
h = 50;
t = 2;


dt = 10;

module diff_shape() {
    translate([0,-d/2+t/2])
    linear_extrude(h/2,scale=0.2)
    square([dt,d], center=true);
}

difference() {
    linear_extrude(h)
    difference() {
        circle(d = d);
        circle(d = d-t*2);
    }
    diff_shape();
    translate([0,0,h])
    mirror([0,0,-1])
    diff_shape();
}



//cylinder(d = 1.6, h = 5, $fn = 16);