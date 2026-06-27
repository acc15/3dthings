use <bendlib/bendlib.scad>;
use <NopSCADlib/utils/sweep.scad>;

function chip_dim(chip) = chip[0];
function chip_pin_dim(chip) = chip[1];
function chip_pin_offset(chip) = chip[2];
function chip_pins(chip) = chip[3];

chip_side_vector = [ [1,0], [0,1], [-1,0], [0,-1] ];

function chip_side_offset(chip, side) = bl_mul( bl_2d(chip_dim(chip))/2, chip_side_vector[side == 0 ? 3 : side-1] );
function chip_pin_count(chip, i = 0) = i < len(chip_pins(chip)) ? len(chip_pins(chip)[i]) + chip_pin_count(chip, i+1) : 0; 
function chip_pin_info(chip, pin, side=0) = let(pins=chip_pins(chip)) side < len(pins) 
    ? pin < len(pins[side]) ? [side, pins[side][pin]] : chip_pin_info(chip, pin - len(pins[side]), side+1)
    : undef;
function chip_pin_position(chip, pin) = let(info = chip_pin_info(chip, pin)) chip_side_offset(chip, info[0]) + chip_side_vector[info[0]]*info[1];

function chip_full_dim(chip) = let(pins = chip_pins(chip)) chip_dim(chip) + [ 
    ((len(pins[1])>0?1:0)+(len(pins[3])>0?1:0))*chip_pin_dim(chip)[1],
    ((len(pins[0])>0?1:0)+(len(pins[2])>0?1:0))*chip_pin_dim(chip)[1],
    chip_pin_offset(chip)
];

function chip_pins_so(pitch, count) = let(c1 = ceil(count/2), c2 = floor(count/2)) [
    [ for (i = [0:c1-1]) pitch*(-(c1-1)/2) + pitch*i ],
    [],
    [ for (i = [0:c2-1]) pitch*(c2-1)/2 - pitch*i ],
    []
];

function chip_sot23() = [ 
    [2.9, 1.3, 0.9],
    [0.4, (2.4 - 1.3)/2, 0.15],
    0.05,
    chip_pins_so(1.9, 3)
];

function chip_soic(pins, width = 4.4, length = undef, pin_length = undef) = [ 
    [length == undef ? pins / 2 * 1.27 : length, width, 1.5],
    [0.4, pin_length == undef ? width / 4.8 : undef, 0.15],
    0.05,
    chip_pins_so(1.27, pins)
];
  


module chip_pin_layout(chip) {
    for (side = [0:4]) {
        pins = chip_pins(chip)[side];
        rotate(side*90)
        translate([0,-chip_dim(chip)[1-side%2]/2])
        for (pin = pins) {
            translate([pin,0])
            children();
        }
    }
}

module chip_pin(chip, is_projection=false) {
    dim = chip_pin_dim(chip);
    translate([-dim[0]/2,-dim[1],0])
    if (is_projection) {
        bl_square(dim);
    } else {
        cube(dim);
    }
}

module chip(chip, is_projection=false) {
    dim = chip_dim(chip);
    
    color("gray")
    translate([-dim[0]/2,-dim[1]/2, chip_pin_offset(chip)])
    if (is_projection) {
        bl_square(dim);
    } else {
        difference() {
            cube(dim);
        
            translate([0.5,0.5,dim[2]-0.2])
            cylinder(d = 0.5, h = 1.2, $fn = 16);
        }
    }
    
    color("white")
    chip_pin_layout(chip) {
        chip_pin(chip, is_projection);
    }
}

module breadboard_grid(m = 11, n = 5) {
    pitch = 2.54;
    #for (i = [0:m-1]) {
        for (j = [0:n-1]) {
            translate([-((m-1)/2)*pitch + i*pitch, -(n-1)/2*pitch + j*pitch])
            circle(d = 0.8);
        }
    }
}

$fa = 0.2;
$fs = 0.2;


//chip = chip_soic(8);
chip = chip_sot23();

holder_thickness = 1.2;
holder_tolerance = 0.2;
holder_pin_wire_length = 10;
holder_wire_dia = 0.6 + 0.2;// + holder_tolerance*2;
holder_wire_height_coeff = 0.6;

holder_chip_full_dim = chip_full_dim(chip);
holder_pin_pitch = 2.54;
holder_base_dim = [
    ceil((holder_chip_full_dim[0] / 2) / holder_pin_pitch) * 2 * holder_pin_pitch, 
    ceil((holder_chip_full_dim[1] / 2) / holder_pin_pitch) * 2* holder_pin_pitch
] + bl_2d(holder_wire_dia + holder_thickness*2 + holder_tolerance*2);

$debug_hull_lines = true;


module hull_lines(d, points) {
    for (i = [0:len(points)-2]) {
        p1 = points[i];
        p2 = points[i+1];
        if ($debug_hull_lines) {
            echo("$debug_hull_lines", p1, p2, norm(p2 - p1), norm(p2-p1)-d);
        }
        hull() {
            translate(p1)
            circle(d = d);
            translate(p2)
            circle(d = d);
        }
    }
}

module holder_pin_mapping() {
    hull_lines(holder_wire_dia, [ 
        chip_pin_position(chip, 0), 
        [chip_pin_position(chip, 0)[0], -holder_pin_pitch], 
        [-holder_pin_pitch, -holder_pin_pitch]
    ]);

    hull_lines(holder_wire_dia, [ 
        chip_pin_position(chip, 1), 
        [chip_pin_position(chip, 1)[0], -holder_pin_pitch], 
        [holder_pin_pitch, -holder_pin_pitch]
    ]);

    hull_lines(holder_wire_dia, [ 
        chip_pin_position(chip, 2), 
        [chip_pin_position(chip, 2)[0], holder_pin_pitch]
    ]);
}


linear_extrude(holder_thickness)
difference() {
    bl_square(holder_base_dim, center=true);
    
    chip_pin_layout(chip) {
        circle(d = holder_wire_dia);
    }
    
    translate([-holder_pin_pitch, -holder_pin_pitch])
    circle(d = holder_wire_dia);
    translate([holder_pin_pitch, -holder_pin_pitch])
    circle(d = holder_wire_dia);
    translate([0, holder_pin_pitch])
    circle(d = holder_wire_dia);
    
}


translate([0,0,holder_thickness])
linear_extrude(holder_wire_dia*holder_wire_height_coeff)
difference() {
    bl_square(holder_base_dim, center=true);
    holder_pin_mapping();
}

translate([0,0,holder_thickness+holder_wire_dia*holder_wire_height_coeff])
linear_extrude(holder_chip_full_dim[2]/2) {
    difference() {
        bl_square([holder_base_dim[0], holder_chip_full_dim[1] + holder_thickness], center=true);
        offset(holder_tolerance)
        chip(chip, true);
        holder_pin_mapping();
    }
}


*translate([0,0,holder_thickness + holder_wire_dia*holder_wire_height_coeff])
chip(chip);

*breadboard_grid();




