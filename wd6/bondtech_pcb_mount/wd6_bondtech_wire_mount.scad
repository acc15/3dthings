use <bendlib/bendlib.scad>;

$fa = 0.5;
$fs = 0.5;

m3_nut_d = 5.4 * 2/sqrt(3);
m3_nut_h = 2.4;
m3_bolt_d = 3.4;
m3_head_d = 5.5;
m3_head_h = 3;

plate_dim = [42, 3, 11];
plate_hole_offset = [8.5, plate_dim[2] - 7];

motor_offset = [0,0,-plate_dim[0]];
motor_dim = [42,42,34];


mount_thickness = 3;
lock_length = m3_nut_d + mount_thickness*2;
wire_dia = 10;
wire_length = 20;

mount_dim = [plate_dim[0], lock_length+wire_length, mount_thickness*2 + wire_dia];
mount_rounding = 4;

mount_tolerance = 0.2;
lock_cut = 3;

module plate() {
    rotate([90,0,0])
    linear_extrude(plate_dim[1])
    difference() {
        square([plate_dim[0], plate_dim[2]]);
        translate([plate_hole_offset[0], plate_hole_offset[1]])
        circle(d = 3);
        translate([plate_dim[0]-plate_hole_offset[0], plate_hole_offset[1]])
        circle(d = 3);
    }
}

module motor() {
    color("gray")
    translate([0,motor_dim[2],0])
    rotate([90,0,0])    
    cube(motor_dim);
        
    color("white")
    translate([(plate_dim[0]-16)/2,34-10,plate_dim[0]])
    cube([16,10,6]);
}

module m3_bolt_diff(head_h, d_h, nut_h) {
    tolerance = 0.2;
    if (head_h > 0) {
        translate([0,0,-tolerance])
        cylinder(d = m3_head_d, h = head_h+tolerance);
    }
    
    translate([0,0,-tolerance])
    cylinder(d = m3_bolt_d, h = d_h+head_h+nut_h + tolerance*2);
    
    if (nut_h > 0) {
        translate([0,0,head_h+d_h])
        cylinder(d = m3_nut_d, h = nut_h+tolerance, $fn = 6);
    }
}

*plate();

module mount_cut_shape() {
    round_dim = [wire_length - plate_dim[2], (mount_dim[2] - lock_cut) / 2 - mount_thickness];
    bl_square([mount_dim[1]+1, mount_dim[2]+1], [0,0,round_dim,0]);
}

module mount_shape() {
    module bolt_diff() {
        translate([0,0,-1]) {
            cylinder(d = m3_nut_d, h = m3_nut_h+1, $fn = 6);
            cylinder(d = m3_bolt_d, h = mount_dim[2]+2);
        }
        
        translate([0,0,mount_dim[2]/2+lock_cut/2+mount_thickness])
        cylinder(d = m3_head_d, h = mount_dim[2]);
    }
    

    module round_diff() {
        difference() {
            rotate_extrude(angle = 90)
            translate([mount_rounding,0])
            mount_cut_shape();
            
            translate([mount_rounding-mount_thickness,0])
            cube([mount_thickness,mount_dim[1] - mount_rounding, mount_dim[2]/2 - mount_thickness - lock_cut/2]);
        }
    }
    
    difference() {
    
        intersection() {
            linear_extrude(mount_dim[2])
            bl_square(mount_dim, [0,mount_rounding]);
        
            translate([0,mount_dim[1]+1])
            rotate([90,0,0])
            linear_extrude(mount_dim[1]+2)
            hull() {
                bl_square([mount_dim[0], mount_dim[2]/2+lock_cut/2+mount_rounding], [mount_rounding,0]);
                translate([mount_dim[0]/2-mount_thickness-wire_dia/2,0])
                bl_square([mount_thickness*2 + wire_dia, mount_dim[2]], [mount_rounding,0]);
            }
        }


        union() {
            
            $fa = 2;
            $fs = 2;
            
            translate([mount_rounding, lock_length,mount_thickness])
            rotate([90,0,90])
            linear_extrude(mount_dim[0] - mount_rounding*2)
            mount_cut_shape();
            
            translate([mount_dim[0]-mount_rounding,lock_length-mount_rounding,mount_thickness])
            round_diff();
        
            translate([mount_rounding,lock_length-mount_rounding,mount_thickness])
            mirror([1,0,0])
            round_diff();
                        
        }
        
        translate([mount_dim[0]/2, mount_dim[1]+1, mount_dim[2]/2])
        rotate([90,0,0])
        cylinder(d = wire_dia, h = mount_dim[1] + 2);
        
        
        translate([0,mount_dim[1]-plate_hole_offset[1],-1]) {
            translate([plate_hole_offset[0],0,0])
            cylinder(d = m3_bolt_d, h = mount_dim[2] + 2);
            
            translate([mount_dim[0]-plate_hole_offset[0],0,0])
            cylinder(d = m3_bolt_d, h = mount_dim[2] + 2);
        }
        
        translate([lock_length/2, lock_length/2,0]) {
            bolt_diff();
        }
        
        translate([mount_dim[0]-lock_length/2, lock_length/2,0]) {
            bolt_diff();
        }
    }

}

module mount() {
    intersection() {
        mount_shape();
        translate([-1,-1,-1])
        cube([mount_dim[0]+2,mount_dim[1]+2,mount_dim[2]/2-lock_cut/2+1]);
    }
}

module lock() {
    translate([0,0,-mount_dim[2]/2-lock_cut/2])
    intersection() {
        mount_shape();
        translate([0,0,mount_dim[2]/2+lock_cut/2])
        cube(mount_dim);
    }
}


mode = "lock";
if (mode == "mount") {
    mount();
} else if (mode == "lock") {
    translate([0,0,lock_length])
    rotate([-90,0,0])
    lock();
} else if (mode == "shape") {
    mount_shape();
} else if (mode == "demo") {
    plate();
    translate(motor_offset)
    motor();
    
    translate([0,0,mount_dim[1]])
    rotate([-90,0,0])
    mount();
    
    translate([0,mount_dim[2]/2+lock_cut/2,mount_dim[1]])
    rotate([-90,0,0])
    lock();
    
    #translate([0, mount_dim[2]/2-lock_cut/2,0])
    cube([mount_dim[0], lock_cut, mount_dim[1]]);
}

*cube([mount_dim[0], mount_thickness, 10]);

//echo(bl_2d([3]));
//echo(bl_radius_cast([3]));




/*

module corner(r1, r2, t1, t2) {
    l = sqrt(2)*r;
    r_cut = l-r;
    difference() {
        square([l, t2]);
        translate([l, t2])
        scale([1, (t2-t1)/r_cut])
        circle(r = r_cut);
    }
    
}

rotate_extrude(angle=90)
corner(10, 1, 8);
*/













