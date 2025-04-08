/*
translate([0,-140,0])
import("wanhao_duplicator_6_fan_duct_cooling_5015-B.STL");

module h() {
    hull() {
    circle(d = 3.4);
    translate([3.5,0,0])
    circle(d = 3.4);
    }
}

//color("green")
translate([61,65.555,19.9])
linear_extrude(4, $fa = 0.1, $fs = 0.1)
difference() {
offset(2.43)
h();
h();
}


//color("green")
translate([93,65.555,19.9])
linear_extrude(4, $fa = 0.1, $fs = 0.1)
difference() {
offset(2.43)
h();
h();
}*/

$fa = 0.2;
$fs = 0.2;

heatsink_width = 46;
heatsink_length = 68;
heatsink_thickness = 8;
heatsink_nozzle_d = 7.9;
heater_height = 38.7;

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
        
        translate([heatsink_length - 3, heatsink_width - 6])
        circle(d = 3.2);
        
        translate([heatsink_length - 3, heatsink_width - 6 - 32])
        circle(d = 3.2);
        
        translate([heatsink_length - 3 - 32, heatsink_width - 6])
        circle(d = 3.2);
        
        translate([2 + heatsink_nozzle_d/2,3 + heatsink_nozzle_d/2])
        circle(d = heatsink_nozzle_d);
        
        
        translate([4.25,heatsink_width-10])
        circle(d = 3.2);
        
        translate([4.25,heatsink_width-10-20])
        circle(d = 3.2);
        
        translate([4.25+17,heatsink_width-10])
        circle(d = 3.2);
        
        translate([4.25+17,heatsink_width-10-20])
        circle(d = 3.2);
    }

}

fan_hole_width = 12.7;
fan_hole_height = 17;

fan_out_pos = [25,10,6];

duct_thickness = 0.48*3;
duct_fanout_width = fan_hole_width;
duct_fanout_length = 3;
duct_nose_length = 2;
duct_width = 2;
duct_distance = 10;
duct_height = fan_hole_height;
duct_angle = 55;
//duct_height = 12.7;

duct_pos_z = fan_out_pos[2] + 1;


function rot(p, a) = [cos(a)*p[0]+sin(a)*p[1],cos(a)*p[1]-sin(a)*p[0]];

echo(rot([0,10], 55));

module duct_shape_inner(t = 0) {
    polygon([
        rot([0,duct_distance-t], duct_angle),
        rot([0,duct_distance+duct_nose_length], duct_angle),
        [ fan_out_pos[0], duct_pos_z + duct_fanout_width - duct_thickness ],
        [ fan_out_pos[0] + duct_fanout_length + t, duct_pos_z + duct_fanout_width - duct_thickness ],
        [ fan_out_pos[0] + duct_fanout_length + t, duct_pos_z + duct_thickness ],
        [ fan_out_pos[0], duct_pos_z + duct_thickness ],
        rot([duct_width,duct_distance+duct_nose_length], duct_angle),
        rot([duct_width,duct_distance-t], duct_angle)
    ]);
}

module duct_shape() {
   difference() {
        offset(delta=duct_thickness)
            duct_shape_inner();
    
        rotate(-duct_angle)
        translate([-duct_thickness-1, duct_distance-duct_thickness-1])
        square([duct_width + duct_thickness*2+2, duct_thickness+1]);
    
        translate([fan_out_pos[0] + duct_fanout_length, duct_pos_z-duct_thickness])
        square([duct_thickness+1, duct_fanout_width + duct_thickness*2]);
        
   }
}

module duct() {
    
    linear_extrude(duct_thickness)
    duct_shape();

    linear_extrude(duct_height)
    difference() {
        duct_shape();
        duct_shape_inner(duct_thickness);
    }

    translate([0,0,duct_height-duct_thickness])
    linear_extrude(duct_thickness)
    duct_shape();

}

rotate([0,90,0])
translate([-fan_out_pos[0]-duct_fanout_length, -duct_pos_z,0])
duct();

/*

*translate([0,fan_hole_height/2,0])
rotate([90,0,0])
duct();

*heater_block();

*translate([-2 - heatsink_nozzle_d/2,-3 - heatsink_nozzle_d/2,heater_height-heatsink_thickness-5])
heat_sink();

*#translate(fan_out_pos)
rotate([0,0,-90])
translate([-44.262,5.8,107])
import("fan.stl");*/