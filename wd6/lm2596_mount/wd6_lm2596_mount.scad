use <bendlib/bendlib.scad>;

m3_bolt_head_d = 5.6;
m3_bolt_head_h = 3;
m3_bolt_d = 3.2;

mount_hole_d = 3.4;
mount_t = 1;
mount_hole_dim = [32,60];
mount_hole_offsets = [ 
    [0,0], 
    [mount_hole_dim[0],0], 
    [mount_hole_dim[0], mount_hole_dim[1]], 
    [0,mount_hole_dim[1]]
];
mount_height = 7;
mount_edge_height = 4;
mount_pad_d = 2.8;
mount_dim = [ 
    mount_hole_dim[0] + m3_bolt_head_d/2 + mount_t, 
    mount_hole_dim[1] + m3_bolt_head_d/2 + mount_t, 
    mount_height 
];



lm2596_dim = [21, 43.5, 1];
lm2596_hole_d = 3.2;

lm2596_hole_offsets_spec = [ [1,5], [-1,-5] ];

lm2596_holes = [ 
    [ lm2596_hole_d, [1 + lm2596_hole_d/2, 5 + lm2596_hole_d/2] ], 
    [ lm2596_hole_d, [lm2596_dim[0] - 1 - lm2596_hole_d/2, lm2596_dim[1] - 5 - lm2596_hole_d/2] ],
    [ 1.5, [ 1.75, 1.75 ] ],
    [ 1.5, [ lm2596_dim[0] - 1.75, 1.75 ] ],
    [ 1.5, [ 1.75, lm2596_dim[1] - 1.75 ] ],
    [ 1.5, [ lm2596_dim[0] - 1.75, lm2596_dim[1] - 1.75 ] ]
];

lm2596_offset = [
    (mount_hole_dim[0]-lm2596_dim[0])/2,
    -lm2596_holes[0][1][1],
    mount_height
];

l7805_dim = [ 
    mount_hole_dim[0] + m3_bolt_head_d + mount_t*2, 
    mount_hole_dim[1] - lm2596_dim[1] - lm2596_offset[1] + lm2596_holes[0][1][1],
    1.5
];
l7805_offset = [ 
    mount_hole_dim[0] / 2 - l7805_dim[0] / 2, 
    lm2596_dim[1] + lm2596_offset[1] + mount_t, 
    mount_height 
];
l7805_holes = [
    [ mount_hole_d, [m3_bolt_head_d/2+mount_t, l7805_dim[1] - mount_t - lm2596_holes[0][1][1]] ], 
    [ mount_hole_d, [l7805_dim[0] - (m3_bolt_head_d/2+mount_t), l7805_dim[1] - mount_t - lm2596_holes[0][1][1]] ],
    [ lm2596_holes[4][0], [ lm2596_offset[0] + lm2596_holes[4][1][0] + m3_bolt_head_d/2 + mount_t, lm2596_holes[2][1][1] ] ],
    [ lm2596_holes[5][0], [ lm2596_offset[0] + lm2596_holes[5][1][0] + m3_bolt_head_d/2 + mount_t, lm2596_holes[3][1][1] ] ],
    [ lm2596_holes[4][0], [ lm2596_offset[0] + lm2596_holes[4][1][0] + m3_bolt_head_d/2 + mount_t, l7805_dim[1] - lm2596_holes[2][1][1] ] ],
    [ lm2596_holes[5][0], [ lm2596_offset[0] + lm2596_holes[5][1][0] + m3_bolt_head_d/2 + mount_t, l7805_dim[1] - lm2596_holes[3][1][1] ] ]
];

$fa = 0.2;
$fs = 0.2;

module board(dim, holes, shape=false) {
    module board_shape() {
        difference() {
            square(bl_2d(dim));
            for (hole = holes) {
                translate(hole[1])
                circle(d = hole[0]);
            }
        }
    }
    
    if (shape) {
        board_shape();
    } else {           
        linear_extrude(dim[2])
        board_shape();
    }
}

module lm2596(shape=false) {
    board(lm2596_dim, lm2596_holes, shape);
}

module l7805(shape=false) {
    board(l7805_dim, l7805_holes, shape);
}

module lm2596_holes() {
    translate(lm2596_offset)
    for (off = lm2596_holes) {
        if (off[0] == lm2596_hole_d) 
            translate(off[1]) 
                children();
    }
}

module mount_holes() {    
    for (i = [0:len(mount_hole_offsets)-1]) {
        $with_head = i < 2;
        translate(mount_hole_offsets[i])
        children();
    }
}


module hull_shape() {
    translate([0,0,mount_height-mount_edge_height]) {
        translate([0,0,mount_edge_height-mount_t])
        cylinder(d = mount_hole_d, h = mount_t);
        cylinder(d = mount_t, h = mount_edge_height);
    }
}

module hull_line(p1, p2) {
    hull() {
        translate(p1)
        hull_shape();
        translate(p2)
        hull_shape();
    }
}

module mount() {

    difference() {
    
        union() {
            
            for (i = [0:len(mount_hole_offsets)-1]) {
                hull() {
                    translate(mount_hole_offsets[i])
                    hull_shape();
                    
                    translate(mount_hole_offsets[i == len(mount_hole_offsets)-1 ? 0 : i + 1])
                    hull_shape();
                }
            }

            p1 = lm2596_offset + lm2596_holes[0][1];
            p2 = lm2596_offset + lm2596_holes[1][1];
            
            hull_line([0,p2[1]], [mount_hole_dim[0],p2[1]]);
            hull_line([p1[0],p2[1]], [p1[0],0]);
            hull_line([p2[0],p2[1]], [p2[0],0]);

            
            lm2596_holes() {
                translate([0,0,-mount_edge_height])
                cylinder(d = mount_pad_d + mount_t*2, h = mount_edge_height);
            }
                        
            mount_holes() {
                cylinder(d = m3_bolt_head_d+mount_t*2, h = mount_height);
            }

        }

        mount_holes() {
            m3_bolt(mount_height, $with_head);
        }
        
        lm2596_holes() {
            translate([0,0,-mount_edge_height+mount_t])
            cylinder(d = mount_pad_d, h = mount_edge_height);
        }
        
    }
    
    
}

module m3_bolt(h, with_head = true) {
    if (with_head) {
        translate([0,0,h-m3_bolt_head_h])
        cylinder(d = m3_bolt_head_d, h = m3_bolt_head_h+1);
    }
    translate([0,0,-1])
    cylinder(d = m3_bolt_d, h = h+2);
}


module mount_preview() {
    translate(l7805_offset)
    l7805();
    translate(lm2596_offset)
    color("green")
    lm2596();
    mount();
}

module mount_printable() {
    translate([m3_bolt_head_d/2 + mount_t, mount_hole_dim[1] + m3_bolt_head_d/2 + mount_t,mount_height])
    rotate([180,0,0])
    mount();
}

//mount_preview();
mount_printable();


module print_l7805_layout(off) {
    
    echo(dim = [l7805_dim[1], l7805_dim[0]]);
    for (hole = l7805_holes) {
        echo(d = hole[0], x = off[0] + hole[1][1], y = off[1] + hole[1][0]);
    }
    
}

print_l7805_layout([20,20]);

//l7805(shape=true);