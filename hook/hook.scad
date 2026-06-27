use <../bendlib/bendlib.scad>;

$fa = 0.5;
$fs = 0.5;

profile_d = 9;
hook_d = 40;

/*
joint_angle = 30;
outer_d = cos(joint_angle)*hook_d/ (1-cos(joint_angle));
foot = sin(joint_angle)*(hook_d + outer_d) / 2;
*/
foot = 40;
outer_d = 2*foot*foot/hook_d - hook_d/2;
joint_angle = asin(foot*2/(hook_d+outer_d));


foot_profile_d = 14;
foot_length = 10;

bolt_d = 2.8;
bolt_head_d = 5;

module hook() {

    union() {

        translate([-hook_d/2,0,0])
        sphere(d = profile_d);

        rotate([0,0, -joint_angle])
        rotate_extrude(angle = 180 + joint_angle)
        translate([hook_d/2,0])
        circle(d = profile_d);

        translate([outer_d/2,-foot,0])
        rotate([0,0,180-joint_angle])
        rotate_extrude(angle=joint_angle)
        translate([outer_d/2,0])
        circle(d = profile_d);
        
    }

}

module mount_part1() {
    difference() {
        rotate_extrude()
        bl_square([6, 5], [2,0,0,0]);
        translate([0,0,-1])
        cylinder(d = bolt_d, h = 7);
        
        translate([0,0,5-1.8])
        cylinder(d1 = bolt_d, d2 = 5.7, h = 1.8);
    }
}

module mount_part2() {
    difference() {
        union() {
            cylinder(d = 9.5, h = 5);
            translate([0,0,5])
            cylinder(d1 = 9.5, d2 = 7.5, h = 1);
            translate([0,0,6])
            cylinder(d1 = 7.5, d2 = 5.5, h = 17);
        }
        
        translate([0,0,-1])
            cylinder(d = bolt_d, h = 25);
    }
}

module mount_part3() {
    difference() {
        rotate_extrude()
        bl_square([6, 5], [1,0,0,0]);
        translate([0,0,-1])
        cylinder(d = bolt_d, h = 7);
        translate([0,0,2])
        cylinder(d = profile_d + 0.3, h = 4);
    }
}

module hook_part() {
    
    hook();
    
    translate([0,-foot,0])
    rotate([90,0,0])
    linear_extrude(foot_length)
    difference() {
        circle(d = profile_d);
        circle(d = bolt_d);
    }

}

module hook_demo() {
        
    hook_part();
    
    translate([0,-foot-foot_length-2,0]) {
        rotate([-90,0,0])
        mount_part3();
        
        translate([0,0,0])
        rotate([90,0,0])
        mount_part2();
        
        translate([0,-23,0])
        rotate([90,0,0])
        mount_part1();
        
    }
    
}

module hook_toy() {

    hook();

    translate([0,-10-foot,0])
    rotate([-90,0,0])
    hull() {
        translate([0,0,0])
        cylinder(d = profile_d, h = foot_length);
        translate([-hook_d/2,0,0])
        rotate([0,90,0])
        cylinder(d = profile_d, h = hook_d);
        
        translate([-hook_d/2,0,0])
        sphere(d = profile_d);
        
        translate([hook_d/2,0,0])
        sphere(d = profile_d);
    }
    
}   

*hook_part();
*mount_part1();
*mount_part2();
*mount_part3();
*hook_toy();

hook();
