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
heatsink_mount_pattern = [[0,0],[0,1],[1,0],[1,1]];
heatsink_fan_distance = [32, 32];
heatsink_fan_pattern = [[1,0],[1,1],[0,1]];
heatsink_fan_offset = [heatsink_length - 3, heatsink_width - 6] - heatsink_fan_distance;

heater_height = 38.7;

fan_height = 15;
fan_width = 51;
fan_length = 51.3;
fan_out_outer_dim = [20, fan_height];
fan_out_inner_dim = [17, 12.5];
fan_out_offset = [25,0,4];
fan_offset = [25.5,-17.5,0] + fan_out_offset;
fan_lock_width = 3.5;
fan_lock_offset = 0.5; // 0..1 interpolated with duct_in_outer_height
fan_left_half_dia = 44;
fan_right_half_dia = fan_length;
fan_left_half_offset = -1.8;
fan_right_half_offset = 1.85;
fan_hole_offsets = [[18,20], [20,23]];
fan_hole_dia = 4.6;
fan_hole_outer_dia = fan_hole_dia + 4;

heatsink_offset = [-heatsink_heater_offset[0],-heatsink_heater_offset[1],heater_height-heatsink_thickness-5];
heatsink_fan_z_distance = heatsink_offset[2] - fan_out_offset[2] - fan_height;

fan_mount_tolerance = 0.1;
fan_mount_height = heatsink_fan_z_distance - fan_mount_tolerance*2;
fan_mount_hole_dia = 4;
fan_mount_thickness = 0.2*8;
fan_mount_edge_thickness = 0.48*4;

duct_tolerance = 0.1;
duct_thickness = 0.48*2;
duct_mount_thickness = 0.2*12;
duct_mount_length = fan_mount_height - duct_thickness;
duct_mount_hole_dia = 2.5;

duct_inner_width = fan_out_outer_dim[0] + duct_tolerance*2;
duct_outer_width = duct_inner_width + duct_thickness*2;

duct_in_inner_height = fan_out_outer_dim[1] + duct_tolerance*2;
duct_in_outer_height = duct_in_inner_height + duct_thickness*2;
duct_in_inner_z = fan_out_offset[2] - duct_tolerance;
duct_in_outer_z = duct_in_inner_z - duct_thickness;
duct_in_length = 3; // in "nose" length

duct_out_inner_height = 2; // out hole size
duct_out_outer_height = duct_out_inner_height + duct_thickness*2;
duct_out_length = 4; // out "nose" length

duct_distance = 15; // distance from nozzle
duct_angle = 55; // flow angle (same as nozzle angle - 110/2)

heatsink_duct_z_distance = heatsink_offset[2] - duct_in_outer_z - duct_in_outer_height;
fan_to_heatsink_offset = [heatsink_offset[0] - fan_offset[0], heatsink_offset[1] - fan_offset[1]];
        

function rot(p, a) = [cos(a)*p[0]+sin(a)*p[1],cos(a)*p[1]-sin(a)*p[0]];

module xy_array(distance, points) {
    for (p = points) {
        translate([p[0] * distance[0], p[1] * distance[1]])
            children();    
    }
}

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
            xy_array(heatsink_fan_distance, heatsink_fan_pattern)
                circle(d = heatsink_hole_d);
        }
        
        translate(heatsink_heater_offset)
        circle(d = heatsink_nozzle_d);
        
        translate(heatsink_mount_offset) {
            xy_array(heatsink_mount_distance, heatsink_mount_pattern)
                circle(d = heatsink_hole_d);
        }
    }

}


module duct_inner_shape(t = 0) {
    polygon([
        rot([0,duct_distance-t], duct_angle),
        rot([0,duct_distance+duct_out_length], duct_angle),
        [ fan_out_offset[0], duct_in_inner_z + duct_in_inner_height ],
        [ fan_out_offset[0] + duct_in_length + t, duct_in_inner_z + duct_in_inner_height ],
        [ fan_out_offset[0] + duct_in_length + t, duct_in_inner_z ],
        [ fan_out_offset[0], duct_in_inner_z ],
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
    
        translate([fan_out_offset[0] + duct_in_length, duct_in_outer_z-1])
        square([duct_thickness+1, duct_in_outer_height + 2]);
   }
}

module duct() {
    
    linear_extrude(duct_thickness)
    difference() {
        duct_outer_shape();
        translate([fan_out_offset[0], duct_in_outer_z + duct_in_outer_height*fan_lock_offset-fan_lock_width/2])
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
    
    translate([fan_out_offset[0] + duct_in_length - duct_mount_thickness, duct_in_outer_z + duct_in_outer_height,0])
    difference() {
        cube([duct_mount_thickness, duct_mount_length, duct_outer_width]);
        
        translate([-1,duct_mount_length/2,duct_outer_width/2])
        rotate([0,90,0])
        cylinder(d = duct_mount_hole_dia, h = duct_mount_thickness + 2);
    }

}

module flow_test_cube() {
    color("green")
    rotate([0,duct_angle,0])
    translate([0,-duct_inner_width/2,0])
    cube([duct_out_inner_height,duct_inner_width,20]);
}


module half_circle(d) {
    difference() {
        circle(d = d);
        translate([0,-d/2-1])
        square([d/2+1, d+2]);
    }
}

module fan_mount_hull_shape() {

    union() {

        hull() {
            
            translate([-fan_width/2 + duct_in_length + fan_mount_tolerance, 0])
            square([fan_mount_thickness,fan_to_heatsink_offset[1] + heatsink_fan_offset[1] + heatsink_fan_distance[1]]);
    
            translate(-fan_hole_offsets[0])
            circle(d = fan_hole_outer_dia);
            translate([0,fan_left_half_offset])
            half_circle(fan_left_half_dia);
            
        }
        
        hull() {

            translate(fan_hole_offsets[1])
            circle(d = fan_hole_outer_dia);
            
            translate([0,fan_right_half_offset])
            mirror([1,0])
            half_circle(fan_right_half_dia);
        
            translate(fan_to_heatsink_offset)
            translate(heatsink_fan_offset)
            xy_array(heatsink_fan_distance, heatsink_fan_pattern)
            circle(d = 7);
            
        }
        
    }

}


module fan_mount_shape() {

    difference() {

        fan_mount_hull_shape();
        
        translate(-fan_hole_offsets[0])
        circle(d = fan_mount_hole_dia);
        
        translate(fan_hole_offsets[1])
        circle(d = fan_mount_hole_dia);
        
        translate(fan_to_heatsink_offset)
        translate(heatsink_fan_offset)
        xy_array(heatsink_fan_distance, heatsink_fan_pattern)
        circle(d = 3.5);
        
        circle(d = 35); 
    
    }
   
}

module fan_mount() {
    
    difference() {
    
        union() {
    
            linear_extrude(fan_mount_thickness)
            fan_mount_shape();
            
            linear_extrude(fan_mount_height)
            union() {
                difference() {
                    fan_mount_shape();
                    
                    offset(-fan_mount_edge_thickness)
                        fan_mount_shape();
                    
                    *translate([-fan_width/2,fan_length/2+fan_right_half_offset+duct_tolerance+duct_thickness-duct_outer_width-fan_mount_edge_thickness-fan_mount_tolerance*2])
                    square([fan_width/2,fan_mount_edge_thickness+fan_mount_tolerance*2]);

                }
                intersection() {
                    union() {
                        translate([-fan_mount_edge_thickness/2,-fan_length/2+fan_right_half_offset]) {
                            square([fan_mount_edge_thickness,fan_length + heatsink_width]);
                            
                            translate([-fan_width/4,0])
                            square([fan_mount_edge_thickness,fan_length + heatsink_width]);
                            
                            translate([fan_width/4,0])
                            square([fan_mount_edge_thickness,fan_length + heatsink_width]);
                        }
                        translate([-fan_width/2,+fan_length/2+fan_right_half_offset+duct_tolerance+duct_thickness])
                        square([fan_width, fan_mount_edge_thickness]);                        
                    }
                    
                    difference() {
                        fan_mount_hull_shape();
                        circle(d = 35); 
                    }
                }
            }
        }
        
        translate([-fan_width/2+duct_in_length-1,fan_length/2+fan_right_half_offset+duct_tolerance+duct_thickness-duct_outer_width/2,fan_mount_tolerance + duct_thickness + duct_mount_length/2])
        rotate([0,90,0])
        cylinder(d = duct_mount_hole_dia, h = fan_mount_edge_thickness + 2);
        
        translate(fan_to_heatsink_offset)
        translate(heatsink_fan_offset)
        xy_array(heatsink_fan_distance, heatsink_fan_pattern)
        cylinder(d1 = 6, d2 = 3.5, h = 2);
        
        
    }
}


module assembly() {
    color("red")
    translate([0,duct_outer_width/2,0])
    rotate([90,0,0]) // print mode
    duct();
    
    heater_block();
    
    *translate(heatsink_offset)
    heat_sink();
    
    translate([0,0,fan_height+fan_mount_tolerance])
    translate(fan_offset)
    color("blue")
    fan_mount();
    
    translate(fan_offset)
    rotate([0,0,-90])
    color("green")
    import("fan_model.stl");
}


echo(heatsink_z=heatsink_offset[2], fan_z=fan_out_offset[2], heatsink_fan_z_distance=heatsink_fan_z_distance, heatsink_duct_z_distance=heatsink_duct_z_distance, fan_mount_height=fan_mount_height, fan_mount_edge_height=fan_mount_height-fan_mount_thickness, duct_mount_length=duct_mount_length, duct_mount_bolt_length =duct_mount_thickness + fan_mount_edge_thickness);

*assembly();

rotate([0,90,0]) 
translate([-fan_out_offset[0]-duct_in_length, -duct_in_outer_z,0])
duct();
*fan_mount();

