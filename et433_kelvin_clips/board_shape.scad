use <bendlib/bendlib.scad>;

$fa = 0.4;
$fs = 0.4;

board_dim = [52,40];
board_hole_dia = 6;
board_hole_offset = [16,8];
board_pin_height = 23;
board_cut_width = 2;
board_cut_height = 7.5;
board_pin_rounding = 1.5;
// board_add_cut_height = 8;

board_pins = [
    [ 16, 3 ], 
    [ 16, 5 ]
];

case_tolerance = 0.2;
case_thickness = 1.5;
case_offset = 2;
case_inner_height = 7.5;
case_wire_dia = 7;
case_wire_length = 5;
case_board_thickness = 1.6;
case_board_outer_dia = 8;

case_dim = [
    board_dim[0] + case_offset*2 + case_thickness*2,
    board_dim[1] - board_pin_height + case_inner_height + case_thickness*2,
    case_inner_height + case_thickness*2
];

case_chamfer = min(case_dim) / 4;

case_board_offset = [
    case_thickness + case_offset, 
    -board_pin_height, 
    case_dim[2]/2-case_board_thickness/2
];

bolt_head_d = 5.4;
bolt_head_h = 3;
bolt_d = 3;
bolt_nut_d = 5.4 * 2/sqrt(3); // m3 nut, inner dia = 5.4
bolt_nut_h = 2;


module bolt_diff(l,tol,reverse=false) {
    translate([0,0,reverse?l:0])
    mirror([0,0,reverse?1:0])
    rotate([0,0,30]) {
        translate([0,0,-tol])
        cylinder(d = bolt_head_d+tol*2, h = bolt_head_h+tol*2);
        cylinder(d = bolt_d+tol*2, h = l);
        translate([0,0,l-bolt_nut_h-tol])
        cylinder(d = bolt_nut_d+tol*2, h = bolt_nut_h+tol*2, $fn=6);
    }
}


module board_shape() {
    
    difference() {
        square(board_dim);

        translate([board_hole_offset[0],board_dim[1]-board_hole_offset[1]])
        circle(d = board_hole_dia);
        
        translate([board_dim[0]-board_hole_offset[0],board_dim[1]-board_hole_offset[1]])
        circle(d = board_hole_dia);
        
        
        for (i = [0:len(board_pins)-1]) {
            pin = board_pins[i];
            off = i > 0 ? bl_sum([ for(j = [0:i-1]) board_pins[j][0] + board_pins[j][1] ], 0, i) : 0;
            translate([off + pin[0],0]) {
                translate([0,-1])
                bl_square([pin[1], board_pin_height + 1], [board_pin_rounding,0]);
                
                translate([-board_cut_width, board_pin_height - board_cut_height])
                bl_square([board_cut_width + pin[1], board_cut_height], min(board_cut_width/2,board_pin_rounding));
                /*translate([off[2], board_cut_height])
                bl_square([off[1] - off[2], board_pin_height - board_cut_height], board_pin_rounding);
                //translate([off[2] + board_cut_width, 0])
                square([off[1] - off[2] - board_cut_width, board_cut_height + 1]);
                if (off[2] > 0) {
                    translate([0, board_pin_height - board_add_cut_height])
                    bl_square([off[1], board_add_cut_height], board_pin_rounding);
                }*/
            }
        }
    }
}


module intersection_cube(dim) {
    intersection() {
        linear_extrude(dim[2])
        children(0);
        translate([0,0,dim[2]])
        rotate([-90,0,0])
        linear_extrude(dim[1])
        children(1);
        translate([0,0,dim[2]])
        rotate([0,90,0])
        linear_extrude(dim[0])
        children(2);
    }
}


module wire_diff_shape(distance, height, radius, tooth_depth = 0.75, tooth_pitch = 2, tolerance = 0.1) {
    
    union() {
        difference() {
            square([distance, height+tolerance]);
            for (i=[1:floor(height/tooth_pitch)]) {
                translate([distance-tooth_depth,i*tooth_pitch]) {
                    polygon([[tooth_depth,0],[tooth_depth+tolerance,0],[tooth_depth+tolerance,tooth_depth],[0,tooth_depth]]);
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

//wire_diff_shape(5, 10, 2);

module round_wire_diff(dia, height, radius) {
    rotate_extrude() 
    wire_diff_shape(dia/2, height, radius);
}

module quad_wire_diff(width, rounding, height, radius, tolerance = 0.1) {
    
    module a90() {
        translate([w/2,w/2]) {
            rotate_extrude(angle = 90) 
            wire_diff_shape(rounding, height, radius, tolerance = tolerance);
            
            rotate([90,0,0])
            linear_extrude(w)
            wire_diff_shape(rounding, height, radius, tolerance = tolerance);
        }
    }
    
    w = width - rounding*2;
    
    
    translate([-w/2-tolerance,-w/2-tolerance,-tolerance])
    cube([w+tolerance*2,w+tolerance*2,height+tolerance*2]);
    for(i=[0:3])
    rotate([0,0,i*90])
    a90();
    
    

}


*quad_wire_diff(7, 2, 10, 2);

module case_top() {
    bl_square([case_dim[0], case_dim[1]], [0,case_chamfer,0,0], $fn=1);
}

module case_front() {
    bl_square([case_dim[0], case_dim[2]], case_chamfer, $fn=1);
}

module case_left() {
    bl_square([case_dim[2], case_dim[1]], [case_chamfer,case_chamfer,0,0], $fn=1);
}

module case_cube() {
    intersection_cube(case_dim) {
        case_top();
        case_front();
        case_left();
    }
}


module case_box() {
    difference() {
        
        union() {
            case_cube();
            translate([case_dim[0]-case_chamfer,case_dim[1]-case_dim[2]/2,case_dim[2]/2])
            rotate([0,90,0])
            linear_extrude(case_wire_length+case_chamfer)
            bl_square(bl_2d(case_dim[2]), case_chamfer, $fn=1, center=true);
        }
        
        #translate([case_board_offset[0],0,case_board_offset[2]])
        linear_extrude(case_board_thickness)
        case_board_diff_shape();
        
        translate([case_dim[0]+case_wire_length,case_dim[1]-case_dim[2]/2,case_dim[2]/2])
        rotate([0,-90,0])
        quad_wire_diff(case_wire_dia, case_wire_dia/4, case_wire_length + case_chamfer, case_thickness);

        case_box_diff();

    }
}

module case_board_diff_shape() {
    height = case_thickness;
    echo(height);
    
    offset(delta=case_tolerance)
    difference() {
        square([board_dim[0], height]);
        for (off = board_cuts) {
            translate([off[0],-1])
            square([off[1], height+2]);
        }
    }
}

module case_bolt_hole_placement() {
    translate([case_board_offset[0], case_board_offset[1],0]) {
        translate([board_hole_offset[0],board_dim[1]-board_hole_offset[1],0]) {
            children();
        }
        translate([board_dim[0]-board_hole_offset[0],board_dim[1]-board_hole_offset[1]]) {
            children();
        }
    }
}

module case_box_diff() {    
    union() {
        difference() {
            intersection_cube(case_dim) {
                offset(-case_thickness) case_top();
                offset(-case_thickness) case_front();
                offset(-case_thickness) case_left();
            }
            case_bolt_hole_placement() 
            cylinder(d = 5.5, h = case_dim[2]);
        }
        translate([0,0,-1])
        case_bolt_hole_placement() 
        cylinder(d = bolt_d, h = case_dim[2] + 2);
    }
}



module case_parts() {
    cutoff = case_dim[2]/2+case_board_thickness/2;
    
    translate([1,0,0])
    intersection() {
        case_box();
        cube([case_dim[0]+case_wire_length, case_dim[1], cutoff]);
    }
    
    translate([-1,0,case_dim[2]])
    rotate([0,180,0])
    intersection() {
        case_box();
        translate([0,0,cutoff])
        cube([case_dim[0]+case_wire_length, case_dim[1], case_dim[2]]);
    }

}


*case_box_diff();

*case_box();
*case_parts();

board_shape();

