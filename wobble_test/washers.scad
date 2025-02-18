
$fa = 0.2;
$fs = 0.2;

/*
linear_extrude(2)
difference() {
circle(d = 8);

circle(d = 3.4);
}*/


module washer(flat = true) {
    difference() {
        cylinder(d = 7, h = 2);
        cylinder(d1 = 3.4, d2 = flat ? 3.4 : 6, h = 2);
    }
    
}

washer(true);
//washer(false);

