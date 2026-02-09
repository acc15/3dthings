//cylinder(d = 2.7, h = );

$fa = 0.2;
$fs = 0.2;

z_thickness = 1.5;
base_dim = [26.5, 15.5];
hole_dim = [12.5, 3.75];

hole_offset = [(base_dim[0] - hole_dim[0]) / 2, 3.5];

grip_dim = [19.5, 1.5];


mount_d = 2.75;
mount_dim = [base_dim[0], 23 - mount_d/2, 4.75];
mount_wall_thickness = 2.25;//_offset = [2.25, hole_offset[1]];
mount_cut_r = 2.5;
mount_holder_d = 6.85;
mount_holder_h = 2.85;

mount_clip_height = 4.5 - grip_dim[1]/2;
mount_clip_width = 0.75;

module grip_sphere() {
    intersection() {
        sphere(d = grip_dim[1]);
        
        translate([-grip_dim[1]/2, -grip_dim[1]/2,-grip_dim[1]/2])
        cube([grip_dim[1], grip_dim[1], grip_dim[1]/2]);
    }
}

module grip() {
    hull() {
        grip_sphere();
        translate([grip_dim[0], 0])
        grip_sphere();
    }
}

difference() {

union() {

    linear_extrude(z_thickness)
    difference() {
        square(base_dim);
        translate(hole_offset)
        square(hole_dim);
    }

    *translate([(base_dim[0] - grip_dim[0]) / 2,hole_offset[1],0]) {
        translate([0,-grip_dim[1]/2,0])
        grip();

        translate([0,hole_dim[1]+grip_dim[1]/2,0])
        grip();
    }


    difference() {
        
        linear_extrude(mount_dim[2])
        difference() {
            square([mount_dim[0], mount_dim[1]]);
            translate([mount_wall_thickness, hole_offset[1]])
            square([mount_dim[0] - mount_wall_thickness*2, mount_dim[1]]);
        }
        
        translate([0,0,mount_dim[2]])
        rotate([0,90,0])
        translate([0,0,-1])
        cylinder(r = mount_cut_r, h = mount_dim[0] + 2);
    }

    translate([0,mount_dim[1],mount_holder_d/2])
    rotate([0,90,0])
    cylinder(d = mount_holder_d, h = mount_holder_h);
    
    translate([mount_dim[0] - mount_holder_h,mount_dim[1],mount_holder_d/2])
    rotate([0,90,0])
    cylinder(d = mount_holder_d, h = mount_holder_h);
    
    translate([0,mount_dim[1],mount_holder_d/2])
    rotate([0,90,0])
    cylinder(d = mount_d, h = mount_dim[0]);
    
    translate([hole_offset[0], hole_offset[1],mount_clip_height-mount_clip_width])
    rotate([90,0,90])
    linear_extrude(hole_dim[0])
    polygon([[0,0],[mount_clip_width, mount_clip_width],[mount_clip_width,mount_dim[2] - mount_clip_height+mount_clip_width], [0,mount_dim[2] - mount_clip_height+mount_clip_width]]);


}

    translate([hole_offset[0], hole_offset[1]+mount_clip_height/2-mount_clip_width, mount_clip_height/2])
    rotate([0,90,0])
    cylinder(d = mount_clip_height, h = hole_dim[0]);

}




