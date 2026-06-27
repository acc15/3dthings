$fa = 0.5;
$fs = 0.5;

d_legs = 150;
d_bolt = 8;
d_nut = 12.8 * 2/sqrt(3);
h_nut = 6.5;
h = 30;
t = 5;
rounding = 2;

h_leg = h_nut + 1;
w_leg = t;
n_leg = 6;


module leg_shape() {
    difference() {
        hull() {
            circle(d = d_nut + t*2);
            translate([d_legs/2,0])
            circle(d = t);
        }
    }
}


module legs_shape() {
    for (i = [0:n_leg-1]) {
        rotate([0,0,i*360/n_leg])
        difference() {
            leg_shape();
            offset(-t)
            difference() {
                leg_shape();
                circle(d = d_nut);
            }
        }
    }
}



difference() {
    union() {
        translate([0,0,h_leg])
        linear_extrude(t)
        legs_shape();

        for (i = [0:n_leg-1]) {
            rotate([0,0,i*360/n_leg])
            translate([d_legs/2,0,0])
            cylinder(d = t, h = h_leg+t);
        }
        
        cylinder(d = d_nut + t*2, h = h_leg+t);
    }
    
    translate([0,0,-1])
    linear_extrude(h_nut+1)
    offset(rounding)
    offset(-rounding)
    circle(d = d_nut, $fn = 6);
    
    translate([0,0,-1])
    cylinder(d = d_bolt, h = h_leg+t+2);
}
