use <bendlib.scad>;

function battery(dim = undef, flat = undef) = [bl_def(dim, [18,65]), bl_def(flat, false)];
function battery_18650() = battery([18,65]);

function battery_dim(type) = type[0];
function battery_flat(type) = type[1];
function battery_tolerance(type) = type[1];

module battery(type = battery_18650()) {
    dim = battery_dim(type);
    flat = battery_flat(type);
    
    d = dim[0];
    l = dim[1];
    
    if (!flat) {
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

function battery_contact(
    dim = undef, 
    length = undef, 
    dia = undef
) = let(
    dim = bl_def(dim, [9.5, 9, 0.2]),
    length = bl_def(length, 1.5),
    dia = bl_def(dia, 6)
) [ dim, length, dia ];

function battery_contact_plus() = battery_contact();
function battery_contact_minus() = battery_contact(length = 9);
function battery_contact_dim(type) = type[0];
function battery_contact_length(type) = type[1];
function battery_contact_dia(type) = type[2];

module battery_contact(type = battery_contact_plus()) {
    dim = battery_contact_dim(type);
    length = battery_contact_length(type); 
    dia = battery_contact_dia(type);
    
    rotate([90,0,90])
    union() {
        translate([-dim[0]/2,-dim[1]/2,0])
        linear_extrude(dim[2]) {
            bl_square(dim, [3,3,1,1]);
            translate([(dim[0]-2.4)/2,0])
            bl_square([2.4,15],[1.2,1.2,0,0]);
        }
        cylinder(d = dia, h = length);
    }
}

function battery_contact_diff(
    contact = undef, 
    height = undef, 
    tolerance = undef, 
    wall = undef
) = let (
    contact = bl_def(contact, battery_contact_plus()),
    height = bl_def(height, battery_contact_dim(contact)[1]/2),
    tolerance = bl_def(tolerance, 0.2),
    wall = bl_def(wall, 0.8),
    contact_dim = battery_contact_dim(contact),
    dim = bl_mul(contact_dim, [1,0.5,1]) + [0,height,0] + bl_3d(tolerance)*2
) [ contact, height, tolerance, wall, dim ];

function battery_contact_diff_contact(type) = type[0];
function battery_contact_diff_height(type) = type[1];
function battery_contact_diff_tolerance(type) = type[2];
function battery_contact_diff_wall(type) = type[3];
function battery_contact_diff_dim(type) = type[4];

module battery_contact_diff(type = battery_contact_diff()) {
    contact = battery_contact_diff_contact(type);
    dim = battery_contact_diff_dim(type);
    dia = battery_contact_dia(contact);
    height = battery_contact_diff_height(type);
    tolerance = battery_contact_diff_tolerance(type);
    wall = battery_contact_diff_wall(type);
    
    rotate([90,0,90])
    union() {
        translate([-dim[0]/2,-dim[1]+height+tolerance,0])
        cube(dim);
        
        d = dia + tolerance*2;
        h = dim[2] + wall + tolerance;
        
        cylinder(d = d, h = h);
        translate([-d/2,0,0])
        cube([d, height + tolerance, h]);
    }
}

function battery_box(
    battery = undef,
    thickness = undef,
    battery_tolerance = undef,
    minus_contact = undef,
    plus_contact = undef,
    height = undef,
    tolerance = undef,
    wall = undef
) = let(
    battery = bl_def(battery, battery()),
    thickness = bl_3d(bl_def(thickness, 1.5)),
    battery_tolerance = bl_3d(bl_def(battery_tolerance, 0.5)),
    wall = bl_def(wall, 0.8),
    minus_contact = bl_def(minus_contact, battery_contact_minus()),
    plus_contact = bl_def(plus_contact, battery_contact_plus()),
    diff = battery_contact_diff(plus_contact, height, tolerance, wall),
    dim = bl_mul(thickness,[2,2]) + bl_mul(battery_tolerance, [2,2]) + [
        battery_contact_length(minus_contact) / 2 + battery_dim(battery)[1] + battery_contact_length(plus_contact),
        battery_dim(battery)[0],
        battery_dim(battery)[0]/2 + battery_contact_diff_height(diff)
    ],
    inner_dim = dim - bl_mul(thickness,[2,2]) - [
        (battery_contact_diff_dim(diff)[2]+battery_contact_diff_wall(diff))*2,
        0,
        -battery_tolerance[2]
    ]
) [
    battery,
    thickness,
    battery_tolerance,
    inner_dim,
    dim,
    minus_contact,
    plus_contact,
    diff
];

function battery_box_battery(type) = type[0];
function battery_box_thickness(type) = type[1];
function battery_box_battery_tolerance(type) = type[2];
function battery_box_inner_dim(type) = type[3];
function battery_box_dim(type) = type[4];
function battery_box_minus_contact(type) = type[5];
function battery_box_plus_contact(type) = type[6];
function battery_box_diff(type) = type[7];

module battery_box(type, with_battery = false, with_contacts = false) {
    battery = battery_box_battery(type);
    battery_dim = battery_dim(battery_box_battery(type));
    thickness = battery_box_thickness(type);
    battery_tolerance = battery_box_battery_tolerance(type);
    dim = battery_box_dim(type);
    inner_dim = battery_box_inner_dim(type);
    diff = battery_box_diff(type);

    off = [
        (dim[0] - inner_dim[0])/2, 
        dim[1]/2, 
        dim[2] - battery_contact_diff_height(diff)
    ];

    difference() {

        cube(dim);
        translate([off[0], thickness[1], thickness[2]])
        cube(inner_dim);
        
        translate([0, off[1], off[2]]) {
            translate([thickness[0], 0, 0])
            battery_contact_diff(diff);
            
            translate([dim[0]-thickness[0], 0,0])
            mirror([1,0,0])
            battery_contact_diff(diff);
        }
    }
    
    if (with_battery) {
        translate([dim[0] - battery_dim[1] - off[0] - battery_tolerance[0], off[1], off[2]])
        rotate([0,90,0])
        battery(battery);
    }
    
    if (with_contacts) {
        translate([0, off[1], off[2]]) {
            translate([thickness[0], 0, 0])
            battery_contact(battery_box_minus_contact(type));
            
            translate([dim[0] - thickness[0], 0, 0])
            mirror([1,0,0])
            battery_contact(battery_box_plus_contact(type));
        }
    }
}

$fa = 0.2;
$fs = 0.2;

*battery();
*battery_contact();
*battery_box(battery_box(), with_contacts = true);

*battery_contact_diff();

