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
board_hole_d = 3.33;

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
        bl_four_holes(board_dim, board_hole_offsets) {
            circle(d=board_hole_d);
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


module box() {

    tolerance = 0.2;

    box_thickness = [0.48*3, 0.48*3, 0.3*5];
    box_extra_dim = [6, 1];
    box_dim = [ 
        board_dim[0] + box_extra_dim[0] + box_thickness[0]*2,
        board_dim[1] + box_extra_dim[1] + box_thickness[1]*2
    ];
    
    box_top_offset_z = screen_board_offset[2] + screen_board_dim[2] + screen_pin_height;
    
    box_button_dia = 5;
    box_button_height = box_thickness[2] + 2;
    box_button_ext_dia = box_button_dia + 2;
    
    box_button_offset_z = button_dim[2] + button_h;
    box_button_ext_height = box_top_offset_z - box_button_offset_z - tolerance;
    
    box_slider_offset_z = slider_dim[2];
    box_slider_ext_height = box_top_offset_z - box_slider_offset_z - tolerance;

    box_screen_tolerance = 1;

    bolt_head_dia = 6;
    bolt_head_len = 3;
    
    module box_bolt_edge(off) {
        
        ext_d = bolt_head_dia + tolerance*2 + box_thickness[0]*2;
        ext_h = bolt_head_len + tolerance + box_thickness[2];
        
        in_d = board_hole_d + tolerance*2 + box_thickness[0]*2;
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
            cylinder(d = board_hole_d + tolerance*2, h = in_h+ext_h+tolerance*2);
        }
    }

    module box_top() {

        translate([0,0,box_top_offset_z])
        linear_extrude(box_thickness[2])
        difference() {

            translate([-box_thickness[0]-box_extra_dim[0]/2, -box_thickness[1]-box_extra_dim[1]/2])
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
            
            bl_four_holes(board_dim, board_hole_offsets) {
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
                    bl_hull_ring((slider_handle_move - slider_handle_dim[0])*3, box_button_ext_dia+tolerance*2, box_thickness[0]);
                }
                
                bl_four_holes(board_dim, board_hole_offsets) {
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


    translate([0,0,board_dim[2]])
    box_top();

    *for (off = button_offsets) 
    translate([off[0]+button_dim[0]/2,off[1]+button_dim[1]/2,box_button_offset_z + tolerance/2])
    box_button();
    
    *for (off = slider_offsets) 
    translate([off[0]+(slider_dim[0]-slider_handle_move+slider_handle_dim[0])/2+(slider_handle_move-slider_handle_dim[0])*0,off[1]+slider_dim[1]/2,box_slider_offset_z + tolerance/2])
    box_slider();

}

*screen();

board_assembly();


*button();
*bnc_connector();


a = 0;


//for (i = [

box();
