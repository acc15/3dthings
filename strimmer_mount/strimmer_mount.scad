thickness = 4;

d_real = 22.2;
d_tol = 0.6;
d_eff = d_real + d_tol;
d_outside = d_eff + thickness * 2;


height = 14;

$fa = 0.1;
$fs = 0.1;

module mount_bracket() {
    screw_real_d = 5.8;
    screw_tol_d = 0.4;
    screw_eff_d = screw_real_d + screw_tol_d;
    
    round_corner = 4;
    
    mount_length = d_outside + height * 2;
    
    
    translate([-d_outside/2 - height, 0])
    linear_extrude(thickness)
    difference() {
        offset(round_corner)
        offset(-round_corner)
        square([mount_length, height]);
        
        translate([height/2, height/2])
        circle(d = screw_eff_d);
        
        translate([mount_length - height/2, height/2])
        circle(d = screw_eff_d);
    }
}

module holder_part() {
    mount_hole_d = height;
    
    linear_extrude(height)
    difference() {
        offset(thickness)
        offset(-thickness)
        translate([-d_outside/2, 0])
        square([d_outside, d_outside / 2 + mount_hole_d + thickness]);
        
        translate([0, d_outside/2 +  mount_hole_d/2])
        hull() {
        translate([-d_outside/2 + thickness + mount_hole_d/2, 0])
        circle(d = mount_hole_d);
        
        translate([d_outside/2 - thickness - mount_hole_d/2, 0])
        circle(d = mount_hole_d);
        }
        
    }
}

module upart() {
    difference() {

        union() {
            holder_part();
            translate([0,thickness,0])
            rotate([90,0,0])
            mount_bracket();
        }
        
        translate([0,0,-0.1])
        cylinder(d = d_eff, h = height + 0.1 * 2);

    }
}


module dpart() {
    
    difference() {   
        union() {
            cylinder(d = d_outside, h = height);
            
            translate([0,0,0])
            rotate([90,0,0])
            mount_bracket();
        }
        
        translate([0,0,-0.1]) { 
            cylinder(d = d_eff, h = height + 0.2);
            translate([-d_outside/2-0.1, 0, 0])
            cube([d_outside + 0.2, d_outside + 0.1, height + 0.2]);
        }
    }
    
}

dpart();


/*
// linear_extrude(height)
difference() {
    union() {
        circle(d = d_eff + thickness*2);
        translate([-d_eff/2-thickness-side_mount_length, -thickness])
        square([d_eff+thickness*2+side_mount_length*2, thickness*2]);
    }
    circle(d = d_eff);
}*/