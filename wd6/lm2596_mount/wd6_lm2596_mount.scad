use <../bendlib/bendlib.scad>;

wd6_mount_hole_d = 3.4;
wd6_mount_t = 1;
wd6_mount_hole_dim = [32,60];
wd6_mount_hole_offsets = [ [0,0], [wd6_mount_hole_dim[0],0], [wd6_mount_hole_dim[0], wd6_mount_hole_dim[1]], [0,wd6_mount_hole_dim[1]]];
wd6_mount_height = 7;
wd6_mount_edge_height = 4;
wd6_mount_pad_d = 2.8;

m3_bolt_head_d = 5.6;
m3_bolt_head_h = 3;
m3_bolt_d = 3.2;


lm2596_dim = [21, 43.5, 1];
lm2596_hole_d = 3.2;
lm2596_hole_offsets = [
    [1+lm2596_hole_d/2,5+lm2596_hole_d/2], 
    [lm2596_dim[0]-1-lm2596_hole_d/2,lm2596_dim[1]-5-lm2596_hole_d/2]
];

lm2596_offset = [
    (wd6_mount_hole_dim[0]-lm2596_dim[0])/2,
    (wd6_mount_hole_dim[1]-lm2596_dim[1])/2,
    wd6_mount_height
];


$fa = 0.2;
$fs = 0.2;

module lm2596() {
    linear_extrude(lm2596_dim[2])
    difference() {
        square(bl_2d(lm2596_dim));
        for (hole = lm2596_hole_offsets) {
            translate(hole)
            circle(d = lm2596_hole_d);
        }
    }
}

module lm2596_holes() {
    translate(lm2596_offset)
    for (off = lm2596_hole_offsets) {
        translate(off) 
            children();
    }
}

module wd6_mount_holes() {    
    for (off = wd6_mount_hole_offsets) {
        translate(off)
        children();
    }
}


module wd6_hull_shape() {
    translate([0,0,wd6_mount_height-wd6_mount_edge_height]) {
    
    translate([0,0,wd6_mount_edge_height-wd6_mount_t])
    cylinder(d = wd6_mount_hole_d, h = wd6_mount_t);
    cylinder(d = wd6_mount_t, h = wd6_mount_edge_height);
    }
}

module wd6_mount() {

    difference() {
    
        union() {
        
            
            for (i = [0:len(wd6_mount_hole_offsets)-1]) {
                hull() {
                    translate(wd6_mount_hole_offsets[i])
                    wd6_hull_shape();
                    
                    translate(wd6_mount_hole_offsets[i == len(wd6_mount_hole_offsets)-1 ? 0 : i + 1])
                    wd6_hull_shape();
                }
            }

            p1 = lm2596_offset + lm2596_hole_offsets[0];
            p2 = lm2596_offset + lm2596_hole_offsets[1];
            
            hull() {
                translate(p1)
                wd6_hull_shape();
                translate([0,p1[1]])
                wd6_hull_shape();
            }
            hull() {
                translate(p1)
                wd6_hull_shape();
                translate([p1[0],0])
                wd6_hull_shape();
            }
            hull() {
                translate([p1.x, p2.y])
                wd6_hull_shape();
                translate([p1.x,wd6_mount_hole_dim[1]])
                wd6_hull_shape();
            }
            hull() {
                translate([p1.x, p2.y])
                wd6_hull_shape();
                translate([0,p2.y])
                wd6_hull_shape();
            }
            
            hull() {
                translate(p2)
                wd6_hull_shape();
                translate([wd6_mount_hole_dim[0],p2[1]])
                wd6_hull_shape();
            }
            hull() {
                translate(p2)
                wd6_hull_shape();
                translate([p2[0],wd6_mount_hole_dim[1]])
                wd6_hull_shape();
            }
            hull() {
                translate([p2.x, p1.y])
                wd6_hull_shape();
                translate([p2.x,0])
                wd6_hull_shape();
            }
            hull() {
                translate([p2.x, p1.y])
                wd6_hull_shape();
                translate([wd6_mount_hole_dim[0],p1.y])
                wd6_hull_shape();
            }

            
            wd6_mount_holes() {
                cylinder(d = m3_bolt_head_d+wd6_mount_t*2, h = wd6_mount_height);
            }
            
            
            lm2596_holes() {
                translate([0,0,-wd6_mount_edge_height])
                cylinder(d = wd6_mount_pad_d + wd6_mount_t*2, h = wd6_mount_edge_height);
            }
            
        }
    
        wd6_mount_holes() {
            m3_bolt(wd6_mount_height);
        }
        
        lm2596_holes() {
            translate([0,0,-wd6_mount_edge_height+wd6_mount_t])
            cylinder(d = wd6_mount_pad_d, h = wd6_mount_edge_height);
        }
        
    }
    
    
}

module m3_bolt(h) {

    translate([0,0,h-3])
    cylinder(d = m3_bolt_head_d, h = m3_bolt_head_h+1);
    translate([0,0,-1])
    cylinder(d = m3_bolt_d, h = h+1);
}
    




*translate(lm2596_offset)
*color("green")
lm2596();
*wd6_mount();

translate([0,wd6_mount_hole_dim[1],wd6_mount_height])
rotate([180,0,0])
wd6_mount();