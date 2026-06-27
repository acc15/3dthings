 use <bendlib/bendlib.scad>;
 use <NopSCADlib/utils/sweep.scad>;

$fa = 0.5;
$fs = 0.5;

tolerance = 0.2;
thickness = 1.2;

wire_thickness = 1.6+tolerance*2;
contact_wall_thickness = 0.6;
contact_body_thickness = wire_thickness;



/* 18650 */
battery_dim = [18.35, 65];

contact_dim = [9.5,9,0.2];
contact_pin_dim = [2.5,15];
contact_length = 7;

battery_offset = [
    thickness + tolerance + battery_dim[0]/2,
    thickness + tolerance + battery_dim[0]/2 + wire_thickness
];

bms_dim = [30.4 + tolerance*2, 3.75 + tolerance*2, 2 + tolerance*2];
bms_contact_offset = [3, 12];


module battery() {
    cylinder(d = battery_dim[0], h = battery_dim[1]);
}

module contact_shape(pin_add = 0) {
    translate([-contact_dim[0]/2,-contact_dim[1]/2])
    union() {
        bl_square([contact_dim[0],contact_dim[1]], [3,3,1,1]);
        translate([(contact_dim[0] - contact_pin_dim[0])/2,0])
        bl_square(contact_pin_dim + [0,pin_add],[contact_pin_dim[0]/2,contact_pin_dim[0]/2,0,0]);
    }
}

module side_shape() {
    translate(battery_offset)
    hull() {
        circle(d = battery_offset[0]*2);
        translate([battery_offset[0]*2 - thickness,0])
        circle(d = battery_offset[0]*2);
    }
    bl_square([battery_offset[0]*4 - thickness,battery_offset[1]], [0,0,2,2]);
}

module contact_wall_shape() {
    difference() {
        side_shape();
        translate(battery_offset) {
            rotate(180)
            offset(tolerance)
            contact_shape(thickness+tolerance+battery_dim[0]/2);
            translate([battery_dim[0]+tolerance*2+thickness, 0])
            rotate(180)
            offset(tolerance)
            contact_shape(thickness+tolerance+battery_dim[0]/2);
        }
    }
}

module body_shape() {
    difference() {
        intersection() {
            side_shape();
            square([battery_offset[0]*4 - thickness,battery_offset[1] + battery_offset[0]*1/8]);
        }
        translate(battery_offset) {
            circle(d = battery_dim[0] + tolerance*2);
            translate([battery_offset[0]*2-thickness,0])
            circle(d = battery_dim[0] + tolerance*2);
        }
    }
}

module contact_body_shape() {
    difference() {
        body_shape();
        translate([battery_offset[0] - contact_pin_dim[0]/2 - tolerance, -1]) {
            square([contact_pin_dim[0] + tolerance*2, battery_offset[1]+1]);
            translate([battery_offset[0]*2-thickness, 0]) {
                square([contact_pin_dim[0] + tolerance*2, battery_offset[1]+1]);
            }
        }
    }
}

module bms() {
    cube(bms_dim);
    *for (i = [0:len(bms_contact_dim)-1]) {
        translate([bl_sum(bms_contact_offset, 0, i+1) + bl_sum(bms_contact_dim, 0, i), 0]) {
            cube([bms_contact_dim[i], bms_dim[1], bms_dim[2]]);
        }
    }
}


tower_thickness = [
    thickness, 
    contact_wall_thickness, 
    contact_body_thickness, 
    battery_dim[1] + contact_length - contact_body_thickness*2 - contact_wall_thickness*2,
    contact_body_thickness, 
    contact_wall_thickness, 
    thickness
];

total_thickness = bl_sum(tower_thickness);

module wire_sweeps() {

    wire_profile = concat(
        arc_points(wire_thickness/2, [0,0,180], 180),
        [[wire_thickness/2+tolerance,wire_thickness/2,0],[wire_thickness/2+tolerance,-wire_thickness/2,0]]
    );
    
    translate([0,wire_thickness/2,0]) {
        
        sweep(rounded_path([
            [battery_offset[0], 0, thickness], 
            [battery_offset[0], 0, total_thickness/2 - bms_dim[0]/2 + bms_contact_offset[0]], 5, 
            [0, 0, total_thickness/2 - bms_dim[0]/2 + bms_contact_offset[0]]
        ]), wire_profile);

        sweep(rounded_path([
            [0, 0, total_thickness/2 + bms_dim[0]/2 - bms_contact_offset[0]],
            [battery_offset[0], 0, total_thickness/2 + bms_dim[0]/2 - bms_contact_offset[0]], 5, 
            [battery_offset[0], 0, total_thickness-thickness]
        ]), wire_profile);
        
        sweep(rounded_path([
            [0, 0, total_thickness/2 + bms_dim[0]/2 - bms_contact_offset[1]],
            [battery_offset[0]*2 - thickness*2-wire_thickness*1.5, 0, total_thickness/2 + bms_dim[0]/2 - bms_contact_offset[1]], 5, 
            [battery_offset[0]*2 - thickness*2-wire_thickness*1.5, 0, total_thickness+tolerance]
        ]), wire_profile);
        
        sweep(rounded_path([
            [0, 0, total_thickness/2 - bms_dim[0]/2 + bms_contact_offset[1]],
            [battery_offset[0]*2 - thickness-wire_thickness*0.5, 0, total_thickness/2 - bms_dim[0]/2 + bms_contact_offset[1]], 5, 
            [battery_offset[0]*2 - thickness-wire_thickness*0.5, 0, total_thickness+tolerance]
        ]), wire_profile);
        
    }
    
}

module holder() {

    
    difference() {

        bl_extrude_tower(tower_thickness) {
            side_shape();
            contact_wall_shape();
            contact_body_shape();
            body_shape();
            contact_body_shape();
            contact_wall_shape();
            side_shape();
        }
       
        translate([0,bms_dim[2]+wire_thickness,bms_dim[0]+total_thickness/2-bms_dim[0]/2]) {
            
            
            #translate([-tolerance,0,0])
            rotate([0,90,-90])
            cube(bms_dim + [0,tolerance,wire_thickness+tolerance]);
            
            #translate([battery_offset[0]*4 - thickness - bms_dim[1],0,0])
            rotate([0,90,-90])
            cube(bms_dim + [0,tolerance,wire_thickness+tolerance]);
            
        }
        
        wire_sweeps();
        
        translate([battery_offset[0]*4-thickness,0,0])
        mirror([1,0,0])
        wire_sweeps();
            
    }
    
    translate([0,0,thickness+contact_length/2])
    translate(battery_offset)
    #if ($preview) {
        battery();
        translate([battery_offset[0]*2 - thickness,0,0])
        battery();
    }

}

translate([battery_offset[0]*4-thickness,0,0])
rotate([90,0,180])
holder();



