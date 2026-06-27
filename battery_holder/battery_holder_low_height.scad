use <bendlib/bendlib.scad>;
use <NopSCADlib/utils/sweep.scad>;
use <NopSCADlib/utils/maths.scad>;

$fa = 0.5;
$fs = 0.5;

tolerance = 0.2;
thickness = 1.5;

/* 18650 */
battery_dim = [18 + 0.5, 65];

contact_dim = [9.5,9,0.2];
contact_pin_dim = [2.5,15];
contact_length = 6;
contact_wall_thickness = 1;

wire_dia = 2;

bms_dim = [30.4 + tolerance*2, 3.75 + tolerance*2, 2];
bms_contact_offset = [3, 12];

battery_offset = [
    wire_dia/2 + bms_dim[2]*0.75 + thickness + battery_dim[0]/2,
    (wire_dia*3 + thickness*4)/2
];

battery_distance = battery_dim[0] + thickness;

holder_tower_thickness = [
    thickness, 
    contact_wall_thickness,
    wire_dia,
    battery_dim[1] + contact_length - (wire_dia*2 + contact_wall_thickness*2),
    wire_dia,
    contact_wall_thickness, 
    thickness + wire_dia
];

holder_dim = [
    battery_offset[0]*2 + battery_distance,
    battery_offset[1]*2,
    bl_sum(holder_tower_thickness)
];

module bms() {
    cube(bms_dim);
    
    *#if ($preview) {
        translate([bms_contact_offset[0] - bms_dim[1]/2,0])
        cube([bms_dim[1], bms_dim[1], bms_dim[2]]);
        translate([bms_contact_offset[1] - bms_dim[1]/2,0])
        cube([bms_dim[1], bms_dim[1], bms_dim[2]]);
        
        translate([bms_dim[0] - bms_contact_offset[1] - bms_dim[1]/2,0])
        cube([bms_dim[1], bms_dim[1], bms_dim[2]]);
        translate([bms_dim[0] - bms_contact_offset[0] - bms_dim[1]/2,0])    
        cube([bms_dim[1], bms_dim[1], bms_dim[2]]);
    }    
}


module battery() {
    cylinder(d = battery_dim[0], h = battery_dim[1]);
}

module contact_shape(pin_length = undef) {
    //translate([-contact_dim[0]/2,-contact_dim[1]/2])
    pl = pin_length == undef ? contact_pin_dim[1] : pin_length;
    union() {
        bl_square(bl_2d(contact_dim), [3,3,1,1], center=true);
        translate([0,pl/2])
        bl_square([contact_pin_dim[0], pl],[contact_pin_dim[0]/2,contact_pin_dim[0]/2,0,0], center=true);
    }
}

module contact_diff_shape() {
    offset(tolerance)
    contact_shape(battery_offset[0]+contact_pin_dim[0]/2);
}

module wall_shape() {
    bl_square(holder_dim);
}

module contact_wall_shape() {
    difference() {
        wall_shape();
        
        translate(battery_offset)
        rotate(90)
        contact_diff_shape();
        
        translate(battery_offset + [battery_distance,0])
        rotate(-90)
        contact_diff_shape();
    }
}

module side_shape() {
    union() {
        difference() {
            wall_shape();
            translate(battery_offset + [battery_distance/2,0])
            circle(d = battery_dim[0]*2+thickness);
            /*
            hull() {
                circle(d = battery_dim[0]);
                translate([battery_distance,0])
                circle(d = battery_dim[0]);
            }*/
        }
        translate([holder_dim[0]/2 - thickness/2,0])
        square([thickness,holder_dim[1]]);
    }
}

module contact_side_shape() {
    difference() {
        side_shape();
        
        translate(battery_offset)
        rotate(90)
        contact_diff_shape();
        
        translate(battery_offset + [battery_distance,0])
        rotate(-90)
        contact_diff_shape();
    }
}

module holder() {

    bl_extrude_tower(holder_tower_thickness) {
        wall_shape();
        contact_wall_shape();
        contact_side_shape();
        side_shape();
        contact_side_shape();
        contact_wall_shape();
        wall_shape();
    }

}

module holder_wires() {

    wire_profile = transform_points(concat(
        arc_points(wire_dia/2, [0,0,0], 180),
        [[-wire_dia/2-thickness,-wire_dia/2,0],[-wire_dia/2-thickness,wire_dia/2,0]]
    ), translate([0,0,0]));
    
    wire_circle = circle_points(wire_dia/2);

    hd_2 = (holder_dim[2]-wire_dia)/2;
    

    translate([-tolerance,holder_dim[1]/2-bms_dim[1]/2,hd_2-bms_dim[0]/2])
    cube([bms_dim[2]*0.75+wire_dia*0.5+tolerance,bms_dim[1],bms_dim[0]]);
        
    wire_radius = 3;
    wire_distance = bms_dim[1]/2+wire_dia;

    translate([0,holder_dim[1]/2,thickness+contact_wall_thickness])
    linear_extrude(hd_2 - bms_dim[0]/2 - thickness - contact_wall_thickness + bms_contact_offset[0])
    polygon(bl_2d(wire_profile));
    
    translate([0,holder_dim[1]/2,hd_2+bms_dim[0]/2 - bms_contact_offset[0]])
    linear_extrude(hd_2 - bms_dim[0]/2 - thickness - contact_wall_thickness + bms_contact_offset[0])
    polygon(bl_2d(wire_profile));
    
    sweep(rounded_path([
        [0,holder_dim[1]/2,hd_2-bms_dim[0]/2+bms_contact_offset[1]],
        [0,holder_dim[1]/2+wire_distance,hd_2-bms_dim[0]/2+bms_contact_offset[1]], wire_radius,
        [0,holder_dim[1]/2+wire_distance,holder_dim[2]], wire_radius,
        [holder_dim[0]/2-wire_dia*1.5-thickness*3,holder_dim[1]/2+wire_distance,holder_dim[2]]
    ]), wire_profile);
    
    sweep(rounded_path([
        [holder_dim[0]/2-wire_dia*2-thickness*3,holder_dim[1]/2+wire_distance,holder_dim[2]],
        [holder_dim[0]/2-thickness,holder_dim[1]/2+wire_distance,holder_dim[2]], wire_radius,
        [holder_dim[0]/2-thickness,holder_dim[1]/2+wire_distance,holder_dim[2]+5]
    ]), wire_circle);
    
    sweep(rounded_path([
        [0,holder_dim[1]/2,hd_2+bms_dim[0]/2-bms_contact_offset[1]],
        [0,holder_dim[1]/2-wire_distance,hd_2+bms_dim[0]/2-bms_contact_offset[1]], wire_radius,
        [0,holder_dim[1]/2-wire_distance,holder_dim[2]], wire_radius,
        [holder_dim[0]/2-wire_dia*1.5-thickness*3,holder_dim[1]/2-wire_distance,holder_dim[2]]
    ]), transform_points(wire_profile, rotate([0,0,180])));
    
    sweep(rounded_path([
        [holder_dim[0]/2-wire_dia*2-thickness*3,holder_dim[1]/2-wire_distance,holder_dim[2]],
        [holder_dim[0]/2-thickness,holder_dim[1]/2-wire_distance,holder_dim[2]], wire_radius,
        [holder_dim[0]/2-thickness,holder_dim[1]/2-wire_distance,holder_dim[2]+5]
    ]), wire_circle);
    
}

module holder_wired() {
    
    difference() {
        union() {
            holder();
            translate([holder_dim[0]/2,holder_dim[1],holder_dim[2]]) {
                translate([-wire_dia-thickness*2,0,0])
                rotate([90,0,0])
                cylinder(d = wire_dia+thickness*2,h=holder_dim[1]);
            
                translate([wire_dia+thickness*2,0,0])
                rotate([90,0,0])
                cylinder(d = wire_dia+thickness*2,h=holder_dim[1]);
            }
        }
        holder_wires();
        translate([holder_dim[0],0,0])
        mirror([1,0,0])
        holder_wires();
    }
    
}

    
translate([0,0,holder_dim[1]])
rotate([-90,0,0]) {
    holder_wired();

    #if ($preview) {
        translate([battery_offset[0],battery_offset[1],thickness+contact_length/2]) {
            battery();
            translate([battery_distance,0])
            battery();
        }
    }
}




