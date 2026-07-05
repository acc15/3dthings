use <bendlib/bendlib.scad>;

$fa = 0.3;
$fs = 0.3;

m3_bolt_head_d = 5.6;
m3_bolt_head_h = 3;
m3_bolt_d = 3.2;

board_dim = [61, 82];
board_rounding = 3;
board_hole_offset = [3, 3];
board_hole_d = m3_bolt_d;
board_power_hole_offset = [3, board_hole_offset[1] + 36];
board_power_hole_d = 2;

thickness = 2;

battery_dim = [14.4, 49.4];
battery_count = 3;

contact_dim = [9.5,9,0.2];
contact_pin_dim = [2.5,15];
contact_length = 6;
contact_wall_thickness = 1;
contact_tolerance = 0.1;

holder_heights = [thickness, contact_wall_thickness, battery_dim[1] + contact_length, contact_wall_thickness, thickness];
holder_dim = [thickness + (battery_dim[0] + thickness) * battery_count,bl_sum(holder_heights), battery_dim[0] + thickness];

echo(bl_nd([undef,board_power_hole_offset,undef,board_power_hole_offset], 3));

module plane() {

    difference() {
        bl_square(board_dim, board_rounding);
        bl_quad_mirror(board_dim, 4)
           translate(board_hole_offset)
                circle(d = board_hole_d);
        bl_quad_mirror(board_dim, [board_power_hole_offset,undef,board_power_hole_offset])
            circle(d = board_power_hole_d);
    }

}

module contact_shape() {
    union() {
        bl_square(bl_2d(contact_dim), [3,3,1,1], center=true);
        translate([0,contact_pin_dim[1]/2-contact_dim[1]/2])
        bl_square(contact_pin_dim,[contact_pin_dim[0]/2,contact_pin_dim[0]/2,0,0], center=true);
    }
}

module battery_layout() {
    for (i = [0:battery_count-1]) {
        $index = i;
        translate([thickness + battery_dim[0]/2 + (thickness+battery_dim[0])*i, thickness + battery_dim[0]/2])
        children();
    }
}

module wall_shape() {
    bl_square([holder_dim[0], holder_dim[2]]);
}

module contact_wall_shape(reverse = false) {
    difference() {
        wall_shape();
        battery_layout() {
            rotate(($index + (reverse?1:0)) % 2 == 0 ? 90 : -90)
            offset(contact_tolerance)
            contact_shape();
        }
    }
}

module holder_shape() {
    difference() {
        wall_shape();
        battery_layout() {
            circle(d = battery_dim[0]);
        }
        translate([thickness, thickness + battery_dim[0]/2])
        square([(battery_dim[0] + thickness)*battery_count - thickness, battery_dim[0]/2 + 1]);
    }
}

module battery_holder() {

    translate([0,holder_dim[1],0])
    rotate([90,0,0])
    bl_extrude_tower([thickness, contact_wall_thickness, battery_dim[1] + contact_length, contact_wall_thickness, thickness]) {
        wall_shape();
        contact_wall_shape(true);
        holder_shape();
        contact_wall_shape(false);
        wall_shape();
    }

}

module base() {
    union() {
        linear_extrude(thickness)
        plane();

        translate([board_dim[0]/2 - holder_dim[0]/2, board_dim[1]/2-holder_dim[1]/2,0])
        battery_holder();
    }
}

module lid_shape() {

    difference() {
        bl_square(board_dim, board_rounding);
        
        difference() {
            offset(-thickness)
            bl_square(board_dim, board_rounding);
            
            bl_quad_mirror(board_dim, 4)
            offset(m3_bolt_head_d/2+thickness)
            square(board_hole_offset);
        }
        
        bl_quad_mirror(board_dim, 4)
        translate(board_hole_offset)
        circle(d=board_hole_d);
    }

}


module lid_head_shape() {
    difference() {
        
        bl_square(board_dim, board_rounding);
        
        bl_quad_mirror(board_dim, 4)
        offset(m3_bolt_head_d/2)
        square(board_hole_offset);
        
    }
}

module lid_inner_shape() {
    difference() {
        lid_head_shape();
        offset(-thickness)
        lid_head_shape();
    }
}

module lid() {
    bl_extrude_tower([holder_dim[2] - m3_bolt_head_h, m3_bolt_head_h-thickness, thickness]) {
        lid_shape();
        lid_inner_shape();
        lid_head_shape();
    }
}

base();

//translate([0,0,thickness])
*lid();




