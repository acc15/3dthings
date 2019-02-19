include <bendlib.scad>
include <MCAD/involute_gears.scad>

gear_hole = 2.4;
gear_height = 12.3;
gear_total_height = 13.5;
gear_distance = 12;

wing_mount_dim = [20, 4, gear_height];
wing_mount_t = 2.8;

wing_mount_hole = 4.4;

gear_r_angle = 7.6;

module wing_mount() {
    difference() {
        cube(wing_mount_dim);
        
        translate([wing_mount_dim[0] - 6,wing_mount_dim[1] + 0.5,wing_mount_dim[2]/2])
        rotate([90,0,0])
        cylinder(d = wing_mount_hole, h = wing_mount_dim[1] + 1);
    }
}

module gear_l(a = 0, b = 0.52) {
    $fn = 64;
    
    gd = gear_distance + 2.4;
    
    union() {

        
        difference() {
        
            union() {
                rotate([0,0,a])
                    gear(24, 
                        circular_pitch = 91,
                        pressure_angle = 0,
                        bore_diameter = 2.4,
                        gear_thickness = gear_height,
                        rim_thickness = gear_height);

                difference() {
                    union() {
                        difference() {
                            cylinder(d = gd, h = gear_height, $fn = 256);
                            translate([0,0,-0.5]) {
                                translate([-0.01,-gd + 0.01,0])
                                    cube([gd, gd, gear_height + 1]);
                            }
                        }
                        translate([0,0,gear_height - 1])
                        cylinder(d = 5, h = (gear_total_height - gear_height) + 1);
                    }
                    
                    translate([0,0,-0.5])
                    cylinder(d = gear_hole, h = gear_total_height + 1);
                }
            }
                
            translate([-gd/2 + b,-(gd - 1.25),(gear_height)/2 ])
                cube([gd, gd, gear_height + 1], center=true);
                    
            translate([gd - 1.25,gd/2 - b,(gear_height)/2])
                cube([gd, gd, gear_height + 1], center=true);
        }
            
        rotate([0,0,90 + 20 ])
            translate([gear_distance / 2,-wing_mount_dim[1]/2,0])
                wing_mount();
    }
}

module gear_r() {
    mirror([1,0,0])
        gear_l(gear_r_angle, 0);
}

module wing_r() {
    translate([0,0,0])
    rotate([0,90,0])
        import("wing_ed2_cut.stl");
}

module wing_l() {
    mirror([1,0,0])
        wing_r();
}

module full_wing_l(a = 0, b = 1) {
    rotate([90,0,0])
    translate([0,0,-gear_height/2])
    gear_l(a, b);
    
    mirror([1,0,0])
    rotate([0,20,0])
    translate([0,0,14])
    rotate([0,0,180])
    import("wing_ed2_cut.stl");
}

module full_wing_r() {
    
    mirror([1,0,0])
    full_wing_l(gear_r_angle, 0);
    
}

anim = 0;//$t * 90;
mode = "gears_print";

if (mode == "gear_l") {
    gear_l();
} else if (mode == "gear_r") {
    gear_r();
} else if (mode == "gears") {
    
    a = anim;
    
    rotate([90,0,0])
    translate([0,0,-gear_height/2]) {
        translate([-gear_distance/2,0,0])
            rotate([0,0,a])
            gear_l();
    
        translate([gear_distance/2,0,0])
            rotate([0,0,-a])
            gear_r();
    }
} else if (mode == "gears_print") {
    translate([0,0,-gear_height/2]) {
        translate([-gear_distance/2 - 1,0,0])
            gear_l();
    
        translate([gear_distance/2 + 1,0,0])
            gear_r();
    }
} else if (mode == "wing_r") {
    wing_r();    
} else if (mode == "wing_l") {
    wing_l();
} else if (mode == "full_wing_r") {
    full_wing_r();
} else if (mode == "full_wing_l") {
    full_wing_l();
} else if (mode == "all") {
    
    a = anim;
        
    translate([gear_distance/2,0,0])
    rotate([0,a,0])
    full_wing_r();
    
    translate([-gear_distance/2,0,0])
    rotate([0,-a,0])
    full_wing_l();
}
/*
                    gear(32, 
                        circular_pitch = 90,
                        bore_diameter = 2.4,
                        pressure_angle = 0,
                        gear_thickness = gear_height,
                        rim_thickness = gear_height);*/