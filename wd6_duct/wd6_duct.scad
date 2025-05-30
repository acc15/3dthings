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

heater_dimensions = [19, 33, 12];
heater_cut_dimensions = [17, 10];
heater_heater_dimensions = [6.15, 30.75];
heater_heater_offsets = [heater_cut_dimensions[0] - 9.5 - heater_heater_dimensions[0]/2, 1 + heater_heater_dimensions[0]/2];
heater_rtd_dimensions = [3.15, 30.75];
heater_rtd_offsets = [heater_heater_offsets[0], heater_dimensions[2] - 1 - heater_rtd_dimensions[0]/2];
heater_thread_dia = 7.85;
heater_thread_offsets = [heater_cut_dimensions[0] - 0.5 - heater_thread_dia/2, 11.15 + heater_thread_dia/2];
heater_nozzle_height = 7;
heater_nozzle_inner_dia = 9;
heater_nozzle_outer_dia = heater_nozzle_inner_dia * 2 / sqrt(3);
heater_nozzle_out_dia = 1.5;
heater_heatbreak_dia = 7.8;
heater_heatbreak_height = 19.75;
heater_height = heater_nozzle_height + heater_dimensions[2] + heater_heatbreak_height;

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

    translate([0,0,heater_nozzle_height + heater_dimensions[2]])
    cylinder(d = heater_heatbreak_dia, h = heater_heatbreak_height);
    
    translate([-heater_thread_offsets[0],heater_thread_offsets[1],heater_nozzle_height])
    rotate([90,0,0])
    difference() {
    
        linear_extrude(heater_dimensions[1])
        intersection() {
            square([heater_dimensions[0],heater_dimensions[2]]);
            translate([heater_dimensions[0]/2, heater_dimensions[2]/2])
            circle(d = heater_dimensions[0]);
        }
        
        translate([heater_cut_dimensions[0],-1,-1])
        cube([heater_dimensions[0] - heater_cut_dimensions[0] + 1, heater_dimensions[2]+2, heater_cut_dimensions[1]+1]);
        
        translate([heater_heater_offsets[0],heater_heater_offsets[1],-1])
        cylinder(d = heater_heater_dimensions[0], h = heater_heater_dimensions[1] + 1);
        
        translate([heater_rtd_offsets[0],heater_rtd_offsets[1],-1])
        cylinder(d = heater_rtd_dimensions[0], h = heater_rtd_dimensions[1] + 1);

        translate([heater_thread_offsets[0],heater_dimensions[2]+1,heater_thread_offsets[1]])
        rotate([90,0,0])
        cylinder(d = heater_thread_dia, h = heater_dimensions[2]+2);

    }
    
    
    rotate([0,0,30]) {
        translate([0,0,heater_nozzle_height/2])
        cylinder(d = heater_nozzle_outer_dia, h = heater_nozzle_height/2, $fn = 6);    
        intersection() {
            cylinder(d1 = heater_nozzle_out_dia, d2 = heater_nozzle_outer_dia, h = heater_nozzle_height/2);
            translate([0,0,-1])
            cylinder(d = heater_nozzle_outer_dia, h = heater_nozzle_height/2+2, $fn = 6);
        }
    }
    
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
    *color("red")
    translate([0,duct_outer_width/2,0])
    rotate([90,0,0]) // print mode
    duct();
    
    heater_block();
    
    translate(heatsink_offset)
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

assembly();

*rotate([0,90,0]) 
translate([-fan_out_offset[0]-duct_in_length, -duct_in_outer_z,0])
duct();
*fan_mount();

//heater_block();


//translate([0,0,fan_out_offset[2]])
ductv2();

module ductv2() {
    
    duct_thickness = 2;
    
    //duct_nozzle_hole_distance = 15;
    duct_heater_distance = 5;
    duct_hole_width = 3;
    duct_width = 15;
    duct_length = 5;
    
    duct_angle = 45;
    duct_tolerance = 0.1;
    
    duct_inout_length = fan_out_outer_dim[0]+duct_tolerance*2+duct_thickness*2;
    duct_height = fan_out_outer_dim[1]+duct_tolerance*2+duct_thickness*2;
    duct_z = fan_offset[2]-duct_tolerance-duct_thickness;
    
    module duct_outer_shape() {
        polygon([[0,0], [duct_width, 0], [duct_width, duct_height], [sin(duct_angle)*duct_width, duct_height]]);
    }
    
    module duct_shape() {
        //translate([duct_thickness, duct_thickness])
        difference() {
            duct_outer_shape();
            offset(-duct_thickness)
            duct_outer_shape();
        }
    }
    
    duct_r_distance = (heater_dimensions[0] - heater_thread_offsets[0]) + duct_heater_distance;
    duct_l_distance = heater_thread_offsets[0] + duct_heater_distance;
    duct_add_distance = (heater_dimensions[1] - heater_thread_offsets[1]) - duct_inout_length/2;
    duct_radius = duct_l_distance + duct_r_distance;
    
    
    translate([duct_r_distance+duct_width,0,duct_z])
    intersection() {
        rotate([0,0,45])
        translate([-duct_width*2,-duct_thickness/2,0])
        cube([duct_width * 4, duct_thickness, duct_height]);
        
        translate([0,50,0])
        rotate([90,0,0])
        linear_extrude(100)
        translate([-duct_width,0])
        duct_outer_shape();
    }
        
    
    #union() {
    
    translate([0,duct_inout_length/2,duct_z])
    rotate([90,0,0])
    linear_extrude(duct_inout_length + duct_add_distance)
    translate([duct_r_distance,0])
    duct_shape();
    
    translate([-duct_radius/2+duct_r_distance,-duct_inout_length/2-duct_add_distance,duct_z])
    rotate_extrude(angle = -180)
    translate([duct_radius/2,0])
    duct_shape();


    translate([0,duct_inout_length/2,duct_z])
    rotate([90,0,0])
    linear_extrude(duct_inout_length + duct_add_distance)
    translate([-duct_l_distance,0])
    mirror([-1,0])
    duct_shape();
        
    }
    
    
}


