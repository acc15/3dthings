$fa = 0.2;
$fs = 0.2;

dim_scale = 2.54;

board_thickness = 1.5;

thickness = 2;
mount_height = 0;
foot_height = 0.4;
lock_height = 0.4;
foot_width_max = 1.5;
foot_length_add = 1;
angle = 45;


sizes = [
    ["sot23", [ 3*dim_scale, 2*dim_scale ], [ 3, 1.7 ]],
    ["sop8", [ 4*dim_scale, 3*dim_scale ], [ 5, 5.1 ]],
    ["sop14", [ 7*dim_scale, 4*dim_scale ], [ 9, 5.1 ]],
];

function clip_add_height() = foot_height + mount_height;

function clip_width(clip_dim) = clip_dim[0] + board_thickness * tan(angle);
function clip_foot_width(clip_dim) = clip_dim[0] - clip_add_height() * tan(angle) * 2;
function clip_lock_width(clip_dim) = clip_dim[0] - lock_height * tan(angle) * 2;

function clip_outer_width(clip_dim) = clip_width(clip_dim) + thickness * 2 / cos(angle);
function clip_outer_foot_width(clip_dim) = clip_foot_width(clip_dim) + thickness * 2 * tan(45 - angle/2);
function clip_outer_lock_width(clip_dim) = clip_lock_width(clip_dim) + thickness * 2 / cos(angle);

module clip_shape(clip_dim) {
    right_part = [
        [clip_foot_width(clip_dim)/2, board_thickness/2 + clip_add_height()],
        [clip_width(clip_dim)/2, 0],
        [clip_lock_width(clip_dim)/2, -board_thickness/2 - lock_height], 
        [clip_outer_lock_width(clip_dim)/2, -board_thickness/2 - lock_height], 
        [clip_outer_width(clip_dim)/2, 0],
        [clip_outer_foot_width(clip_dim)/2, board_thickness/2 + clip_add_height() + thickness],
    ];
    left_part = [ for (i = [len(right_part)-1:-1:0]) [ -right_part[i][0], right_part[i][1] ] ];
    polygon(concat(right_part, left_part));
}

module clip_foot(size, t=thickness) {
    
    clip_dim = size[1];
    chip_dim = size[2];
    
    width = min(clip_dim[1], chip_dim[1]+foot_width_max*2);
    
    color("gray")
    translate([0,0,board_thickness/2]) {
        #linear_extrude(foot_height+mount_height+t)
        difference() {
            square([chip_dim[0] + foot_length_add*2, width],center=true);
            square([chip_dim[0] + foot_length_add*2 + 2, chip_dim[1]],center=true);
        }
        
        translate([0,0,foot_height])
        linear_extrude(mount_height+t)
        difference() {
            square([clip_foot_width(clip_dim), width], center=true);
            square(chip_dim,center=true);
        }
    }
}

module clip(size, with_foot=true, with_preview=true) {

    clip_dim = size[1];
    chip_dim = size[2];

    difference() {
        rotate([90,0,0])
        translate([0,0,-clip_dim[1]/2])
        linear_extrude(clip_dim[1])
        clip_shape(clip_dim);
        
        translate([0,0,thickness/2+board_thickness/2+foot_height+mount_height])
        cube([chip_dim[0], chip_dim[1], thickness+2], center=true);
    }
    
    
    if (with_foot) {
        clip_foot(size);
    }
    
    #if (with_preview && $preview) {
        cube([clip_dim[0], clip_dim[1], board_thickness], center=true);
    }
    
}

function by_preset(preset) = sizes[search([preset], sizes)[0]];


module printable() {
    rotate([180,0,0])
    children();
}

//printable() clip_foot(by_preset("sop8"), 0);

//*rotate([-180,0,0])
//clip_foot(by_preset("sop8"), 0);

//rotate([-180,0,0])
printable() clip(by_preset("sop8"));
//printable() clip(by_preset("sot23"));
