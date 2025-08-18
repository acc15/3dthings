
$fs=0.2;

d = 1.6;
t = 0.25;
h = 5;

dt = 1;

module diff_shape() {
    translate([0,-d/2+t/2])
    linear_extrude(h/2,scale=0.2)
    square([dt,1.5], center=true);
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