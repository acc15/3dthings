use <bendlib/bendlib.scad>;

$fa = 0.5;
$fs = 0.5;

m3_bolt_head_d = 5.6;
m3_bolt_head_h = 3;
m3_bolt_d = 3.2;
m3_nut_d = 5.4 * 2/sqrt(3);
m3_nut_h = 2.5;

m4_bolt_d = 4.2;
m4_nut_d = 6.84 * 2/sqrt(3);
m4_nut_h = 3.3;

hole_distance = 80;
hole_d = 5;
thickness = 0.4 * 5;

cut_dim = [39, 4];

width = 90;
height = 14.2;


base_dim = [hole_distance + m4_nut_d + thickness*2, width, height];
base_wire_hole_d = 6;
base_wire_hole_offset = [ thickness + base_wire_hole_d / 2, 20 ];
base_mount_wire_thickness = 3.3;
base_mount_hole_offset = [base_dim[0]/4,thickness*2 + m3_bolt_head_d/2 + base_mount_wire_thickness];


c_filter_d = 13.5;
c_filter_h = 18;
c_filter_full_length = 55;
c_filter_lead_length = 35;
c_filter_lead_distance = 9;

c_lim_width = 30;
c_lim_full_length = 55;
c_lim_length = 38; 
c_lim_res_length = 20;
c_lim_res_d = 5;
c_lim_center_space = 18;
c_lim_height = 9;

lid_dim = [base_dim[0], base_dim[1], c_filter_d + thickness];
lid_rounding = thickness*2;

module ear() {
    
    ear_h = height / 2 + m4_nut_d/2+thickness;
    
    translate([0,thickness + m4_nut_h,0])
    rotate([90,0,0])
    union() {
    
        difference() {
        
            linear_extrude(thickness + m4_nut_h)
            polygon([
                [0,0],
                [m4_nut_d + thickness, 0],
                [m4_nut_d + thickness + ear_h, ear_h],
                [0, ear_h]
            ]);
            
            translate([thickness + m4_nut_d/2,thickness + m4_nut_d/2,-1]) {
                rotate([0,0,30])
                cylinder(d = m4_nut_d, h = m4_nut_h + 1, $fn = 6);
                cylinder(d = m4_bolt_d, h = ear_h + 2);
            }
        }
        
        rotate([0,90,0])
        linear_extrude(thickness)
        polygon([
            [0,0],
            [ear_h, ear_h],
            [0, ear_h]
        ]);
        
    }
}

module vent_pattern(dim, w = thickness, t = thickness, angle = 45) {

    step = w+t;
    
    x1 = dim[1] * sin(angle);
    xl = cos(angle) * dim[0] + x1;
    yl = dim[0] * sin(angle) + dim[1] * cos(angle);
    count = floor(xl/step);
    
    off = floor(x1/step);
    
    intersection() {
        square(bl_2d(dim));
        rotate(-angle)
        for (i = [0:count]) {
            translate([-w/2 + (i-off) * step,0])
            square([w, yl]);
        }
    }
}

module inner_grid(dim, t, grid) {
    for (x=[1:grid[0]-1]) {
        translate([x*dim[0]/grid[0] - t/2,0])
        square([t,dim[1]]);
    }
    for (y=[1:grid[1]-1]) {
        translate([0,y*dim[1]/grid[1] - t/2,0])
        square([dim[0],t]);
    }
}

module base() {
    
    module base_shape() {
        difference() {
            square(bl_2d(base_dim));
            
            translate(base_wire_hole_offset)
            circle(d = base_wire_hole_d);
            
            translate([base_wire_hole_offset[0], base_dim[1] - base_wire_hole_offset[1]])
            circle(d = base_wire_hole_d);
            
            bl_quad_mirror(base_dim, 4)
            translate(base_mount_hole_offset)
            circle(d = m3_bolt_d);
        }
    }

    translate([0,0,height-thickness])
    union() {
        linear_extrude(thickness)
        difference() {
            base_shape();
            difference() {
                offset(-thickness*3)
                base_shape();
                inner_grid(base_dim, thickness, [4,4]);
                vent_pattern(base_dim, thickness*1.5, thickness);
            }
        }
        
        
        bl_quad_mirror(base_dim, 4)
        translate([base_mount_hole_offset[0], base_mount_hole_offset[1],-m3_nut_h])
        linear_extrude(m3_nut_h)
        difference() {
            circle(d = m3_nut_d + thickness*2);
            circle(d = m3_nut_d, $fn = 6);
        }
    }
        
    bl_quad_mirror(base_dim, 4)
    ear();
}

module top_round(dim, r) {
    
    module round_edge(l) {
        translate([-1,r,dim[2]-r])
        rotate([0,90,0])
        linear_extrude(l+2)
        difference() {
            translate([-r*2,-r*2])
            square([r*2, r*2]);
            circle(r = r);
        }
    }
    
    module round_edges() {
        round_edge(dim[0]);
        
        translate([0,dim[1],0])
        mirror([0,1,0])
        round_edge(dim[0]);
        
        rotate([0,0,90])
        mirror([0,1,0])
        round_edge(dim[1]);
        
        translate([dim[0],0,0])
        rotate([0,0,90])
        round_edge(dim[1]);
    }

    difference() {
        cube(dim);
        round_edges();
    }
    
}

module c_filter_box() {
    module lead() {        
        linear_extrude(c_filter_full_length+1)
        hull() {
            circle(d = 2);
            translate([c_filter_d/2,0])
            circle(d = 2);
        }
    }
    
    module cap_diff() {
        translate([0,0, c_filter_full_length - c_filter_lead_length]) {
            cylinder(d = c_filter_d, h = c_filter_lead_length);
            translate([0,-c_filter_d/2,0])
            cube([c_filter_d/2+1, c_filter_d, c_filter_lead_length]);
        }
        translate([0,c_filter_lead_distance/2,-1])
        lead();
        translate([0,-c_filter_lead_distance/2,-1])
        lead();
    }    
    
    difference() {
        cube([c_filter_full_length + thickness, c_filter_d + thickness*2, lid_dim[2]]);
            
        rotate([0,90,0])
        translate([-c_filter_d/2,c_filter_d/2+thickness,0])
        cap_diff();
    }
}


module c_lim_box() {
    
    dim = [c_lim_full_length + thickness, c_lim_width + thickness * 2, lid_dim[2]];
    
    difference() {
        cube(dim);
    
        translate([c_lim_full_length - c_lim_length, thickness, -1])
        cube([c_lim_length, c_lim_width, c_lim_height + 1]);
        
        translate([-1, thickness, -1])
        cube([c_lim_full_length+1, 2, c_lim_height/2+2]);
        
        translate([-1, c_lim_width, -1])
        cube([c_lim_full_length+1, 2, c_lim_height/2+2]);
        
        translate([c_lim_full_length - c_lim_length - c_lim_res_length, dim[1] - thickness*2-3, -1])
        cube([c_lim_res_length+1, thickness*2+4, dim[2]+2]);
        
        translate([-1, thickness*2 + 2, -1])
        cube([c_lim_full_length - c_lim_length - 1, c_lim_width - thickness*3 - 2, dim[2]+2]);
        
    }
}


module lid_base() {

    //translate([0,0,height])
    union() {
    
        difference() {
        
            union() {
            
                difference() {
                    top_round(lid_dim, lid_rounding);
                    translate([thickness, thickness, -1])
                    top_round(lid_dim - [thickness*2, thickness*2, thickness-1], lid_rounding-thickness);
                    
                    translate([-1,-1,thickness])
                    linear_extrude(lid_dim[2] - thickness - lid_rounding)
                    vent_pattern(base_dim+[2,2]);
                    
                }

                translate([(lid_dim[0] - c_filter_full_length - thickness)/2,20,0])
                c_filter_box();
                
                translate([(lid_dim[0] - c_lim_full_length - thickness)/2,20 + c_filter_d + thickness,0])
                c_lim_box();
                
            }
                        
            translate([0,0,c_lim_height])
            linear_extrude(lid_dim[2] - c_lim_height + 1)
            difference() {
                
                offset(-lid_rounding-thickness)
                square(bl_2d(lid_dim));
                
                vent_pattern(base_dim);
                
                inner_grid(base_dim, thickness, [4,4]);
                
                bl_quad_mirror(base_dim, 4)
                translate(base_mount_hole_offset)
                circle(d = m3_bolt_head_d + thickness*2);
                
            }
            
            bl_quad_mirror(base_dim, 4)
            translate([base_mount_hole_offset[0], base_mount_hole_offset[1], -1])
            cylinder(d = m3_bolt_head_d, h = lid_dim[2]+2);
            
        }
        
        
        bl_quad_mirror(base_dim, 4)
        translate(base_mount_hole_offset) {
            difference() {
                cylinder(d = m3_bolt_head_d + thickness*2, h = lid_dim[2]);
            
                translate([0,0,lid_dim[2]-m3_bolt_head_h])
                cylinder(d = m3_bolt_head_d, h = m3_bolt_head_h+1);
            
                translate([0,0,-1])
                cylinder(d = m3_bolt_d, h = lid_dim[2]+2);
            }
        }
        
    }
    
}


*c_lim_box();

*c_filter_box();


*base();

echo(distance = base_mount_hole_offset[1] - (m3_bolt_head_d/2 + thickness) - thickness);

translate([0,0,height])
lid_base();



