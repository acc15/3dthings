bolt_dia = 5 + 0.8;
z_thickness = 0.2 * 5;
xy_thickness = 0.48 * 3;

handle_dia = 30; 
nut_dia = 8.8 + 0.8;
nut_height = 6;

handle_cut_count = 6;
handle_cut_dia = 10;
handle_cut_distance = handle_dia / 2 + handle_cut_dia / 2 - 2;

wheel_offset = z_thickness * 2;

chamfer = 1;

$fa = 0.2;
$fs = 0.2;

module handle_shape() {
    difference() {
        circle(d = handle_dia);
        for (i = [0:handle_cut_count-1]) {
            angle = i * (360 / handle_cut_count);
            translate([cos(angle) * handle_cut_distance, sin(angle) * handle_cut_distance])
                circle(d = handle_cut_dia);
        }
    }
}

difference() {
    union() {
        cylinder(d2 = handle_dia, d1 = handle_dia - chamfer*2, h = chamfer);
        translate([0,0,nut_height + z_thickness - chamfer])
        cylinder(d2 = handle_dia - chamfer*2, d1 = handle_dia, h = chamfer);
        translate([0,0,chamfer])
        cylinder(d = handle_dia, h = nut_height + z_thickness - chamfer*2);
        
        translate([0,0,nut_height + z_thickness])
        cylinder(d = bolt_dia + xy_thickness * 2, h = wheel_offset);
    }


    for (i = [0:handle_cut_count-1]) {
        angle = i * (360 / handle_cut_count);
        translate([cos(angle) * handle_cut_distance, sin(angle) * handle_cut_distance, -1])
            cylinder(d = handle_cut_dia, h = nut_height + z_thickness + 2);
    }
    
    translate([0,0,-1])
    cylinder(d = nut_dia, h = nut_height + 1, $fn = 6);
    
    translate([0,0,nut_height - 1])
    cylinder(d = bolt_dia, h = z_thickness + wheel_offset + 2);
}