use <bendlib/bendlib.scad>;

$fa = 0.4;
$fs = 0.4;

w = 24;
h = 7.75;
d = 5.6;
l = 10;
t = 1.2;
tolerance = 0.2;

battery_dim = [14,50];
hole_offset = 6;
contact_length = 5;
total_length = t+battery_dim[1]+contact_length;


contact_dim = [9.5,9,0.2];
contact_pin_dim = [2.5,15];


module battery() {
    cylinder(d = battery_dim[0], h = battery_dim[1]);
}

module lock() {

    module lock_shape() {
        difference() {
            union() {
                translate([-t/2,0])
                circle(d=d+tolerance*2);
                translate([-t,0])
                square([t,l]);        
            }
        }
    }

    difference() {
        offset(t)
        lock_shape();
        lock_shape();
        translate([-t*2-1,l-0.001])
        square([t*3+2, t+1]);
    }
    
}

module shape() {

    lock();
    translate([w+t,0])
    lock();

    translate([0,hole_offset])
    square([w,t]);

    translate([0,hole_offset+total_length])
    square([w,t]);

    translate([0,hole_offset])
    square([t,total_length+t]);

    translate([w-t,hole_offset])
    square([t,total_length+t]);

    translate([t+battery_dim[0],hole_offset])
    square([t,total_length+t]);
    
}


module contact() {
    linear_extrude(contact_dim[2])
    union() {
        bl_square([contact_dim[0],contact_dim[1]], [3,3,1,1]);
        translate([(contact_dim[0] - contact_pin_dim[0])/2,0])
        bl_square(contact_pin_dim,[contact_pin_dim[0]/2,contact_pin_dim[0]/2,0,0]);
    }
}

module adapter() {

    difference() {
        
        linear_extrude(h)
        shape();
        
        d = 4;
       
        #translate([battery_dim[0]+t*2+d/2,hole_offset-1,0])
        rotate([-90,0,0]) {
            hull() {
            cylinder(d = d, h = total_length + t+2);
            translate([w - battery_dim[0] - d - t*3,0,0])
            cylinder(d = d, h = total_length + t+2);
            }
        }

        translate([t+battery_dim[0]-1,hole_offset+t,h-contact_dim[0]/2-contact_pin_dim[0]/2]) {

            translate([0,0,0])
            cube([t+2,t,contact_pin_dim[0]]);
            
            translate([0,total_length-t*2,0])
            cube([t+2,t,contact_pin_dim[0]]);
                
        }
        
    }

    #if ($preview) {
        translate([battery_dim[0]/2+t,hole_offset+t+contact_length/2,h-battery_dim[0]/2])
        rotate([-90,0,0])
        battery();
        
        translate([t+battery_dim[0]/2-contact_dim[1]/2,hole_offset+t+contact_dim[2],h])
        rotate([90,90,0])
        contact();
        
        translate([t+battery_dim[0]/2-contact_dim[1]/2,hole_offset+total_length,h])
        rotate([90,90,0])
        contact();
        
        translate([-t,0,0]) {
            cube([t,total_length + hole_offset,h]);
            translate([t/2,0])
            cylinder(d = d, h = h);
        }
        
        translate([w,0,0]) {
            cube([t,total_length + hole_offset,h]);
            translate([t/2,0])
            cylinder(d = d, h = h);
        }
        
    }
}

rotate([180,0,0])
adapter();

