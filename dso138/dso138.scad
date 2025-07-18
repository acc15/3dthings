use <../bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

board_dim = [117, 77, 1.6];
board_thickness = 1.6;
board_hole_offsets = [
    [5, 5], // left bottom
    [5, 5], // right bottom 
    [5, 5], // left top
    [5, 5], // right top
];
board_hole_dia = 3.3;

dc_dim = [9, 13.8, 10.75];
dc_offset = [board_dim[0] - 24.5, board_dim[1] - dc_dim[1]];

dc_xh_dim = [7.7,5.7,7];
dc_xh_offset = [board_dim[0] - 7 - dc_xh_dim[0], board_dim[1] - dc_dim[1]];

bnc_d = 9.6;
bnc_base = 8.6;
bnc_length = 22;
bnc_offset = [10.5, board_dim[1] - bnc_base];

button_dim = [6,6,4];
button_d = 3.5;
button_h = 1.5;

button_offsets = [
    [board_dim[0] - 18 - button_dim[0], 2.5],
    [board_dim[0] - 6 - button_dim[0], 15],
    [board_dim[0] - 6 - button_dim[0], 15 + 12.5*1],
    [board_dim[0] - 6 - button_dim[0], 15 + 12.5*2],
    [board_dim[0] - 6 - button_dim[0], 15 + 12.5*3]
];

slider_dim = [12.8, 7, 4.6];
slider_handle_dim = [2,2,6];
slider_handle_move = 6;

slider_offsets = [
    [6.5, 14],
    [6.5, 32],
    [6.5, 50]
];

screen_board_dim = [71.25,53.75,1.6];
screen_board_offset = [30,10,11.2];

screen_dim = [61, 43, 2.5];
screen_offset = [0.5, 6, screen_board_dim[2]];
screen_pin_height = 1.2;

trigged_led_dia = 4;
trigged_led_height = 5.5;
trigged_led_offset = [board_dim[0] - 29.5, 6.5+trigged_led_dia/2];

module board() {
    color("darkred")
    linear_extrude(board_dim[2])
    difference() {
        square([board_dim[0], board_dim[1]]);
        bl_quad_mirror(board_dim, board_hole_offsets) {
            circle(d=board_hole_dia);
        }
    }
}

module dc_connector() {
    color("black")
    cube(dc_dim);
}

module dc_xh_connector() {
    color("white")
    cube(dc_xh_dim);
}

module bnc_connector() {
    color("lightgray")
    translate([bnc_d/2,0,bnc_d/2])
    rotate([-90,0,0]) {
        cylinder(d = bnc_d, h = bnc_length);
        translate([-bnc_d/2,0,0])
        cube([bnc_d, bnc_d/2, bnc_base]);
    }
}

module slider(pos = 0) {
    color("black")
    translate([(slider_dim[0] - slider_handle_move)*0.5 + (slider_handle_move - slider_handle_dim[0]) * pos, (slider_dim[1] - slider_handle_dim[1])*0.5, slider_dim[2]])
    cube(slider_handle_dim);
    color("gray")
    cube(slider_dim);
        
    color("darkred")
    translate([(slider_dim[0] - slider_handle_move)*0.5, (slider_dim[1] - slider_handle_dim[1])*0.5, 0.5])
    cube([slider_handle_move, slider_handle_dim[1], slider_dim[2]]);
}

module button() {
    color("black")
    translate([button_dim[0]/2,button_dim[1]/2,button_dim[2]])
    cylinder(d = button_d, h = button_h);
    
    color("lightgray")
    cube(button_dim);
}

module screen() {
    color("red")
    cube(screen_board_dim);
    
    color("black")
    translate(screen_offset)
    cube(screen_dim);
}

module trigged_led() {
    color("green")
    cylinder(d = trigged_led_dia, h = trigged_led_height);
}

module board_assembly() {
    board();

    translate([0,0,board_thickness]) {

        translate(bnc_offset)
        bnc_connector();

        translate(dc_offset)
        dc_connector();
        
        translate(dc_xh_offset)
        dc_xh_connector();

        for (off = slider_offsets) 
            translate(off)    
                slider(0);
        
        
        for (off = button_offsets) 
            translate(off)
                button();
        
        translate(screen_board_offset)
        screen();
        
        translate(trigged_led_offset)
        trigged_led();

    }
}

module battery(dim, plus_pole=true) {
    d = dim[0];
    l = dim[1];
    
    if (plus_pole) {
        translate([0,0,l])
        color("red")
        cylinder(d = 5.5, h = 1);
    }
    
    translate([0,0,l*0.9])
    color("red")
    cylinder(d = d, h = l*0.1);
    
    translate([0,0,l*0.1])
    cylinder(d = d, h = l*0.8);
    
    color("black")
    cylinder(d = d, h = l*0.1);
}

tolerance = 0.2;

box_thickness = [0.48*3, 0.48*3, 0.3*5];
box_extra_dim = [6, 1];
box_dim = [ 
    board_dim[0] + box_extra_dim[0] + box_thickness[0]*2,
    board_dim[1] + box_extra_dim[1] + box_thickness[1]*2
];
box_angle = 15;

box_offset = [-box_thickness[0]-box_extra_dim[0]/2, -box_thickness[1]-box_extra_dim[1]/2];

box_top_offset_z = screen_board_offset[2] + screen_board_dim[2] + screen_pin_height;

box_button_dia = 5;
box_button_height = box_thickness[2] + 2;
box_button_ext_dia = box_button_dia + 2;

box_button_offset_z = button_dim[2] + button_h;
box_button_ext_height = box_top_offset_z - box_button_offset_z - tolerance;

box_slider_offset_z = slider_dim[2];
box_slider_ext_height = box_top_offset_z - box_slider_offset_z - tolerance;

box_screen_tolerance = 1;

box_hole_inner_dia = board_hole_dia + tolerance*2;
box_hole_ext_dia = box_hole_inner_dia + box_thickness[0]*2;

bolt_head_dia = 6;
bolt_head_len = 3;
bolt_len = 30 + bolt_head_len;

nut_d = 5.5; // M3 nut
nut_ext_d = nut_d * sin(60) + tolerance*2;
nut_len = 2.4;

box_board_protector_height = 6;
box_board_protector_distance = 2;

battery_dim = [18, 65];
battery_tolerance = 0.4;

battery_contact_dim = [9.5, 9, 0.4];
battery_contact_minus_len = 9;
battery_contact_plus_len = 1.5;
battery_contact_dia = 6;

box_battery_holder_contact_hole = battery_contact_dim[2] + tolerance;
box_battery_holder_contact_wall = 0.8;

box_battery_holder_dim = [ 
    box_thickness[0]*2 + battery_tolerance*2 + battery_dim[0],
    box_thickness[1]*2 + battery_tolerance*2 + battery_dim[1] + battery_contact_plus_len + battery_contact_minus_len/2,
    battery_dim[0]/2 + battery_tolerance + battery_contact_dim[1]/2
];

box_battery_count = 4;
box_battery_block_dim = [
    box_battery_holder_dim[0] * box_battery_count - box_thickness[0] * (box_battery_count - 1),
    box_battery_holder_dim[1],
    battery_dim[0]+battery_tolerance*2
];


box_top_height = box_top_offset_z + box_thickness[2];
box_bottom_height = box_thickness[2] + battery_dim[0]+battery_tolerance*2 + box_board_protector_height + tolerance*2 + board_dim[2]; 

cms4056t_dim = [24, 18, 1.2];
cms4056t_typec_dim = [9,7,3.2];
cms4056t_typec_offset = [2,13.15, cms4056t_dim[2]];
cms4056t_led_dim = [1,2,1];
cms4056t_led_offsets = [
    [13, cms4056t_dim[1]-2, cms4056t_dim[2]],
    [14.3, cms4056t_dim[1]-2, cms4056t_dim[2]]
];
cms4056t_pad_dim = [2,2];
cms4056t_pad_hole_dia = 1;
cms4056t_pad_offsets = [
    [0,0], 
    [8,0], 
    [cms4056t_dim[0]-cms4056t_pad_dim[0], 0], 
    [cms4056t_dim[0]-cms4056t_pad_dim[0] - 8, 0]
];

cms4056t_offset = [
    0,
    0,
    0
];

module nut_shape() {
    bl_ngon(nut_ext_d/2, 6);
}

module cms4056t_module() {
    color("black")
    difference() {
        cube(cms4056t_dim);
        translate([0,-tolerance,-tolerance])
        for (off = cms4056t_pad_offsets) {
            translate(off)
            cube([cms4056t_pad_dim[0], cms4056t_pad_dim[1]+tolerance, cms4056t_dim[2]+tolerance*2]);
        }
    }
    
    translate(cms4056t_typec_offset)
    translate([0,0,cms4056t_typec_dim[2]])
    rotate([-90,0,0])
    linear_extrude(cms4056t_typec_dim[1])
    bl_hull_circle(cms4056t_typec_dim[2], cms4056t_typec_dim[0]);
    
    color("blue")
    for (off = cms4056t_led_offsets) {
        translate(off)
        cube(cms4056t_led_dim);
    }
    
    color("lightgray")
    for (off = cms4056t_pad_offsets) {
        translate(off)
        linear_extrude(cms4056t_dim[2])
        translate(cms4056t_pad_dim/2)
        difference() {
            square(cms4056t_pad_dim, center=true);
            circle(d = cms4056t_pad_hole_dia);
        }
    }

}

module box_bolt_edge(off) {
    
    ext_d = bolt_head_dia + tolerance*2 + box_thickness[0]*2;
    ext_h = bolt_head_len + tolerance + box_thickness[2];
    
    in_d = box_hole_ext_dia;
    in_h = box_top_offset_z + box_thickness[2] - ext_h;
    
    difference() {
        translate(-off)
        union() {
        
            linear_extrude(in_h)
            bl_square([off[0] + in_d/2, off[1] + in_d/2], [in_d/2, 0, 0, 0]);
        
            translate([0,0,in_h])
            linear_extrude(ext_h)
            bl_square([off[0] + ext_d/2, off[1] + ext_d/2], [ext_d/2, 0, 0, 0]);
            
        }
        
        translate([0,0,in_h+box_thickness[2]])
        cylinder(d = bolt_head_dia + tolerance*2, h = bolt_head_len + tolerance*2);
        
        translate([0,0,-tolerance])
        cylinder(d = box_hole_inner_dia, h = in_h+ext_h+tolerance*2);
    }
}

module box_top() {

    translate([0,0,box_top_offset_z])
    linear_extrude(box_thickness[2])
    difference() {

        translate(box_offset)
        square(box_dim);

        translate(screen_board_offset + screen_offset)
        square([screen_dim[0], screen_dim[1]]);
        
        for (off = button_offsets) 
            translate(off + button_dim/2)
                circle(d = box_button_dia + tolerance*2);
        
        for (off = slider_offsets) {
            translate([off[0] + (slider_dim[0] - slider_handle_move + slider_handle_dim[0])/2, off[1] + slider_dim[1]/2]) {
                hull() {
                    circle(d = box_button_dia + tolerance*2);
                    translate([slider_handle_move - slider_handle_dim[0],0])
                    circle(d = box_button_dia + tolerance*2);
                }
            }
        }
        
        bl_quad_mirror(board_dim, board_hole_offsets) {
            circle(d=bolt_head_dia + tolerance*2);
        }
        
        translate(trigged_led_offset)
        circle(d = trigged_led_dia);
        
    }
    
    difference() {
    
        union() {
        
            for (off = button_offsets) {
                translate([off[0]+button_dim[0]/2,off[1]+button_dim[1]/2,box_button_offset_z + tolerance])
                linear_extrude(box_button_ext_height)
                bl_ring(box_button_ext_dia + tolerance*2, box_thickness[0]);
            }
            
            translate([trigged_led_offset[0],trigged_led_offset[1],board_dim[2]+trigged_led_height])
            linear_extrude(box_top_offset_z-board_dim[2]-trigged_led_height)
            bl_ring(trigged_led_dia, box_thickness[0]);
         
            for (off = slider_offsets) {
                translate([off[0]+slider_dim[0]/2-slider_handle_move, off[1] + slider_dim[1]/2, box_slider_offset_z+tolerance])
                linear_extrude(box_slider_ext_height)
                bl_hull_ring(box_button_ext_dia+tolerance*2, box_thickness[0], (slider_handle_move - slider_handle_dim[0])*3);
            }
            
            bl_quad_mirror(board_dim, board_hole_offsets) {
                box_bolt_edge([
                    $offset[0] + box_extra_dim[0]/2 + box_thickness[0], 
                    $offset[1] + box_extra_dim[1]/2 + box_thickness[1]
                ]);
            }
            
        }
        
        linear_extrude(box_top_offset_z)
        translate([screen_board_offset[0] - box_screen_tolerance, screen_board_offset[1] - box_screen_tolerance])
        square([screen_board_dim[0]+box_screen_tolerance*2, screen_board_dim[1]+box_screen_tolerance*2]);
        
    }
    
    
    render()
    difference() {
    
        translate([-box_thickness[0]-box_extra_dim[0]/2, -box_thickness[1]-box_extra_dim[1]/2,0])
        linear_extrude(box_top_offset_z + box_thickness[2])
        difference() {
            square(box_dim);
            translate([box_thickness[0], box_thickness[1]])
            square([box_dim[0] - box_thickness[0]*2, box_dim[1] - box_thickness[1]*2]);
        }
   
        translate([bnc_d/2+bnc_offset[0],box_dim[1]-box_thickness[1]-box_extra_dim[1]/2+tolerance,bnc_d/2])
        rotate([90,0,0])
        linear_extrude(box_thickness[1]+tolerance*2)
        bl_half_circle_square(bnc_d+tolerance*2);
        
        translate([dc_offset[0]-tolerance, dc_offset[1] + dc_dim[1] + box_extra_dim[1]/2 - tolerance,-tolerance])
        cube([dc_dim[0]+tolerance*2, box_thickness[1]+tolerance*2, dc_dim[2]+tolerance*2]);
        
    }
    
}

module box_board_protector() {
    r = box_hole_inner_dia/2 + tolerance + box_thickness[0];



    /*
    board_scale = 1;
    
    scaled_board_dim = [board_dim[0]*board_scale, board_dim[1]*board_scale];
    
    module scaled_board() {
        translate(board_dim*(1-board_scale)/2)
        difference() {
            square(scaled_board_dim);
            offset(-r*2)
            square(scaled_board_dim);
        }
    }
    
    module protector_shape() {
        bl_quad_mirror(board_dim, board_hole_offsets, move = false) {
            hull() {
                translate($offset)
                circle(d = box_hole_ext_dia);
                
                translate(board_dim*(1-board_scale)/2 + [r,r])
                circle(d = box_hole_ext_dia);
            }
        }
        scaled_board();

    }*/

    module protector_shape() {
        p_diag = [
            board_hole_offsets[0],
            [board_dim[0] - board_hole_offsets[1][0], board_hole_offsets[1][1]],
            [board_hole_offsets[2][0], board_dim[1] - board_hole_offsets[2][1]],
            [board_dim[0] - board_hole_offsets[3][0], board_dim[1] - board_hole_offsets[3][1]]
        ];
        
        p_direct = [p_diag[0], p_diag[1], p_diag[3], p_diag[2]];
        
        difference() {
            offset(r)
            polygon(p_diag);
            offset(-r)
            polygon(p_diag);
        }
        
        difference() {
            offset(r)
            polygon(p_direct);
            offset(-r)
            polygon(p_direct);
        }
    }

    difference() {
    
        union() {        
            linear_extrude(box_thickness[2])
            protector_shape();
            
            linear_extrude(box_board_protector_height - box_board_protector_distance)
            offset(-r+box_thickness[0]/2)
            protector_shape();
           
            bl_quad_mirror(board_dim, board_hole_offsets) {
                cylinder(r = r, h = box_board_protector_height);
            }
            
        }
    
        bl_quad_mirror(board_dim, board_hole_offsets) {
            translate([0,0,-tolerance])
            cylinder(d = box_hole_inner_dia, h = box_board_protector_height + tolerance * 2);
        }
    }
    
}

module battery_contact(plus = true) {
    rotate([90,0,180])
    union() {
        translate([-battery_contact_dim[0]/2,-battery_contact_dim[1]/2,0])
        linear_extrude(battery_contact_dim[2]) {
            bl_square(battery_contact_dim, [3,3,1,1]);
            translate([(battery_contact_dim[0]-2.4)/2,0])
            bl_square([2.4,15],[1.2,1.2,0,0]);
        }    
        cylinder(d = battery_contact_dia - tolerance*2, h = plus ? battery_contact_plus_len : battery_contact_minus_len);
    }
}

module box_battery_holder(with_battery = false) {
        
    module contact_diff() {
        union() {
            
            #translate([-battery_contact_dim[0]/2-tolerance, 0, -battery_contact_dim[1]/2-tolerance])
            cube([battery_contact_dim[0] + tolerance*2, box_battery_holder_contact_hole, (box_battery_holder_dim[2]+battery_contact_dim[1])/2 + tolerance*2]);
            
            #translate([0, box_battery_holder_contact_hole + box_battery_holder_contact_wall + tolerance, 0])
            rotate([90,-90,0])
            hull() {
                cylinder(d = battery_contact_dia, h = box_battery_holder_contact_hole + box_battery_holder_contact_wall + tolerance);
                translate([box_battery_holder_dim[2]/2,0,0])
                cylinder(d = battery_contact_dia, h = box_battery_holder_contact_hole + box_battery_holder_contact_wall + tolerance);
            }
        }
    }
    
    translate([0,0,box_thickness[2]])
    difference() {
        linear_extrude(box_battery_holder_dim[2])
        difference() {
            square([box_battery_holder_dim[0], box_battery_holder_dim[1]]);
            translate([box_thickness[0], box_thickness[1] + box_battery_holder_contact_wall + box_battery_holder_contact_hole])
            square(box_battery_holder_dim - [box_thickness[0]*2,box_thickness[1]*2+box_battery_holder_contact_wall*2+box_battery_holder_contact_hole*2]);
        }
        translate([box_battery_holder_dim[0]/2,0,battery_tolerance + battery_dim[0]/2]) {
            translate([0,box_thickness[1],0])
            contact_diff();
            
            translate([0,box_battery_holder_dim[1]-box_thickness[1],0])
            mirror([0,1,0])
            contact_diff();
        }
    }
    
    *cube([box_battery_holder_dim[0], box_battery_holder_dim[1], box_thickness[2]]);
    
    if (with_battery) {
        translate([box_battery_holder_dim[0]/2, 0, box_thickness[2] + battery_tolerance + battery_dim[0]/2]) {
            
            color("blue")
            translate([0, box_thickness[0] + tolerance, 0])
            battery_contact(false);
            
            color("red")
            translate([0, box_battery_holder_dim[1]-box_thickness[1]-tolerance, 0])
            mirror([0,1,0])
            battery_contact(true);
            
            translate([0, box_thickness[0] + battery_tolerance + battery_contact_minus_len/2, 0])
            rotate([-90,0,0])
            battery(battery_dim);
        }
    }

}

module box_bottom() {
    
    pad_height = box_thickness[2] + battery_dim[0] + battery_tolerance*2;
    
    render()
    difference() {

        union() {

            translate(box_offset)
            union() {
            
                linear_extrude(box_thickness[2])
                square(box_dim);
                
                *linear_extrude(box_bottom_height)
                difference() {
                    square(box_dim);
                    translate([box_thickness[0], box_thickness[1]])
                    square([box_dim[0] - box_thickness[0]*2, box_dim[1] - box_thickness[1]*2]);
                }
            }
            
            linear_extrude(pad_height)
            bl_quad_mirror(board_dim, board_hole_offsets) {
                translate(box_offset-$offset)
                bl_square([
                    $offset[0]-box_offset[0]+nut_ext_d/2+box_thickness[0], 
                    $offset[1]+nut_ext_d/2-box_offset[1]+box_thickness[1]], 
                    [(nut_ext_d+box_thickness[0])/2, 0, 0, 0]);
            }
            
        }
        
        
        
        bl_quad_mirror(board_dim, board_hole_offsets) {
            translate([0,0,-tolerance]) {
                linear_extrude(box_top_height + box_bottom_height - bolt_len + nut_len * 2 + tolerance)
                nut_shape();
            
                cylinder(d = box_hole_inner_dia, h = pad_height+tolerance*2);
            }
        }
    
    }
    
    
    translate([box_offset[0] + (box_dim[0] - box_battery_block_dim[0])/2, box_offset[1], 0]) {
        for (i=[0:box_battery_count]) {
            translate([(box_battery_holder_dim[0] - box_thickness[0])*i,0,0]) {
                if (i < box_battery_count) {
                    translate([0, (box_dim[1] - box_battery_block_dim[1])/2, 0])
                        box_battery_holder();
                }
                cube([box_thickness[0], box_dim[1], box_thickness[2] + box_battery_holder_dim[2]]);
            }
        }
    }
    
}

module bolt() {
    cylinder(d = 2.94, h = bolt_len);
    translate([0,0,bolt_len - bolt_head_len])
    cylinder(d = bolt_head_dia, h = bolt_head_len);
}


module box_button() {
    
    translate([0,0,box_button_ext_height])
    cylinder(d = box_button_dia, h = box_button_height);
    
    cylinder(d = box_button_ext_dia, h = box_button_ext_height);
}

module box_slider() {
    difference() {
    
        translate([-(slider_handle_move-slider_handle_dim[0]),0])
        linear_extrude(box_slider_ext_height)
        hull() {
            circle(d = box_button_ext_dia);
            translate([(slider_handle_move-slider_handle_dim[0])*2,0])
            circle(d = box_button_ext_dia);
        }

        translate([-slider_handle_dim[0]/2-tolerance, -slider_handle_dim[1]/2-tolerance,-tolerance])
        cube([slider_handle_dim[0] + tolerance*2, slider_handle_dim[1] + tolerance*2, slider_handle_dim[2] + tolerance*2]);
        
    }
    
    translate([0,0,box_slider_ext_height])
    cylinder(d = box_button_dia, h = box_button_height);

}

*battery_contact(false);

box_battery_holder(true);



*translate([0,0,board_dim[2]+box_top_height-bolt_len])
color("blue")
bl_quad_mirror(board_dim, board_hole_offsets) {
    bolt();
}


*board_assembly();

//rotate([180,0,0])
*translate([0,0,board_dim[2]])
box_top();

*translate([0,0,-box_bottom_height+board_dim[2]])
box_bottom();


*translate([0,0,-box_board_protector_height-tolerance])
//render()
box_board_protector();

*for (off = button_offsets) 
translate([off[0]+button_dim[0]/2,off[1]+button_dim[1]/2,box_button_offset_z + tolerance/2])
box_button();

*for (off = slider_offsets) 
translate([off[0]+(slider_dim[0]-slider_handle_move+slider_handle_dim[0])/2+(slider_handle_move-slider_handle_dim[0])*0,off[1]+slider_dim[1]/2,box_slider_offset_z + tolerance/2])
box_slider();

//*translate(cms4056t_offset)
*translate([
    -cms4056t_dim[1]-box_thickness[0]-tolerance,
    0,
    -box_board_protector_height-tolerance*3 - cms4056t_dim[2]-cms4056t_typec_dim[2]
])
translate([box_offset[0] + box_dim[0], cms4056t_dim[0]+board_hole_offsets[1][1]+nut_ext_d/2+box_thickness[1]+tolerance,0])
rotate([0,0,-90])
cms4056t_module();

*translate([
    -box_thickness[0] - 19 - tolerance,
    -40,
    -box_bottom_height+board_dim[2]
])
translate(box_offset + box_dim)
cube([19, 20, 12]);

echo(box_top_height, box_bottom_height, sum = box_top_height+box_bottom_height);
