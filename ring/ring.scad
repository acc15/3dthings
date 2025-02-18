ring_d = 52;

profile_dx = 7;
profile_dy = 8;
profile_h = 7;

$fa = 0.2;
$fs = 0.2;

rotate_extrude()
translate([profile_dx/2 + ring_d/2,profile_h/2])
intersection() {
    scale([1,profile_dy/profile_dx])
        circle(d = profile_dx);
    
    square([profile_dx, profile_h], center = true);
}


