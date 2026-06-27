use <bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

battery_dim = [14.5,50];
holder_thickness = 1.2;
holder_contact = 5;
holder_dim = [ holder_thickness + battery_dim[0], battery_dim[1] + holder_contact + holder_thickness*2, holder_thickness*2 + battery_dim[0]];

lid_fill = 3;
lid_dim = [19.5, 25.5, 1.5+lid_fill];
lid_hole_offset = [lid_dim[0]/2,23.5];


module lid() {

    union() {

        translate([0,0,lid_fill])
        linear_extrude(lid_dim[2] - lid_fill)
        intersection() {
        
            union() {

                hull() {
                    translate([0,5])
                    square([lid_dim[0], 15]);

                    translate([(lid_dim[0]-12)/2,0])
                    square([12,20]);
                        
                    translate([(lid_dim[0]-6)/2,0])
                    square([6,24]);
                
                }
                
                translate([(lid_dim[0]-4)/2,0])
                square([4,lid_dim[1]]);
            }
            
            translate([-2.9,lid_dim[1]/2-1])
            circle(d = 44.75);
            
        }

        translate([(lid_dim[0]-4)/2,-2,lid_fill-1])
        cube([4,lid_dim[0],1]);

        translate([lid_dim[0]/2,lid_dim[0]/2+1.5,0])
        cylinder(d = lid_dim[0], h = lid_fill);
        
    }

}


module battery() {
    cylinder(d = battery_dim[0], h = battery_dim[1] - 1.5);
    cylinder(d = 5, h = battery_dim[1]);
}



module battery_holder_shape(inner) {

    w = battery_dim[0];
    t = holder_thickness;
    
    difference() {
        bl_square([w+t,w+t+t], [0,4,0,0], $fn=1);
        if (inner) {
            offset(-t)
            bl_square([w+t,w+t+t], [0,4,0,0], $fn=1);
            translate([w-t,t])
            square([w,w]);
        }
    }

    *#translate([w/2+t,w/2+t])
    circle(d = w);

    
}



module battery_holder() {
    
    translate([0,holder_dim[1]])
    rotate([90,0,0])
    union() {
    
        linear_extrude(holder_thickness)
        battery_holder_shape(false);
        
        translate([0,0,holder_thickness])
        linear_extrude(holder_dim[1]-holder_thickness*2)
        battery_holder_shape(true);
        
        translate([0,0,holder_dim[1]-holder_thickness])
        linear_extrude(holder_thickness)
        battery_holder_shape(false);
        
        *if ($preview) {
            translate(bl_3d(holder_thickness))
            translate([battery_dim[0]/2, battery_dim[0]/2,holder_contact/2])
            #battery();
        }
    
    }
}

module base() {

    difference() {

        union() {

            translate([0,0,lid_dim[2]])
            battery_holder();

            translate([0,(holder_dim[1]-lid_dim[1])/2,0])
            lid();
            
        }

        translate([lid_dim[0]-7,(holder_dim[1]-lid_dim[1])/2 + 1.5 + 3,-1])
        cylinder(d = 3, h = lid_dim[2]+holder_thickness + 2);
        
        translate([lid_dim[0]-7,(holder_dim[1]-lid_dim[1])/2 + 1.5 + lid_dim[0] - 3,-1])
        cylinder(d = 3, h = lid_dim[2]+holder_thickness + 2);
 
        translate([lid_hole_offset[0],(holder_dim[1]-lid_dim[1])/2 + lid_hole_offset[1],-1])
        union() {
            translate([0,0,lid_dim[2]+holder_thickness+1])
            cylinder(d = 5, h = battery_dim[0]+holder_thickness+2);
            translate([0,0,lid_dim[2]+holder_thickness])
            cylinder(d = 3, h = 3);
            cylinder(d = 1.7, h = lid_dim[2]+holder_thickness + 2);
        }
        
    }
}

module lid_with_hole() {
    //rotate([0,180,0])
    difference() {
        lid();
        translate([lid_hole_offset[0],lid_hole_offset[1],-1])
        cylinder(d = 1.7, h=lid_dim[2]+2);
    }
}

rotate([0,-90,0])
base();


//lid_with_hole();