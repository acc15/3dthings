use <../bendlib/bendlib.scad>;

$fa = 0.1;
$fs = 0.1;

tolerance = 0.2;

dsn_vc288_dim = [41, 21, 1];
dsn_vc288_mount_dim = [44, 5];
dsn_vc288_screen_dim = [23, 20, 8];
dsn_vc288_screen_offset = [(dsn_vc288_mount_dim[0] - dsn_vc288_screen_dim[0])/2, dsn_vc288_dim[1] - dsn_vc288_screen_dim[1], dsn_vc288_dim[2]];
dsn_vc288_holes = [
    ["-", 1, [5.5, dsn_vc288_dim[1] - 3.5]],
    ["+", 1, [5.5, dsn_vc288_dim[1] - 7.5]],
    ["+", 0.7, [3, 4.5]],
    ["-", 0.7, [5.5, 4.5]],
    ["v", 0.7, [8, 4.5]]
];

pd_dim = [26.25, 11, 1.65];
pd_typec_dim = [7.3,9,3.2];
pd_typec_offset = [-2,(pd_dim[1]-pd_typec_dim[1])/2,pd_dim[2]];
pd_switch_body_dim = [2.75, 3];
pd_switch_offsets = [
    [pd_dim[0] - 5, 2.75],
    [pd_dim[0] - 8, 2.75],
    [pd_dim[0] - 11, 2.75]
];
pd_power_hole = [1,2];
pd_power_offsets = [
    [pd_dim[0] - pd_power_hole[1]-0.6, 0.6],
    [pd_dim[0] - pd_power_hole[1]-0.6, pd_dim[1] - pd_power_hole[0] - 0.1]
];
pd_offset = [-pd_typec_dim[2]-tolerance,0,0];

switch_body_dim = [8.5, 4, 4];
switch_handle_dim = [1.5, 1.5, 5];
switch_move_width = 3.5;
switch_pin_dim = [0.5, 0.3, 4.5];


module dsn_vc288_shape() {
    translate([dsn_vc288_mount_dim[0]/2, dsn_vc288_dim[1]/2])
    union() {
        square(bl_nd(dsn_vc288_dim, 2), center = true);
        square(dsn_vc288_mount_dim, center = true);
    }
}

module dsn_vc288() {
    union() {
        color("green")
        linear_extrude(dsn_vc288_dim[2])
        difference() {
            dsn_vc288_shape();
            translate([(dsn_vc288_mount_dim[0] - dsn_vc288_dim[0])/2,0])
            for (hole = dsn_vc288_holes) {
                translate(hole[2]) {
                    circle(d = hole[1]*2);
                }
            }
        }
        
        translate([(dsn_vc288_mount_dim[0] - dsn_vc288_dim[0])/2,0,0]) {
            color("darkgray")
            linear_extrude(dsn_vc288_dim[2])
            for (hole = dsn_vc288_holes) {
                translate(hole[2]) {
                    difference() {
                        circle(d = hole[1]*2);
                        circle(d = hole[1]);
                    }
                }
            }
            if ($preview) {
                translate([0,0,-0.1])
                linear_extrude(dsn_vc288_dim[2]+0.2)            
                for (hole = dsn_vc288_holes) {
                    translate([hole[2][0],hole[2][1]+hole[1]]) {
                        text(hole[0], font="Nimbus Mono PS:style=Regular", size = 2, halign="center", valign="bottom");
                    }
                }
            }
        }
        
        translate(dsn_vc288_screen_offset)
        color("darkgray")
        cube(dsn_vc288_screen_dim);
    }
}

module pd_switch() {
    polygon(bl_arc(pd_switch_body_dim[0]/2, [0,180]));
    translate([0,pd_switch_body_dim[0]-pd_switch_body_dim[1]])
    polygon(bl_arc(pd_switch_body_dim[0]/2, [0,-180]));
}

module pd() {
    
    color("black")
    render()
    difference() {
        cube(pd_dim);
        translate([0,0,-1])
        linear_extrude(pd_dim[2]/2+1)
        for (off = pd_switch_offsets)
            translate(off)
                pd_switch();
        for (off = pd_power_offsets) 
            translate(off)
                translate([0,0,-1])
                linear_extrude(pd_dim[2]+2)
                offset(0.1)
                bl_hull_circle(pd_power_hole[0], pd_power_hole[1]);
        
    }
    
    color("gray")
    translate([pd_typec_dim[0],0,pd_typec_dim[2]]+pd_typec_offset)
    rotate([-90,0,90])
    linear_extrude(pd_typec_dim[0])
    bl_hull_circle(pd_typec_dim[2], pd_typec_dim[1]);
    
    linear_extrude(pd_dim[2]/2)
        for (off = pd_switch_offsets)
            translate(off)
                pd_switch();
        
    color("gray")
    for (off = pd_power_offsets) {
        translate(off)
        linear_extrude(pd_dim[2])
        difference() {
            offset(0.1)
            bl_hull_circle(pd_power_hole[0], pd_power_hole[1]);
            bl_hull_circle(pd_power_hole[0], pd_power_hole[1]);
        }
    }
    
}



module switch(position = 0) {
    for (i=[1:3])
        translate([i*switch_body_dim[0]/4, switch_body_dim[1]/2,0])
            translate([-switch_pin_dim[0]/2, -switch_pin_dim[1]/2,0])
                cube(switch_pin_dim);

    translate([0,0,switch_pin_dim[2]]) {
        color("darkgray")
        difference() {
            cube(switch_body_dim);
            translate([(switch_body_dim[0]-switch_move_width)/2, (switch_body_dim[1]-switch_handle_dim[1])/2, 1])
            cube([switch_move_width, switch_handle_dim[1], switch_body_dim[2]]);
        }

        translate([(switch_body_dim[0]-switch_move_width)/2, (switch_body_dim[1]-switch_handle_dim[1])/2, 0]) {
            color("gray") 
            translate([0,0,1])
            cube([switch_move_width, switch_handle_dim[1], switch_body_dim[2]-1]);
        
            color("black")
            translate([position * (switch_move_width-switch_handle_dim[0]),0,switch_body_dim[2]])
            cube(switch_handle_dim);
        }
    }
}

xh254_pin_holder_dim = [2.54, 2.54, 2.4];
xh254_pin_holder_cut_dim = [3,3];
xh254_pin_dim = [0.6, 0.6, 11];
xh254_pin_holder_offset = [0,0,3];
xh254_pin_offset = (bl_nd(xh254_pin_holder_dim,2)-bl_nd(xh254_pin_dim, 2)) / 2;

module xh254_pin() {
    color("black")
    translate(xh254_pin_holder_offset)
    linear_extrude(xh254_pin_holder_dim[2])
    intersection() {
        square(bl_nd(xh254_pin_holder_dim,2));
        translate(bl_nd(xh254_pin_holder_dim,2)/2)
        rotate(45)
        square(xh254_pin_holder_cut_dim, center=true);
    }
    
    color("lightgray")
    translate(xh254_pin_offset)
    cube(xh254_pin_dim);
}

xh254_connector_dim = [2.5, 5.7, 6.9];
xh254_connector_thickness = 0.75;
xh254_connector_pin_dim = [0.62, 0.62, 8.95];
xh254_connector_offset = [0,0,3];
xh254_connector_pin_offset = [2.5, 2, 0];

function xh254_connector_width(pin_count) = xh254_connector_dim[0] + xh254_connector_pin_offset[0]*pin_count;

module xh254_connector(pin_count) {
    width = xh254_connector_width(pin_count);
    cut_width = 2;
    cut_offset = 1.8;
    cut_height = 3.5;
    
    color("white")
    translate(xh254_connector_offset)
    render()
    difference() {
        union() {
            linear_extrude(xh254_connector_thickness)
            square([width, xh254_connector_dim[1]]);
        
            translate([0,0,xh254_connector_thickness])
            linear_extrude(xh254_connector_dim[2]-xh254_connector_thickness)
            difference() {
                square([width, xh254_connector_dim[1]]);
                offset(-xh254_connector_thickness)
                square([width, xh254_connector_dim[1]]);
            }
        }

        translate([-1,xh254_connector_thickness,xh254_connector_dim[2]-3])
        cube([width + 2, xh254_connector_thickness, 4]);
        
        
        translate([cut_offset,-1,xh254_connector_dim[2]-cut_height])
        cube([cut_width, xh254_connector_thickness + 2, cut_height+1]);
        
        translate([width-cut_offset-cut_width,-1,xh254_connector_dim[2]-cut_height])
        cube([cut_width, xh254_connector_thickness + 2, cut_height+1]);
    }
    
    color("gray")
    for (i=[1:pin_count]) {
        translate([xh254_connector_pin_offset[0]*i - xh254_connector_pin_dim[0]/2,xh254_connector_pin_offset[1],xh254_connector_pin_offset[2]])
            cube(xh254_connector_pin_dim);
    }
    
}

dc_connector_dim = [9, 11, 14];
dc_connector_outer_thickness = 3;
dc_connector_inner_dia = 8;
dc_connector_hole_dim = [6.3, 9.5];
dc_connector_pin_dim = [1.5, dc_connector_dim[2]-1.5];
dc_connector_contact_dim = [2, 4.7, 0.3];

module dc_connector() {
    color("#202020")
    difference() {
        union() {
            cylinder(d = dc_connector_inner_dia, h = dc_connector_dim[2]);
            translate([-dc_connector_dim[0]/2, -dc_connector_dim[1]+dc_connector_dim[0]/2,0]) {
                translate([0, 0, dc_connector_dim[2] - dc_connector_outer_thickness])
                cube([dc_connector_dim[0], dc_connector_dim[1], dc_connector_outer_thickness]);
                cube([dc_connector_dim[0], dc_connector_dim[1] - dc_connector_dim[0]/2, dc_connector_dim[2]]);
            }
        }
        translate([0,0,dc_connector_dim[2]-dc_connector_hole_dim[1]])
        cylinder(d = dc_connector_hole_dim[0], h = dc_connector_hole_dim[1] + 1);
    }
    color("lightgray")
    translate([0,0,1])
    cylinder(d = dc_connector_pin_dim[0], h = dc_connector_pin_dim[1]-1);

    module contact() {
        linear_extrude(dc_connector_contact_dim[2])
        translate([0,dc_connector_contact_dim[0]/2])
        rotate(180)
        bl_half_circle_square(dc_connector_contact_dim[0], dc_connector_contact_dim[1]);
    }

    color("lightgray")
    translate([0,dc_connector_dim[0]/2-dc_connector_dim[1]-dc_connector_contact_dim[1], 0]) {
        contact();
        translate([0,0,6])
        contact();
        translate([dc_connector_dim[0]/2,0, 2 + dc_connector_contact_dim[0]/2])
        rotate([0,-90,0])
        contact();
    }
}


dc_terminal_dia = 4.7;
dc_terminal_height = 5.5;
dc_terminal_bolt_width = 4;
dc_terminal_bolt_hole_dia = 2.4;
dc_terminal_hole_dia = 3.7;
dc_terminal_length = 11.56;
dc_terminal_bolt_dia = 2.2;
dc_terminal_bolt_head_dia = 3.8;
dc_terminal_bolt_length = 6.6;
dc_terminal_bolt_head_length = 2;

module dc_terminal(depth = 0) {

    module bolt() {
        cylinder(d = dc_terminal_bolt_dia, h = dc_terminal_bolt_length);
        translate([0,0,dc_terminal_bolt_length-dc_terminal_bolt_head_length])
        cylinder(d = dc_terminal_bolt_head_dia, h = dc_terminal_bolt_head_length);
    }

    color("gold")
    translate([0,dc_terminal_hole_dia/2-(dc_terminal_bolt_length-dc_terminal_bolt_head_length-(dc_terminal_height - dc_terminal_dia/2 - dc_terminal_hole_dia/2))*depth,0]) {
        translate([0,0,2.5])
        rotate([-90,0,0])
        bolt();
        translate([0,0,dc_terminal_length-2.5])
        rotate([-90,0,0])
        bolt();
    }
    
    color("gold")
    render()
    difference() {
        linear_extrude(dc_terminal_length)
        difference() {
            hull() {
                circle(d = dc_terminal_dia);
                translate([-dc_terminal_bolt_width/2,0])
                square([dc_terminal_bolt_width, dc_terminal_height - dc_terminal_dia/2]);
            }
            circle(d = dc_terminal_hole_dia);
        }

        translate([0,0,2.5])
        rotate([-90,0,0])
        cylinder(d = dc_terminal_bolt_hole_dia, h = dc_terminal_height);
        
        translate([0,0,dc_terminal_length-2.5])
        rotate([-90,0,0])
        cylinder(d = dc_terminal_bolt_hole_dia, h = dc_terminal_height);
    }
}


module pd_with_switches(pos = 0) {
    translate([switch_body_dim[2]+switch_pin_dim[2],pd_dim[0],pd_dim[1]])
    rotate([-90,0,-90]) {
        pd();
        for (i = [0:len(pd_switch_offsets)-1]) {
            translate([-switch_body_dim[1]/2 + pd_switch_offsets[1][0] + (switch_body_dim[1]+tolerance)*(i-1), 0, 0])
            rotate([180,0,90])
            switch(pos);
        }
    }
}


box_bolt_d = 2;
box_nut_d = 4;
box_bolt_head_d = 4;

box_bolt_hole_d = box_bolt_d + tolerance*2;
box_bolt_head_hole_d = box_bolt_head_d + tolerance*2;
box_bolt_head_thickness = 3 + tolerance;

box_nut_hole_d = box_nut_d / sin(60) + tolerance*2;
box_nut_thickness = 2.3 + tolerance;
box_thickness = [0.48*3, 0.48*3, 0.2*7];
box_inner_dim = [ dsn_vc288_mount_dim[0], pd_dim[0] ];
box_offset = box_thickness + bl_3d(tolerance);
box_dim = box_inner_dim + bl_2d(box_offset)*2;

box_bottom_inner_height = pd_dim[1];
box_bottom_height = box_thickness[2] + tolerance + box_bottom_inner_height + tolerance + box_thickness[2];

xh254_pin_counts = [5,2];

xh254_pin_position = [
    (box_inner_dim[0] - xh254_pin_holder_dim[0]*xh254_pin_counts[0])/2, 
    2, 
    xh254_pin_holder_offset[2]+xh254_pin_holder_dim[2]-tolerance-box_thickness[2]
];


module box_mount_ear_shape() {
    translate([box_nut_hole_d/2+box_thickness[0],-box_nut_hole_d/2])
    difference() {
        rotate(180)
        bl_half_circle_square(box_nut_hole_d + box_thickness[0]*2, box_nut_hole_d + box_thickness[0]);
        children();
    }
}

module box_bottom() {
        
    pd_switch_mid = pd_dim[0] - pd_switch_offsets[1][0];
    pd_switch_len = (switch_body_dim[1]+tolerance)*len(pd_switch_offsets)-tolerance;
    pd_switch_start = pd_switch_mid - pd_switch_len/2;
    pd_switch_end = pd_switch_mid + pd_switch_len/2;
        
    module box_shape() {
        square(box_dim);
        bl_quad_mirror(box_dim, 4)
        box_mount_ear_shape()
            circle(d = box_bolt_hole_d);
    }

    color("#406040")
    difference() {
        union() {
        
            linear_extrude(box_thickness[2])
            difference() {
                box_shape();
                translate(box_offset) {
                    translate(xh254_pin_position - bl_2d(tolerance))
                    square([xh254_pin_holder_dim[0]*xh254_pin_counts[0], xh254_pin_holder_dim[1]*xh254_pin_counts[1]]+bl_2d(tolerance)*2);
                }
            }
            
            linear_extrude(box_bottom_height)
            difference() {
                box_shape();
                translate(bl_2d(box_thickness))
                square(box_dim - bl_2d(box_thickness)*2);
            }
            
            switch_box_length = pd_switch_end + box_thickness[1] + tolerance*2;
            switch_box_height = box_thickness[2] + tolerance + (pd_dim[1] - switch_body_dim[0]) + 1;
            
            cube([
                switch_body_dim[2] + (box_thickness[0] + tolerance)*2,
                switch_box_length,
                switch_box_height
            ]);
            
            translate([0,switch_box_length,0])
            cube([
                box_thickness[0] + switch_body_dim[2] + switch_pin_dim[2],
                box_dim[1] - switch_box_length,
                switch_box_height
            ]);
            
        }
             
        
        bl_quad_mirror(box_dim, 4)
        translate([box_nut_hole_d/2+box_thickness[0],-box_nut_hole_d/2,-1])
        linear_extrude(box_nut_thickness+1)
        bl_ngon(box_nut_hole_d/2, 6);
        
        translate([
            0,
            box_thickness[1] + pd_switch_start,
            box_thickness[2] + pd_dim[1] - switch_body_dim[0]
        ]) {
            
            translate([box_thickness[0],0,0]) {
                cube([
                    tolerance + switch_body_dim[2] + tolerance + box_thickness[0] + tolerance,
                    switch_body_dim[1]*3 + tolerance*4,
                    box_bottom_height
                ]);
            }
            
            for (i=[0:2]) {
                translate([-tolerance,
                    (switch_body_dim[1] - switch_handle_dim[1])/2 + i*(switch_body_dim[1]+tolerance), 
                    tolerance + (switch_body_dim[0] - switch_move_width)/2 - tolerance])
                cube([
                    box_thickness[0],
                    switch_handle_dim[1],
                    switch_move_width
                ] + bl_3d(tolerance)*2);
            }
            
        }
        
        translate(box_offset) {
            translate([
                switch_body_dim[2] + switch_pin_dim[2] + pd_dim[2] + pd_typec_dim[2]/2,
                box_inner_dim[1],
                pd_typec_offset[1] + pd_typec_dim[2] / 2
            ]) {
                
                rotate([-90,0,0])
                linear_extrude(box_thickness[1] + tolerance*2)
                bl_half_circle_square(pd_typec_dim[2]+tolerance*2, box_bottom_height);
            }
        }
        
    }

}

box_bottom();

translate(box_offset) {
    
    pd_with_switches();

    translate(xh254_pin_position)
    translate([xh254_pin_holder_dim[0]*xh254_pin_counts[0],0,0])
    rotate([0,180,0])
    bl_grid(xh254_pin_counts, xh254_pin_holder_dim) {
        xh254_pin();
    }

    translate([box_inner_dim[0]-dc_connector_dim[2],box_inner_dim[1] - dc_connector_dim[1], box_bottom_inner_height-dc_connector_dim[0]])
    translate([0,dc_connector_dim[1]-dc_connector_dim[0]/2,dc_connector_dim[0]/2]) 
    rotate([0,90,0])
    dc_connector();

    translate([box_inner_dim[0]-xh254_connector_offset[2], 2, 0])
    translate([-xh254_connector_dim[2],xh254_connector_dim[1],0])
    rotate([180,-90,0])
    xh254_connector(2);  

    translate([box_inner_dim[0]/2 - dc_terminal_dia - 1, box_inner_dim[1] - dc_terminal_length, box_bottom_inner_height - dc_terminal_height])
    translate([dc_terminal_dia+0.5,0,dc_terminal_height-dc_terminal_dia/2])
    rotate([-90,0,0])
    union() {
        
        translate([dc_terminal_dia/2+1,0,0])
        dc_terminal(1);
        translate([-dc_terminal_dia/2-1,0,0])
        dc_terminal(1);
        
    }

    *translate([0, (box_inner_dim[1] - dsn_vc288_dim[1])/2,box_bottom_inner_height+4])
    dsn_vc288();

}

echo(box_nut_hole_d + box_thickness[0]*2);
