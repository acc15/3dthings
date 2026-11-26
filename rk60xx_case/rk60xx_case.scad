use <bendlib/bendlib.scad>;
include <BOSL2/std.scad>;

$fa = 3;// : 0.5;
$fs = 0.2;

//tolerance = 0.2;

rk_dim = [ 71 + 0.4, 44, 39 + 0.4 ];
rk_ear_dim = [ 76, 12, 12 ];
rk_ear_mount_length = 2;
rk_case_depth = 23;
rk_border_dim = [ 4, 2, 2 ];
rk_socket_offset = [ 27, 30, -3 ];
rk_socket_dim = [ 21, 9, 15 ];

box_thickness = 2;

banana_inner_d = 12;
banana_outer_d = 15;
banana_l = 30;
banana_outer_l = 3;
banana_mount_thickness = 5;
banana_offset = box_thickness*2 + banana_outer_d/2;

rail_width = 20;
rail_height = 5;
wire_height = 20;

box_rounding = 2;
box_dim = [ 
    rk_dim[0]+rk_border_dim[0]*2,
    rk_dim[1]+8,
    banana_offset*2 + rk_border_dim[2]*2 + rk_dim[2]
];

box_wire_hole_offset = [box_dim[0]/2, banana_offset*2 - rk_socket_offset[2]];
box_wire_hole_dim = [10, 5];

bolt_head_d = 4;
bolt_hole_d = 2;
bolt_thread_d = 1;

tolerance = 0.1;

function hole_offset(r) = r - (r - box_thickness - (box_thickness+tolerance) - bolt_head_d/2)*sqrt(2)/2; // additional box

module banana_plug() {
    rotate([-90,0,0]) {
        translate([0,0,-banana_outer_l]) {    
            cylinder(d = banana_inner_d, h = banana_l);
            cylinder(d = banana_outer_d, h = banana_outer_l);
        }
        translate([0,0,23])
        rotate([0,90,-20])
        cylinder(d = 7, h = 15);
    }
}

module rk60xx() {
 
    cube([rk_dim[0] + rk_border_dim[0]*2, rk_border_dim[1], rk_dim[2] + rk_border_dim[2]*2]);
    
    translate([rk_border_dim[0], 0, rk_border_dim[2]])
    cube(rk_dim);
    
    translate(rk_socket_offset)
    cube(rk_socket_dim);
    
    translate([(rk_dim[0] + rk_border_dim[0]*2 - rk_ear_dim[0])/2, rk_border_dim[1], (rk_dim[2] + rk_border_dim[2]*2 - rk_ear_dim[2])/2])
    cube(rk_ear_dim);
    
}


module front_plane(inner = false) {
    
    raw_path = [
        [0,0],
        [box_dim[0]/2 - rail_width/2 - (inner?rail_height*2:0), 0],
        [box_dim[0]/2 - rail_width/2 - rail_height, rail_height],
        [box_dim[0]/2 + rail_width/2 + rail_height, rail_height],
        [box_dim[0]/2 + rail_width/2 + (inner?rail_height*2:0), 0],
        [box_dim[0], 0],
        [box_dim[0], box_dim[2]],
        [0, box_dim[2]]
    ];       
    
    path = round_corners(raw_path, radius=[banana_offset, 1, 1, 1, 1, banana_offset, box_rounding, box_rounding], closed=true);
    
    polygon(path);
    
}

module front_plane_diff(tolerance = 0) {
    offset(-box_thickness-tolerance)
    front_plane(true);
}

module panel_diff(ear_width) {
    translate([rk_dim[0]/2+rk_border_dim[0],rk_dim[2]/2+banana_offset*2 + rk_border_dim[1]])
    union() {
        square([rk_dim[0], rk_dim[2]], center=true);
        square([ear_width, rk_ear_dim[2]], center=true);
    }
}


module face() {
    difference() {
        front_plane();
        panel_diff(rk_ear_dim[0]);
        translate([banana_offset, banana_offset])
        circle(d = banana_inner_d);
        translate([box_dim[0]-banana_offset, banana_offset])
        circle(d = banana_inner_d);
    }
}

module face_inner(ear_width) {
    difference() {
        union() {
            difference() {
                front_plane();
                front_plane_diff();
            }
            translate([0, banana_offset*2])
            bl_square([box_dim[0], rk_border_dim[2]*2+rk_dim[2]], [box_rounding,box_rounding,0,0]);
        }
        panel_diff(ear_width);
    }
}

module banana_mount() {
    
    module shape() {
        difference() {
            circle(d = banana_outer_d);
            circle(d = banana_inner_d);
        }
    }
    
    linear_extrude(banana_mount_thickness) {
        translate([banana_offset, banana_offset])
        shape();
        translate([box_dim[0]-banana_offset, banana_offset])
        shape();
    }

}

module vent_pattern(dim) {
    
    xd = dim[0]-box_thickness*2;
    xw = box_thickness;
    xc = floor(xd / (xw*2.5));
    xs = (xd - xw*xc)/(xc-1);
        
    yd = dim[1]-box_thickness*2;
    yc = ceil(yd / 20);
    ys = box_thickness*2;
    yw = (yd - ys * (yc-1)) / yc;
    
    $fs = 0.3;
    
    for (y = [0:yc-1]) {
        for (x = [0:xc-1]) {
            translate([box_thickness+xw/2+x*(xw+xs), box_thickness+xw/2 + y*(yw+ys)])
            hull() {
                circle(d = xw);
                translate([0,yw-xw])
                circle(d = xw);   
            }
        }
    }
}

module air_front_plane(h) {
    ear_spacing = hole_offset(box_rounding) + bolt_head_d/2;
    
    difference() {
        
        linear_extrude(h)
        difference() {
            front_plane();
            front_plane_diff();
        }
        
        translate([-tolerance,banana_offset,0])
        rotate([90,0,90])
        linear_extrude(box_dim[0] + tolerance*2)
        vent_pattern([box_dim[2] - banana_offset - ear_spacing, h]);
        
        translate([ear_spacing,box_dim[2]+tolerance,0])
        rotate([90,0,0])
        linear_extrude(box_thickness+tolerance*2)
        vent_pattern([box_dim[0] - ear_spacing*2, h]);
        
    }
}

module wire_hole() {
    off = (box_wire_hole_dim[0]-box_wire_hole_dim[1])/2;
    translate(box_wire_hole_offset) {
        hull() {
            translate([-off,0])
            circle(d = box_wire_hole_dim[1]);
            translate([off,0])
            circle(d = box_wire_hole_dim[1]);
        }
    }
}

module back_lid() {
        
    linear_extrude(box_thickness)
    difference() {
        front_plane_diff(tolerance);
        
        intersection() {
            offset(-box_thickness)
            difference() {
                front_plane_diff(tolerance);
                wire_hole();
            }
            translate([box_thickness+tolerance,banana_offset])
            vent_pattern([ box_dim[0]-box_thickness*2-tolerance*2, box_dim[2]-banana_offset - hole_offset(box_rounding) - bolt_head_d/2 ]);
        }
        
        for (o = [
            [hole_offset(banana_offset),hole_offset(banana_offset)],
            [box_dim[0] - hole_offset(banana_offset),hole_offset(banana_offset)],
            [hole_offset(box_rounding),box_dim[2] - hole_offset(box_rounding)],
            [box_dim[0]-hole_offset(box_rounding),box_dim[2] - hole_offset(box_rounding)]
        ]) {
            translate(o)
            circle(d = bolt_hole_d);
        }
        
        wire_hole();
    }
    
}

module box_mount_ear(h, r) {
    hole_offset = hole_offset(r);
    
    module shape() {
        bl_square([(hole_offset+bolt_head_d/2), (hole_offset+bolt_head_d/2)], [bolt_head_d/2,0,0,0]);
    }
    
    difference() {
        intersection() {

            union() {
                linear_extrude(box_thickness)
                shape();

                translate([0,0,box_thickness])
                linear_extrude(h - box_thickness, scale = 0.1)
                shape();
            }

            linear_extrude(h)
            bl_square([max(r, hole_offset+bolt_head_d),max(r, hole_offset+bolt_head_d)], [0,0,r,0]);
            
        }
        translate([hole_offset,hole_offset,-1])
        cylinder(d = bolt_thread_d, h = h+2, $fn = 16);
    }
}


module box(demo=false) {
    translate(demo ? [0,box_dim[1],0] : [0,box_dim[2],box_dim[1]])
    rotate(demo ? [90,0,0] : [180,0,0])
    union() {

        translate([0,0,box_dim[1] - rk_case_depth])
        bl_extrude_tower([rk_case_depth-rk_ear_dim[1],rk_ear_dim[1]-rk_ear_mount_length,rk_ear_mount_length - box_thickness,box_thickness]) {
            face_inner(0);
            face_inner(rk_ear_dim[0]+rk_border_dim[0]);
            face_inner(rk_ear_dim[0]);
            face();
        }
        
        vent_height = box_dim[1] - rk_case_depth - box_thickness;
        
        translate([0,0,box_thickness])
        air_front_plane(box_dim[1] - rk_case_depth - box_thickness);
        
        linear_extrude(box_thickness)
        difference() {
            front_plane();
            front_plane_diff();
        }
        
        translate([0,0,box_dim[1]-banana_mount_thickness])
        banana_mount();
        
        translate([0,0,box_thickness]) {
            box_mount_ear(vent_height,banana_offset);
            
            translate([box_dim[0],0,0])
            mirror([1,0,0])
            box_mount_ear(vent_height,banana_offset);
            
            translate([0,box_dim[2],0])
            mirror([0,1,0])
            box_mount_ear(vent_height/2,box_rounding);
            
            translate([box_dim[0],box_dim[2],0])
            mirror([1,1,0])
            box_mount_ear(vent_height/2,box_rounding);
        }
    }
}

module demo() {
    box(true);
    
    *translate([0,box_dim[1],0])
    rotate([90,0,0])
    back_lid();
    
    color("blue")
    translate([0,-rk_border_dim[1],banana_offset*2])
    rk60xx();

    translate([banana_offset,0,banana_offset])
    color("red")
    banana_plug();

    translate([box_dim[0]-banana_offset,0, banana_offset])
    color("black")
    mirror([1,0,0])
    banana_plug();
}

*wire_hole();

*front_plane();

demo();

*box();
*back_lid();

*translate([0,0,banana_offset*2])
rk60xx();

*#translate(box_socket_offset)
cube([rk_socket_dim[0],10,10]);

*vent_pattern([30, 40]);


*air_front_plane(box_dim[1] - rk_case_depth - box_thickness);

/*
//hull() {
//linear_extrude(1)
p1 = concat(
    bl_arc(banana_offset, angle = [180,270], position = [banana_offset,banana_offset], $fn = 32),
    bl_arc(banana_offset - box_thickness, angle = [270,180], position = [banana_offset,banana_offset], $fn = 32)
);

polygon(p1);

#translate(bl_2d(bolt_hole_offset))
circle(d = bolt_head_d , $fn = 32);

p2 = concat(
    bl_arc(banana_offset, angle = [180,270], position = [banana_offset,banana_offset], $fn = 32),
    bl_arc(banana_offset - box_thickness, angle = [270,270-banana_arc_angle], position = [banana_offset,banana_offset], $fn = 8),
    bl_arc(bolt_head_d/2, angle = [0, 90], position = [bolt_hole_offset, bolt_hole_offset], $fn = 16),
    bl_arc(banana_offset - box_thickness, angle = [180+banana_arc_angle, 180], position = [banana_offset,banana_offset], $fn = 8)

);

polygon(p2);

*skin([p1, p2], slices = 10, z = [0,10]);
*/

