use <MCAD/involute_gears.scad>

$fa = 0.5;
$fs = 0.5;

// rotation per 0.01s
motor_rpm = 6000;



base_pitch = 200;
base_twist = 200;
base_clearance = 0.2;
   
motor_base_h = 50.25;
motor_pad_h = 4.5;
motor_axis_h = 14;
motor_axis_d = 3.2;
motor_d = 36;
motor_h = motor_base_h + motor_pad_h + motor_axis_h;
motor_hole_dist = 25;
motor_hole_h = 5;
motor_hole_d = 3;
motor_pad_d = 13;

tolerance = 0.2;
thickness = 3;

gear_thickness = 6;
gear_axis_d = 5;
gear_axis_pad_d = 7;
gear_ratio_thickness = 10;
gear_drive_thickness = 10;
gear_ratio_z1 = 46;
gear_ratio_z2 = 12;
gear_drive_z = 10;
gear_main_z = 120;
gear_spacer_d = (out_r(gear_ratio_z2))*2;
gear_spacer_thickness = 2;
gear_main_thickness = gear_thickness;

gear_ratio_pitch_radius = gear_ratio_z1 * base_pitch / 360;
gear_drive_pitch_radius = gear_drive_z * base_pitch / 360;
gear_drive_ratio_cone = norm([gear_drive_pitch_radius, gear_ratio_pitch_radius]);
gear_angle_thickness = gear_ratio_thickness;
gear_angle_spacer_thickness = gear_drive_pitch_radius+tolerance+thickness+1+motor_d/2 - (gear_thickness + gear_angle_thickness)/2;
gear_angle_spacer_d = gear_spacer_d;

pad_thickness = 0.8;

psu_width = 59;
psu_height = 86;
psu_thickness = 32.75;

bearing_d = 12.75;
bearing_ext_ring_thickness = 1.5;
bearing_inner_d = 6.30;
bearing_thickness = 4.75;


table_d = 150;
table_rpm = motor_rpm / ((gear_main_z / gear_ratio_z2)*pow(gear_ratio_z1 / gear_ratio_z2,3));
echo(table_rpm = table_rpm, animate_step_30fps = 30 * 60 / table_rpm);
       
reducer_center_dist = pitch_r(gear_main_z)-pitch_r(gear_ratio_z2) - tolerance;
reducer_reducer_dist = pitch_r(gear_ratio_z2)+pitch_r(gear_ratio_z1) - tolerance;
reducer_start_angle = 63;
reducer_offset_angle = acos(1 - (reducer_reducer_dist*reducer_reducer_dist) / (2*reducer_center_dist*reducer_center_dist));

function reducer_angle(i) = reducer_start_angle - reducer_offset_angle*i;
function reducer_z_offset(i) = motor_d + thickness + 1 + (gear_thickness + gear_spacer_thickness + (gear_ratio_thickness - gear_thickness)/2)*i;

function pitch_r(z) = (z * base_pitch / 180)/2;
function out_r(z) = pitch_r(z) + base_pitch / 180;
function inner_r(z) = pitch_r(z) - (base_pitch / 180) - base_clearance;
    
module simple_gear(z, h, d, twist, clearance = base_clearance) {
    gear (circular_pitch=base_pitch,
        number_of_teeth = z,
        bore_diameter = d,
        gear_thickness = h, 
        rim_thickness = h,
        hub_thickness = 0, 
        backlash = 0,
        clearance = clearance,
        pressure_angle = 28,
        twist = twist * (base_twist / z));
}
 
module motor() {

    difference() {
        cylinder(d = motor_d, h = motor_base_h);
        
        translate([motor_hole_dist/2,0,motor_base_h - motor_hole_h])
        cylinder(d = motor_hole_d, h = motor_hole_h + tolerance);
        
        translate([-motor_hole_dist/2,0,motor_base_h - motor_hole_h])
        cylinder(d = motor_hole_d, h = motor_hole_h + tolerance);
    }
    translate([0,0,motor_base_h])
    cylinder(d = motor_pad_d, h = motor_pad_h);

    translate([0,0,-3.5])
    cylinder(d = 10.75, h = 3.5);

    translate([0,0,motor_base_h + motor_pad_h])
    cylinder(d = motor_axis_d, h = motor_axis_h);

}

module psu() {
    
    difference() {
        cube([psu_width, psu_height, psu_thickness]);
        translate([4.6 + 1.7, 81 + 1.7, -tolerance])
        cylinder(d = 3.4, h = 5 + tolerance);
        
        translate([psu_width - 4.6 - 1.7, 2 + 1.7, -tolerance])
        cylinder(d = 3.4, h = 5 + tolerance);
    }    
}

module helix_gear(z, h, d, twist, clearance = base_clearance) {

    translate([0,0,h/2])
    union() {
        
        in_r = inner_r(z);
        
        simple_gear(z, h/2, d, twist, clearance);
        
        mirror([0,0,1])
        simple_gear(z, h/2, d, twist, clearance);
    }
            
}

module reducer_gear(twist = 1) {
    difference() {
        union() {

            difference() {
                helix_gear(gear_ratio_z1, gear_thickness, 0, twist);
                translate([0,0,gear_thickness/2])
                cylinder(r = inner_r(gear_ratio_z1) - thickness, h = gear_thickness/2+tolerance);
            }

            translate([0,0,gear_thickness/2 - tolerance])
                cylinder(d = gear_spacer_d, h = gear_spacer_thickness + gear_thickness/2 + tolerance);

            translate([0,0,gear_thickness+gear_spacer_thickness])
                helix_gear(gear_ratio_z2, gear_ratio_thickness, 0, twist);
        }
        
        translate([0,0,-tolerance])
            cylinder(d = gear_axis_d+tolerance*4, h = gear_thickness + gear_spacer_thickness + gear_ratio_thickness + tolerance*2);
    }
}

module drive_gear() {
    //helix_gear(gear_drive_z, gear_drive_thickness, motor_axis_d, -1);
    
    bevel_gear (
    number_of_teeth=gear_drive_z,
    cone_distance=gear_drive_ratio_cone,
    face_width=gear_drive_thickness,
    pressure_angle=30,
    bore_diameter = motor_axis_d, // no tolerance here for good fit
    gear_thickness = gear_drive_thickness,
    outside_circular_pitch=base_pitch);
    
}

module platform_bottom() {
    
    linear_extrude(thickness)
    difference() {
        
        hull() {
            circle(d = motor_d);
            
            translate([pitch_r(gear_drive_z)+pitch_r(gear_ratio_z1)+pitch_r(gear_ratio_z2)+pitch_r(gear_ratio_z1), 0])
            circle(r = out_r(gear_ratio_z2));
        }
        
        circle(d = motor_pad_d + tolerance*4);
        translate([-motor_hole_dist/2,0])
        circle(d = motor_hole_d + tolerance*4);
        
        translate([motor_hole_dist/2,0])
        circle(d = motor_hole_d + tolerance*4);
        
        translate([pitch_r(gear_drive_z)+pitch_r(gear_ratio_z1),0])
        circle(d = gear_axis_d + tolerance*2);
        
        translate([pitch_r(gear_drive_z)+pitch_r(gear_ratio_z1)+pitch_r(gear_ratio_z2)+pitch_r(gear_ratio_z1),0])
        circle(d = gear_axis_d + tolerance*2);
    }
   
}

module platform_top() {
    
    linear_extrude(thickness)
    difference() {
        hull() {
            circle(r = out_r(gear_ratio_z2));
        
            translate([pitch_r(gear_ratio_z1)+pitch_r(gear_ratio_z2), 0])
                circle(r = out_r(gear_ratio_z2));
        }
        
        
        circle(d = gear_axis_d, $fn = 6);
        
        translate([pitch_r(gear_ratio_z1)+pitch_r(gear_ratio_z2),0])
        circle(d = gear_axis_d, $fn = 6);
    }
        
}

module gear_axis() {
    
    cylinder(d = gear_axis_d + tolerance*2, h = thickness);
    translate([0,0,thickness])
    cylinder(d = gear_axis_d, h = (gear_thickness + gear_ratio_thickness + gear_spacer_thickness) * 3 + (motor_axis_h - gear_thickness) + motor_pad_h );
    
    translate([0,0,(gear_thickness + gear_spacer_thickness) * 5 + (motor_axis_h - gear_thickness) + motor_pad_h + thickness])
    cylinder(d = gear_axis_d, h = thickness, $fn = 6);
    
}

module bearing() {
    
    linear_extrude(bearing_thickness)
    difference() {
        circle(d = bearing_d);
        circle(d = bearing_inner_d);
    }
    
}

module main_gear() {
    difference() {
        union() {
            
            cylinder(d = table_d - bearing_thickness*2 - tolerance*4, h = gear_main_thickness);
            
            translate([0,0,bearing_ext_ring_thickness])
            cylinder(d = table_d, h = gear_main_thickness - bearing_ext_ring_thickness);
        }
        translate([0,0,-tolerance])
        helix_gear(gear_main_z, gear_main_thickness + tolerance*2, 0, 1, 0);
    }
}

module pad(d, h) {
    linear_extrude(h)
    difference() {
        circle(d = d + pad_thickness*2);
        circle(d = d);
    }
}

module angle_ratio_gear() {
    difference() {
        
        union() {
            bevel_gear (
                number_of_teeth=gear_ratio_z1,
                cone_distance=gear_drive_ratio_cone,
                face_width=gear_drive_thickness,
                pressure_angle=30,
                bore_diameter=gear_axis_d + tolerance*2,
                gear_thickness = gear_thickness/2,
                outside_circular_pitch = base_pitch);

            cylinder(d = gear_angle_spacer_d, h = gear_angle_spacer_thickness + gear_thickness);

            translate([0,0,gear_thickness+gear_angle_spacer_thickness])
                helix_gear(gear_ratio_z2, gear_angle_thickness, 0, 1);
        }
        
        translate([0,0,-tolerance])
        cylinder(d = gear_axis_d+tolerance*2, h = gear_thickness + gear_angle_thickness + gear_angle_spacer_thickness + tolerance*2);
        
    }
}

module motor_with_angle_gears() {
    
    echo ("cone_distance", gear_drive_ratio_cone);
    pitch_angle1 = asin (gear_ratio_pitch_radius / gear_drive_ratio_cone);
    pitch_angle2 = asin (gear_drive_pitch_radius / gear_drive_ratio_cone);
    echo ("pitch_angle1, pitch_angle2", pitch_angle1, pitch_angle2);
    echo ("pitch_angle1 + pitch_angle2", pitch_angle1 + pitch_angle2);
        
    translate([0,0,motor_d / 2])
    union() { 
    
        translate([0,0,-gear_drive_pitch_radius-tolerance])
        angle_ratio_gear();
        
        rotate([-90,0,0])
        translate([0,0,-motor_h+gear_drive_thickness-gear_ratio_pitch_radius])
        union() {
        
            motor();
        
            translate([0,0,motor_h - gear_drive_thickness])
                drive_gear();
            
        }
    
    }

}

module gear_axis(i) {
    
    translate([0,0,tolerance])
    cylinder(d = gear_axis_pad_d, h = reducer_z_offset(i) - tolerance*2 - gear_ratio_thickness);

    translate([0,0,-tolerance-thickness])
    cylinder(d = gear_axis_d, h = reducer_z_offset(2) + gear_ratio_thickness + thickness * 2 + tolerance * 2);
    
}

module assembly() {

    echo(reducer_z_offset = reducer_z_offset(2));


    translate([0,0,reducer_z_offset(2)])
    main_gear();

    translate([cos(reducer_start_angle) * reducer_center_dist,sin(reducer_start_angle) * reducer_center_dist,0])
    motor_with_angle_gears();

    for (i = [1:2]) {

        rotate([0,0,reducer_angle(i)])
        translate([reducer_center_dist,0,reducer_z_offset(i-1)])
        reducer_gear(i % 2 == 0 ? 1 : -1);

    }

    n = 3;

    *for (i = [0:n-1]) 
        rotate((i*(360/n)+90))
        translate([table_d/2 - 4,0,0])
        cylinder(d = 8, h = reducer_z_offset(2));
    
    for (i = [0:n-1]) 
        rotate((i*(360/n)+90))
        translate([table_d/2 - bearing_thickness,0,reducer_z_offset(2) - bearing_d/2 + gear_main_thickness/2])
            rotate([0,90,0])
                bearing();

    cylinder(d = 8, h = reducer_z_offset(2));

    for (i = [0:2]) 
    rotate([0,0,reducer_angle(i)])
    translate([reducer_center_dist,0,0]) {

        gear_axis(i);
    }


    translate([-10,-psu_height/2,0])
    rotate([0,-90,0])
    psu();
    #cylinder(d = table_d, h = 60);

}

assembly();




/*
// 1x
*drive_gear();

// 2x
*reducer_gear(1);

// 2x
*reducer_gear(-1);

// 3x
*pad(gear_axis_d+tolerance*2, gear_spacer_thickness);

// 1x
// 6 by 2
*pad(gear_axis_d+tolerance*2, gear_thickness + gear_spacer_thickness*2);

// 1x
*pad(gear_axis_d+tolerance*2, motor_axis_h + motor_pad_h - gear_thickness - thickness); // 7.5 (3 by 2 + 1.5)

// 1x
*pad(gear_axis_d+tolerance*2, motor_axis_h + motor_pad_h + gear_spacer_thickness - thickness);

// 2x
*rotate([0,90,0])
difference() {
    gear_axis();
    translate([0,-gear_axis_d/2 - thickness/2, -tolerance])
    cube([gear_axis_d + thickness, gear_axis_d + thickness, (gear_thickness + gear_spacer_thickness) * 5 + (motor_axis_h - gear_thickness) + motor_pad_h + thickness*2 + tolerance*2]);
}
    

// 1x
*platform_bottom();

// 1x
*platform_top();

*psu();

*main_gear();*/