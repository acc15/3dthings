use <bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

bolt_head_d = 5.6;
bolt_head_h = 3;
bolt_d = 3.4;
bolt_nut_d = 5.4 * 2/sqrt(3); // m3 nut, inner dia = 5.4
bolt_nut_h = 2;

bolt_length = 30 + bolt_head_h;


rocker_spacing = [2, 2, 0];
rocker_dim = [30, 22, 26];
rocker_inner_dim = rocker_dim + rocker_spacing * 2;
rocker_contact_length = 10;


wire_d = 5.6;

t = 1.5;

strain_relief_length = 10;

box_outer_dim = [ 
    rocker_inner_dim[0] + strain_relief_length*2, 
    rocker_inner_dim[1] + t*2,
    bolt_length
];
box_rounding = 5;

strain_relief_offset = box_outer_dim[2] - rocker_inner_dim[2] + rocker_contact_length / 2;


module wire_diff_shape(distance, height, radius, depth = 0.75, pitch = 2, tolerance = 0.1) {
    union() {
        difference() {
            square([distance, height+tolerance]);
            for (i=[1:floor(height/pitch)]) {
                translate([distance-depth,i*pitch]) {
                    polygon([[depth,0],[depth+tolerance,0],[depth+tolerance,depth],[0,depth]]);
                }
            }
        }
        difference() {
            translate([0,-tolerance])
            square([distance + radius, radius + tolerance]);
            translate([distance + radius, radius])
            circle(radius, $fa = 0.2, $fs = 0.2);
        }
    }
}

module round_wire_diff(dia, height, radius, depth = 0.75, pitch = 2, tolerance = 0.1) {
    rotate_extrude() 
    wire_diff_shape(dia/2, height, radius, depth, pitch, tolerance);
}


module bolt_diff() {
    
    translate([0,0,bolt_length - bolt_head_h])
    cylinder(d = bolt_head_d, h = bolt_head_h + 1);
    
    translate([0,0,-1])
    cylinder(d = bolt_d, h = bolt_length + 2);
    
    translate([0,0,-1])
    cylinder(d = bolt_nut_d, h = bolt_nut_h + 1, $fn = 6);
}

bolt_distance_div = 5;


module rocker_box() {

    difference() {
        linear_extrude(box_outer_dim[2])
        bl_square(box_outer_dim, box_rounding);
        
        translate(bl_center(rocker_dim, box_outer_dim, [1,1,0]) + [0,0,t])
        cube([rocker_dim[0], rocker_dim[1], box_outer_dim[2]]);
        
        translate(bl_center(rocker_inner_dim, box_outer_dim, [1,1,0]) + [0,0,t])
        cube([rocker_inner_dim[0], rocker_inner_dim[1], box_outer_dim[2] - t*2]);
            
        translate([0,box_outer_dim[1]/2, strain_relief_offset]) {
            rotate([0,90,0])
            round_wire_diff(wire_d, strain_relief_length, 2);
        
            
            translate([box_outer_dim[0],0,0])
            mirror([1,0,0])
            rotate([0,90,0])
            round_wire_diff(wire_d, strain_relief_length, 2);
        }
        
        bl_quad_mirror(box_outer_dim, 4)
        translate([strain_relief_length/2, t + bolt_head_d/2,0])
        bolt_diff();
        
    }

}

module rocker_box_bottom() {
    intersection() {
        rocker_box();
        union() {
            cube([box_outer_dim[0], box_outer_dim[1], strain_relief_offset]);
            linear_extrude(box_outer_dim[2]/2)
            rocker_box_aligner(0.2);
        }
    }
}

module rocker_box_aligner(tolerance) {
    bl_quad_mirror(box_outer_dim, 4)
    bl_square([strain_relief_length - t - tolerance, t*2 + bolt_head_d - tolerance], [box_rounding-tolerance,0,0,0]);
}

module rocker_box_top() {

    translate([0, box_outer_dim[1], box_outer_dim[2]])
    rotate([180,0,0])
    intersection() {
        rocker_box();
        
        difference() {
            translate([0,0,strain_relief_offset])
            cube([box_outer_dim[0], box_outer_dim[1], box_outer_dim[2] - strain_relief_offset]);
            linear_extrude(box_outer_dim[2]/2)
            rocker_box_aligner(0);
        }
    }

}

rocker_box_top();

translate([0, box_outer_dim[1] + 1, 0])
rocker_box_bottom();