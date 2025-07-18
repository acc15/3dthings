use <../bendlib/bendlib.scad>;
use <../bendlib/cms4056t.scad>;
use <../bendlib/battery.scad>;
use <../bendlib/button.scad>;

$fa = 0.2;
$fs = 0.2;


//box_battery_holder_b/butcontact_hole = battery_contact_dim[2] + tolerance;
//box_battery_holder_contact_wall = 0.8;

box_dim = [91,91,26];
box_thickness = [0.5*3, 0.5*3, 0.3*5];
box_hole_offsets = [[8,8],[8,8],[8,8],[8,8]];
box_hole_dia = 3.2;
box_tolerance = bl_3d(0.2);


cms4056t = cms4056t();
cms4056t_dim = cms4056t_dim(cms4056t);

box_holder_dim = bl_mul(box_thickness,[2,2]) + bl_mul(box_tolerance, 2) + [
    box_dim[0], 
    box_dim[2], 
    cms4056t_dim[0]
];

button = button();
button_dim = button_body_dim(button);

battery_box = battery_box(thickness = box_thickness);

module box() {
    translate(box_thickness + box_tolerance + [0,box_dim[2],cms4056t_dim(cms4056t)[0]])
    rotate([90,0,0])
    difference() {
        cube(box_dim);
        bl_quad_mirror(box_dim, box_hole_offsets) {
            translate([0,0,-1])
            cylinder(d = box_hole_dia, h=box_dim[2]+2); 
        }
    }
}

button_offset = [box_holder_dim[0]/2, box_holder_dim[1] - button_body_dim(button)[2] - box_thickness[1] - box_tolerance[1], box_holder_dim[2]/2];

*translate(button_offset)
rotate([-90,0,0])
button(button);

cms4056t_offset = box_thickness + box_tolerance + [cms4056t_dim[1],box_dim[2] - cms4056t_dim[2],cms4056t_dim[0]];
cms4056t_transform = bl_move(cms4056t_offset) * bl_rot([0,90,90]);

*multmatrix(cms4056t_transform)
cms4056t(cms4056t);


module box_holder_mount() {
    h = box_tolerance[2] + box_hole_dia/2 + box_thickness[2];
    
    module box_holder_corner(off) {
        difference() {
            bl_square([
                box_thickness[0]*2 + box_tolerance[0] + off[0] + box_hole_dia/2, 
                h + off[1]
            ], radius = [box_hole_dia/2 + box_thickness[0],0,0,0]);
            translate([box_thickness[0] + box_tolerance[0] + off[0], off[1]])
            circle(d = box_hole_dia);
        }
    }

    module box_holder_corners() {
        rotate([90,0,0])
        linear_extrude(box_thickness[1]) {
            box_holder_corner(box_hole_offsets[0]);
            translate([box_holder_dim[0],0])
            mirror([1,0,0])
            box_holder_corner(box_hole_offsets[1]);
        }
    }

    translate([0,0,box_holder_dim[2] - box_tolerance[2]])
    union() {

        translate([0,box_holder_dim[1],0])
        box_holder_corners();

        translate([0,box_thickness[1],0])
        box_holder_corners();
        
        cube([box_thickness[0], box_holder_dim[1], h + box_hole_offsets[0][1]]);
        
        translate([box_holder_dim[0]-box_thickness[0],0,0])
        cube([box_thickness[0], box_holder_dim[1], h + box_hole_offsets[1][1]]);
        
    }
}


module box_holder() {
    difference() {
        union() {
            difference() {
                cube(box_holder_dim);
                translate(box_thickness)
                cube(box_holder_dim - box_thickness*2 + [0,0,box_thickness[2] + box_tolerance[2]]);
            }
            battery_box(battery_box);
            box_holder_mount();
            
            button_stand_dim = [button_body_dim(button)[0], box_thickness[1] + button_body_dim(button)[2], button_offset[2] - button_body_dim(button)[1]/2 - box_tolerance[2]];
            
            translate([button_offset[0] - button_body_dim(button)[0]/2,box_holder_dim[1] - button_stand_dim[1],0])
            cube(button_stand_dim);
        }

        multmatrix(cms4056t_transform)
        cms4056t_typec_diff(cms4056t, box_thickness[0], box_tolerance[1], box_tolerance[0]);
        
        translate([button_offset[0],box_holder_dim[1],button_offset[2]])
        rotate([-90,0,0])
        translate([0,0,-box_thickness[1]-box_tolerance[1]])
        cylinder(d = button_mount_dim(button)[0] + box_tolerance[0]*2, h = box_thickness[1] + box_tolerance[1]*2);
    }
}


echo(cms4056t_offset[1] - battery_box_dim(battery_box)[1]);
echo(button_offset[1] - battery_box_dim(battery_box)[1]);

module box_holder_plate() {

    wall_distance = box_holder_dim[1] - battery_box_dim(battery_box)[1] - box_thickness[1] - box_tolerance[1]*2;
    box_holder_plate_dim = [
        box_holder_dim[0] - cms4056t_dim(cms4056t)[1] - box_thickness[0]*2 - box_tolerance[0]*3,
        box_thickness[1],
        box_holder_dim[2] - box_thickness[2] - box_tolerance[2]*2
    ];

    translate(box_tolerance + [
        box_thickness[0] + box_tolerance[0] + cms4056t_dim(cms4056t)[1],
        battery_box_dim(battery_box)[1],
        box_thickness[2]
    ]) {
        cube(box_holder_plate_dim);
        translate([0,0,cms4056t_dim(cms4056t)[0]/2])
        cube([box_thickness[0],wall_distance,cms4056t_dim(cms4056t)[0]/2]);
    }
        
    translate([button_offset[0] - button_body_dim(button)[0]/2, battery_box_dim(battery_box)[1] + box_tolerance[1], button_offset[2] + button_body_dim(button)[1]/2 + box_tolerance[2]])
    cube([button_body_dim(button)[0],wall_distance,box_thickness[2]]);

}

box_holder_plate();
box_holder();

*box();



