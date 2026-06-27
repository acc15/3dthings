$fa = 0.2;
$fs = 0.2;

d = 6;
h = 7.6;
t = 1.2;
w = 24;

battery_dim = [14, 50];
battery_offset = 6;
contact_dim = 5;
mount_length = 10;


module mount_shape() {
    for (i = [0:1]) {
        translate([i*(t+w),0]) {
            translate([-t/2,0])
            circle(d = d);
            translate([-t,0])
            square([t, mount_length]);
        }
    }
}

module battery() {
    
    cylinder(d = battery_dim[0], h = battery_dim[1]);
    
}

#translate([battery_dim[0]/2+t,battery_offset+contact_dim/2,h-battery_dim[0]/2])
rotate([-90,0,0])
battery();



linear_extrude(h)
union() {

    difference() {
        offset(t)
        mount_shape();
        
        mount_shape();
        
        translate([-t*2-1,mount_length-0.001])
        square([w+t*4+2,t+1]);
    }

    translate([0,battery_offset])
    square([t,battery_dim[1]+contact_dim]);

    translate([w-t,battery_offset])
    square([t,battery_dim[1]+contact_dim]);

    translate([0,battery_offset-t])
    square([w,t]);

    translate([0,battery_offset+battery_dim[1]+contact_dim])
    square([w,t]);

}