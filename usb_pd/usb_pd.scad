use <../bendlib/bendlib.scad>;

$fa = 0.1;
$fs = 0.1;

dsn_vc288_dim = [41, 21, 1];
dsn_vc288_mount_dim = [44, 5];
dsn_vc288_screen_dim = [23, 20, 8];
dsn_vc288_screen_offset = [(dsn_vc288_mount_dim[0] - dsn_vc288_screen_dim[0])/2, dsn_vc288_dim[1] - dsn_vc288_screen_dim[1], dsn_vc288_dim[2]];
dsn_vc288_holes = [
    [1, [5.5, dsn_vc288_dim[1] - 3.5]],
    [1, [5.5, dsn_vc288_dim[1] - 7.5]],
    [0.7, [3, 4.5]],
    [0.7, [5.5, 4.5]],
    [0.7, [8, 4.5]]
];

pd_dim = [26.25, 11, 1.65];
pd_typec_dim = [7.3,9,3.2];
pd_typec_offset = [-2,(pd_dim[1]-pd_typec_dim[1])/2,pd_dim[2]];
pd_switch_dim = [2.75, 3];
pd_switch_offsets = [
    [pd_dim[0] - 5, 2.75],
    [pd_dim[0] - 8, 2.75],
    [pd_dim[0] - 11, 2.75]
];
pd_offset = [
    dsn_vc288_screen_offset[0]-pd_dim[1],
    (dsn_vc288_dim[1] - pd_dim[0])/2,
    (dsn_vc288_dim[2]+dsn_vc288_screen_dim[2])-(pd_dim[2]+pd_typec_dim[2])
];

switch_dim = [8.5, 4, 4];
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
                translate(hole[1])
                    circle(d = hole[0]);
            }
        }
        translate(dsn_vc288_screen_offset)
        color("darkgray")
        cube(dsn_vc288_screen_dim);
    }
}

module pd_switch() {
    polygon(bl_arc(pd_switch_dim[0]/2, [0,180]));
    translate([0,pd_switch_dim[0]-pd_switch_dim[1]])
    polygon(bl_arc(pd_switch_dim[0]/2, [0,-180]));
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

    
}

module switch(position = 0) {
    for (i=[1:3])
        translate([i*switch_dim[0]/4, switch_dim[1]/2,0])
            translate([-switch_pin_dim[0]/2, -switch_pin_dim[1]/2,0])
                cube(switch_pin_dim);

    translate([0,0,switch_pin_dim[2]]) {
        color("darkgray")
        difference() {
            cube(switch_dim);
            translate([(switch_dim[0]-switch_move_width)/2, (switch_dim[1]-switch_handle_dim[1])/2, 1])
            cube([switch_move_width, switch_handle_dim[1], switch_dim[2]]);
        }

        translate([(switch_dim[0]-switch_move_width)/2, (switch_dim[1]-switch_handle_dim[1])/2, 0]) {
            color("gray") 
            translate([0,0,1])
            cube([switch_move_width, switch_handle_dim[1], switch_dim[2]-1]);
        
            color("black")
            translate([position * (switch_move_width-switch_handle_dim[0]),0,switch_dim[2]])
            cube(switch_handle_dim);
        }
    }
}

for (i = [0:len(pd_switch_offsets)-1]) {
    
    translate([pd_offset[0]+pd_switch_offsets[0][1]-pd_switch_dim[0]/2,pd_offset[1]-(switch_dim[1])/2 + (pd_dim[0]-pd_switch_offsets[0][0])+switch_dim[1]*i,pd_offset[2]-switch_dim[0]*3/4-switch_pin_dim[0]/2])
    rotate([0,-90,0])
    switch(0);

}


translate(pd_offset)
translate([0,pd_dim[0],0])
rotate([0,0,-90])
pd();

dsn_vc288();