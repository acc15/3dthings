
$fs = 0.5;
$fa = 0.5;

t = 1.8;

d = 10;
w = 6;
l = 100;
p = 10;



module shape(l) {
    difference() {
        intersection() {
            circle(d = d);
            square([d, w], center=true);
        }
        if (l) {
            square([d - t*2, d], center=true);
        } else {
            translate([0,w/4+t/2])
            square([d - t*2, w / 2], center=true);
            translate([0,-(w/4+t/2)])
            square([d - t*2, w / 2], center=true);
        }
    }
}

linear_extrude(p)
shape(true);

translate([0,0,p])
linear_extrude(l-p*2)
shape(false);

translate([0,0,l-p])
linear_extrude(p)
shape(true);