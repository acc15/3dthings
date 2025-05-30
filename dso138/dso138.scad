$fa = 0.2;
$fs = 0.2;

board_dim = [117, 77, 1.6];
board_thickness = 1.6;
board_hole_offsets = [
    [5, 5],
    [5, board_dim[1] - 5],
    [board_dim[0] - 5, 5],
    [board_dim[0] - 5, board_dim[1] - 5]
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
trigged_led_offset = [board_dim[0] - 29.5, 6.7];


jst_pin_base_dim = [2.5,2.5,1.5];
jst_pin_dim = [0.6,0.6,5.5];

module board() {
    color("darkred")
    linear_extrude(board_dim[2])
    difference() {
        square([board_dim[0], board_dim[1]]);
        for (off = board_hole_offsets) {
            translate(off) circle(d=board_hole_d);
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

module micro_usb() {
    cube(micro_usb_dim);
}

module jst_pins(counts) {
    nx = counts[0];
    ny = counts[1];
    
    color("black")
    cube([jst_pin_base_dim[0] * nx, jst_pin_base_dim[1] * ny, jst_pin_base_dim[2]]);
    
    color("lightgray")
    for (y = [0:ny-1]) {
        for (x = [0:nx-1]) {
            translate([
                x * jst_pin_base_dim[0] + (jst_pin_base_dim[0] - jst_pin_dim[0])/2, 
                y * jst_pin_base_dim[1] + (jst_pin_base_dim[1] - jst_pin_dim[1])/2, 
                jst_pin_base_dim[2]
            ])
            cube(jst_pin_dim);
        }
    }
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

*screen();

board_assembly();

*jst_pins(4, 1);

*button();
*bnc_connector();


tolerance = 0.2;

face_thickness = [0.48*3, 0.48*3, 0.3*5];
face_offset_z = board_dim[2] + screen_board_offset[2] + screen_board_dim[2] + screen_pin_height;
face_button_offset_z = board_dim[2] + button_dim[2] + button_h + tolerance;
face_button_dia = 5;
face_button_height = face_thickness[2] + 2;
face_button_ext_dia = face_button_dia + 2;
face_button_ext_height = face_offset_z - face_button_offset_z;

translate([0,0,face_offset_z])
linear_extrude(face_thickness[2])
difference() {

    translate([-tolerance-face_thickness[0], -tolerance-face_thickness[1]])
    square([
        board_dim[0] + tolerance * 2 + face_thickness[0] * 2,
        board_dim[1] + tolerance * 2 + face_thickness[1] * 2
    ]);

    translate(screen_board_offset + screen_offset)
    square([screen_dim[0], screen_dim[1]]);
    
    for (off = button_offsets) 
        translate(off + button_dim/2)
            circle(d = face_button_dia + tolerance*2);
    
}


module face_button() {
    translate([0,0,face_button_ext_height])
    cylinder(d = face_button_dia, h = face_button_height);
    
    cylinder(d = face_button_ext_dia, h = face_button_ext_height);
}

for (off = button_offsets) 
translate([off[0]+button_dim[0]/2,off[1]+button_dim[1]/2,face_button_offset_z])
face_button();
