use <../bendlib/bendlib.scad>;
use <../bendlib/cms4056t.scad>;
use <../bendlib/battery.scad>;
use <../bendlib/button.scad>;
use <../bendlib/led.scad>;

$fa = 0.2;
$fs = 0.2;


board_button = push_button(height = 9.5);
board_button_dim = push_button_dim(board_button);

battery_type = battery_18650();
battery_dim = battery_dim(battery_type);

board_dim = [81, 81, 1.5];
board_hole_dia = 3;
board_hole_offsets = bl_repeat(4, [3,3]);
board_7segment_dim = [50, 19, 8];
board_7segment_offset = [(board_dim[0]-board_7segment_dim[0])/2, 39, board_dim[2]];
board_led_type = led(dia = 3);
board_led_radius = 38;

board_button_y = board_dim[1] - 16 - board_button_dim[1];
board_button_offsets = [
    [25,board_button_y], 
    [board_dim[0] - 28 - board_button_dim[0], board_button_y]
];

module board_led_placement() {
    translate([board_dim[0]/2,board_dim[1]/2])
    for (i = [0:59]) {
        rotate(i/60*360)
        color(i % 5 == 0 ? "red" : "blue")
        translate([board_led_radius,0])
        children();
    }
}

module board() {

    color("#01437a")
    linear_extrude(board_dim[2])
    difference() {
        square(bl_2d(board_dim));
        bl_quad_mirror(board_dim, board_hole_offsets) {
            circle(d = board_hole_dia);
        }
    }

    translate(board_7segment_offset)
    cube(board_7segment_dim);

    translate([0,0,board_dim[2]])
    board_led_placement() {
        led(board_led_type, $fs = 0.7);
    }

    translate([board_dim[0],0,0])
    rotate([0,180,0]) {
        for (btn_offset = board_button_offsets) {
            translate(btn_offset)
            push_button(board_button);
        }
    }

}

box_thickness = [0.5*3, 0.5*3, 0.3*5];
box_tolerance = bl_3d(0.2);

box_dim = box_thickness*2 + box_tolerance*2 + [
    board_dim[0],
    battery_dim[0] + board_dim[1],
    battery_dim[0]
];


board_offset = box_thickness + box_tolerance +  [
    0,battery_dim[0],box_dim[2]-board_dim[2]-led_height(board_led_type)];

*linear_extrude(box_thickness[2])
difference() {
    square(bl_2d(box_dim));    
    translate(bl_2d(board_offset + board_7segment_offset) - bl_2d(box_tolerance))
    square(bl_2d(board_7segment_dim) + bl_2d(box_tolerance)*2);
    
    translate(bl_2d(board_offset))
    board_led_placement()
    circle(d=3.2);
}

#cube(box_dim);

module bottom_box() {
    
    bl_box([box_dim[0],box_dim[1], board_offset[2]+board_dim[2]], [box_thickness[0], box_thickness[1], [box_thickness[2],0]]);
}

bottom_box();


translate(board_offset)
board();

translate(box_thickness + box_tolerance + [battery_full_dim(battery_type)[1] + (board_dim[0] - battery_dim[1])/2, battery_dim[0]/2, battery_dim[0]/2])
rotate([0,270,0])
battery(battery_type);

box_hole_offsets = [[8,8],[8,8],[8,8],[8,8]];
box_hole_dia = 3.2;



battery_box = battery_box(thickness = box_thickness);

cms4056t = cms4056t();
cms4056t_dim = cms4056t_dim(cms4056t);

box_holder_dim = bl_mul(box_thickness,[2,2]) + bl_mul(box_tolerance, 2) + [
    box_dim[0], 
    box_dim[2], 
    cms4056t_dim[0]
];

button = button();
button_dim = button_body_dim(button);
