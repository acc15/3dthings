use <bendlib/bendlib.scad>;

$fa = 0.5;
$fs = 0.5;

typec_dim = [9, 7.5, 3];

trigger_dim = [27.8, 11.2, 1.5];
trigger_chip_height = 1.5;

buck_dim = [22.5, 16.9, 3.5];

button_dim = [ 26.5, 8.1, 4];
button_contact_z = 2.6;
button_case_d = 7;

module typec() {   
    rotate([90,0,90])
    linear_extrude(typec_dim[1])
    bl_square([typec_dim[0], typec_dim[2]], typec_dim[2]/2);
}

module trigger() {
    
    translate([0, (trigger_dim[1]-typec_dim[0])/2, 0])
    typec();
    
    translate([0,0,typec_dim[2]])
    cube(trigger_dim);
}

module button() {

    cylinder(d = 4.5, h = 8);
    cylinder(d = button_case_d, h = 6);

    linear_extrude(button_dim[2])
    intersection() {
        circle(d = 12);
        square([12, button_dim[1]], center=true);
    }

    translate([0,0,button_contact_z])
    linear_extrude(0.2) {
        bl_square([14, 4.3], 0.5, center=true);
        bl_square([button_dim[0], 2], 1, center=true);
    }
    
}

*typec();

trigger_button_edge = 5;
buck_button_edge = 3;
button_z = typec_dim[2] + trigger_dim[2];

module layout_demo() {

    translate([0, buck_dim[1] - trigger_dim[1], 0])
    trigger();

    translate([trigger_dim[0] + button_dim[0]/2 - trigger_button_edge,buck_dim[1]-button_dim[1]/2, button_z - button_contact_z])
    button();

    translate([trigger_dim[0] + button_dim[0] - trigger_button_edge - buck_button_edge,0, button_z - buck_dim[2]])
    cube(buck_dim);

}

*layout_demo();

wire_d = 3;

case_thickness = 1.6;

case_inner_dim = [ 
    80 - case_thickness*2,
    buck_dim[1],
    typec_dim[2] + trigger_dim[2] + trigger_chip_height
];

case_inner_width = trigger_dim[0] + buck_dim[0] + button_dim[0] - trigger_button_edge - buck_button_edge;
wire_holder_width = case_inner_dim[0] - case_inner_width;

case_dim = case_inner_dim + bl_3d(case_thickness*2);

echo(case_inner_dim);

module wire_holder() {
    linear_extrude(wire_d)
    polygon([
        [-buck_button_edge,0], 
        [0,0], 
        [wire_d,buck_dim[1]/2 - wire_d/2], 
        [wire_holder_width+case_thickness+1,buck_dim[1]/2 - wire_d/2], 
        [wire_holder_width+case_thickness+1,buck_dim[1]/2 + wire_d/2], 
        [wire_d,buck_dim[1]/2 + wire_d/2], 
        [0,buck_dim[1]], 
        [-buck_button_edge,buck_dim[1]]
    ]);
}


module cut_shape() {
    translate([0, buck_dim[1] - trigger_dim[1], 0]) {
        translate([0,0,typec_dim[2]])
        cube([trigger_dim[0], trigger_dim[1], trigger_dim[2] + trigger_chip_height]);
    
        translate([typec_dim[1],(trigger_dim[1] - typec_dim[0])/2,typec_dim[2] + trigger_dim[2] + trigger_chip_height])
        rotate([-90,0,90])
        union() {
            translate([0,trigger_dim[2] + trigger_chip_height,typec_dim[1]-1])
            linear_extrude(case_thickness+2)
            bl_square([typec_dim[0], typec_dim[2]], typec_dim[2]/2);
    
            linear_extrude(typec_dim[1])
            bl_square([typec_dim[0], typec_dim[2] + trigger_dim[2] + trigger_chip_height], [typec_dim[2]/2, typec_dim[2]/2, 0, 0]);
        }
    }
    
    x_off = trigger_dim[0] - trigger_button_edge;
    
    translate([0,0,button_z - button_contact_z]) {
    
        linear_extrude(button_contact_z + trigger_chip_height)
        polygon([
            [0,buck_dim[1] - trigger_dim[1]],
            [x_off, buck_dim[1] - trigger_dim[1]], 
            [x_off + button_dim[0] - buck_button_edge, 0],
            [x_off + button_dim[0], 0],
            [x_off + button_dim[0], buck_dim[1]],
            [0, buck_dim[1]]
        ]);

        translate([x_off + button_dim[0]/2, buck_dim[1]-button_dim[1]/2, 0])
        cylinder(d = button_case_d, h = button_dim[2] + case_thickness + 1);
        
    }

    translate([x_off + button_dim[0] - buck_button_edge,0,button_z - buck_dim[2]])
    cube(buck_dim);
    
    translate([case_inner_width,0,case_inner_dim[2]/2-wire_d/2])
    wire_holder();
    
    $fa = 0.2;
    $fs = 0.2;
    
    translate([0,buck_dim[1]/2 - trigger_dim[1]/2,0]) {
        translate([trigger_dim[0] * 1 / 3,0,0])
        cylinder(d = 1.2, h = case_inner_dim[2] + case_thickness + 1);
            
        translate([trigger_dim[0] * 2 / 3,0,0])
        cylinder(d = 1.2, h = case_inner_dim[2] + case_thickness + 1);
    }
    
    translate([0,buck_dim[1]/2 - trigger_dim[1]/2,0]) {
        translate([trigger_dim[0] * 1 / 3,0,0])
        cylinder(d = 1.2, h = case_inner_dim[2] + case_thickness + 1);
            
        translate([trigger_dim[0] * 2 / 3,0,0])
        cylinder(d = 1.2, h = case_inner_dim[2] + case_thickness + 1);
    }
    
    translate([case_inner_dim[0] - wire_holder_width*1/3,0,0]) {
        translate([0, buck_dim[1] * 1 / 5, 0])
        cylinder(d = 1.2, h = case_inner_dim[2] + case_thickness + 1);
            
        translate([0, buck_dim[1] * 4 / 5, 0])
        cylinder(d = 1.2, h = case_inner_dim[2] + case_thickness + 1);
    }
        
}

*cut_shape();

*wire_holder();

module part(bottom = false) {
    
    cut_line = case_dim[2]/2+wire_d*3/8;
    
    translate(bottom ? [0,0,0] : [0, case_dim[1], case_dim[2] - cut_line])
    rotate([bottom ? 0 : 180,0,0])
    translate([0,0,bottom?0:-cut_line])
    intersection() {
        difference() {
            cube(case_dim);
            translate([case_thickness,case_thickness,case_thickness])
            cut_shape();
        }
        translate([0,0,bottom ? 0 : cut_line])
        cube([case_dim[0],case_dim[1], bottom ? cut_line : case_dim[2] - cut_line]);
    }
    
}


part(true);

translate([0, case_dim[1] + 1, 0])
part(false);



//*translate([case_thickness,case_thickness,case_thickness])
//#cut_shape();