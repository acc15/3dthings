$fa = 0.2;
$fs = 0.2;

heatsink_width = 46;
heatsink_length = 68;
heatsink_thickness = 8;
heatsink_nozzle_d = 8;
heatsink_hole_d = 3.2;
heatsink_heater_offset = [6, 7];
heatsink_mount_distance = [17,20];
heatsink_mount_offset = [4.25, heatsink_width-10 - heatsink_mount_distance[1]];
heatsink_fan_distance = [32, 32];
heatsink_fan_offset = [heatsink_length - 3, heatsink_width - 6] - heatsink_fan_distance;

heater_height = 38.7;
heater_heatsink_z = 5;

module heater_block() {

    heatbreak_height = 19.7;

    translate([0,0,heater_height-heatbreak_height])
    cylinder(d = 7.8, h = heatbreak_height);
    
    translate([-19/2+2+9/2,33/2,12/2+7])
    rotate([90,0,0])
    linear_extrude(33)
    intersection() {
        square([19,12],center=true);
        circle(d = 19);
    }
    
    rotate([0,0,30])
    translate([0,0,3])
    cylinder(d = 9 * 2 / sqrt(3), h = 4, $fn = 6);
    
    cylinder(d1 = 0.6, d2 = 9, h = 3);
    
}


module heat_sink() {
    
    linear_extrude(heatsink_thickness)
    difference() {
        square([heatsink_length, heatsink_width]);
               
        translate(heatsink_fan_offset) {
            translate([0, heatsink_fan_distance[1]])
            circle(d = heatsink_hole_d);
            translate([heatsink_fan_distance[0], 0])
            circle(d = heatsink_hole_d);
            translate(heatsink_fan_distance)
            circle(d = heatsink_hole_d);
        }
        
        translate(heatsink_heater_offset)
        circle(d = heatsink_nozzle_d);
        
        translate(heatsink_mount_offset) {
             circle(d = heatsink_hole_d);
             translate([0,heatsink_mount_distance[1]])
             circle(d = heatsink_hole_d);
             translate([heatsink_mount_distance[0],heatsink_mount_distance[1]])
             circle(d = heatsink_hole_d);
             translate([heatsink_mount_distance[0],0])
             circle(d = heatsink_hole_d);
        }
    }

}

fan_height = 15;
fan_hole_outer_dim = [20, fan_height];
fan_hole_inner_dim = [17, 12.5];
fan_hole_offset = [25,0,6];
fan_lock_width = 3.5;
fan_lock_offset = 0.5; // 0..1 interpolated with duct_in_outer_height

duct_tolerance = 0.1;
duct_thickness = 0.48*2;

duct_inner_width = fan_hole_outer_dim[0] + duct_tolerance*2;
duct_outer_width = duct_inner_width + duct_thickness*2;

duct_in_inner_height = fan_hole_outer_dim[1] + duct_tolerance*2;
duct_in_outer_height = duct_in_inner_height + duct_thickness*2;
duct_in_inner_z = fan_hole_offset[2] - duct_tolerance;
duct_in_outer_z = duct_in_inner_z - duct_thickness;
duct_in_length = 3; // in "nose" length

duct_out_inner_height = 2; // out hole size
duct_out_outer_height = duct_out_inner_height + duct_thickness*2;
duct_out_length = 4; // out "nose" length

duct_distance = 10; // distance from nozzle
duct_angle = 55; // flow angle (same as nozzle angle - 110/2)

function rot(p, a) = [cos(a)*p[0]+sin(a)*p[1],cos(a)*p[1]-sin(a)*p[0]];

module duct_inner_shape(t = 0) {
    polygon([
        rot([0,duct_distance-t], duct_angle),
        rot([0,duct_distance+duct_out_length], duct_angle),
        [ fan_hole_offset[0], duct_in_inner_z + duct_in_inner_height ],
        [ fan_hole_offset[0] + duct_in_length + t, duct_in_inner_z + duct_in_inner_height ],
        [ fan_hole_offset[0] + duct_in_length + t, duct_in_inner_z ],
        [ fan_hole_offset[0], duct_in_inner_z ],
        rot([duct_out_inner_height,duct_distance+duct_out_length], duct_angle),
        rot([duct_out_inner_height,duct_distance-t], duct_angle)
    ]);
}

module duct_outer_shape() {
   difference() {
        offset(delta=duct_thickness)
            duct_inner_shape();
    
        rotate(-duct_angle)
        translate([-duct_thickness-1, duct_distance-duct_thickness-1])
        square([duct_outer_width+2, duct_thickness+1]);
    
        translate([fan_hole_offset[0] + duct_in_length, duct_in_outer_z-1])
        square([duct_thickness+1, duct_in_outer_height + 2]);
   }
}

module duct() {
    
    linear_extrude(duct_thickness)
    difference() {
        duct_outer_shape();
        translate([fan_hole_offset[0], duct_in_outer_z + duct_in_outer_height*fan_lock_offset-fan_lock_width/2])
        square([duct_in_length, fan_lock_width]);
    }

    linear_extrude(duct_outer_width)
    difference() {
        duct_outer_shape();
        duct_inner_shape(duct_thickness);
    }

    translate([0,0,duct_outer_width-duct_thickness])
    linear_extrude(duct_thickness)
    duct_outer_shape();

}

module flow_test_cube() {
    color("green")
    rotate([0,duct_angle,0])
    translate([0,-duct_inner_width/2,0])
    cube([duct_out_inner_height,duct_inner_width,20]);
}

//duct();


// duct (print mode)
*rotate([0,90,0]) 
translate([-fan_hole_offset[0]-duct_in_length, -duct_in_outer_z,0])
duct();

// duct (preview mode)
color("red")
translate([0,duct_outer_width/2,0])
rotate([90,0,0]) // print mode
duct();

#flow_test_cube();

heater_block();

heatsink_z = heater_height-heater_heatsink_z-heatsink_thickness;

translate([-heatsink_heater_offset[0],-heatsink_heater_offset[1],heatsink_z])
heat_sink();

#translate(fan_hole_offset)
translate([25.5,-17.5,0])
rotate([0,0,-90])
color("green")
import("fan_model.stl");

heatsink_fan_z_distance = heatsink_z - fan_hole_offset[2] - fan_height;
heatsink_duct_z_distance = heatsink_z - duct_in_outer_z - duct_in_outer_height;
echo(heatsink_z=heatsink_z, fan_z=fan_hole_offset[2], heatsink_fan_z_distance=heatsink_fan_z_distance, heatsink_duct_z_distance=heatsink_duct_z_distance);