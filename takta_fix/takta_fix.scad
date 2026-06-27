use <../bendlib/bendlib.scad>;
use <../threads-scad/threads.scad>;

$fa = 0.2;
$fs = 0.2;

base_dim = [26.5, 18.25, 3];
base_r = 2;

axis_d2 = 17.5;
axis_h = 23;

end_d = 14.4;
end_h = 3;

thread_height = 5;
thread_angle = 30;
thread_pitch = 3;
thread_tooth_height = 1.75;
thread_outer_d = 11;

bolt_inner_d = 7.15;


union() {

    translate([0,0,axis_h - thread_height]) {
        ScrewHole(thread_outer_d, thread_height, pitch = thread_pitch, tooth_angle = thread_angle, tooth_height = thread_tooth_height) {
            cylinder(d = axis_d2, h = thread_height);
        }
        //#cylinder(d = 7.15, h = 20);
    }

    difference() {

        union() {
            linear_extrude(base_dim[2])
            bl_square(bl_2d(base_dim), radius = base_r, center=true);

            cylinder(d1 = base_dim[1], d2 = axis_d2, h = axis_h);

            translate([0,0,axis_h])
            cylinder(d = end_d, h = end_h);            
        }

        translate([0,0,axis_h-thread_height])
        cylinder(d = 12.15, h = thread_height+end_h+1);
        
        cylinder(d1 = 15.15, d2 = 11, h = axis_h - thread_height);
        
    }

}
/*
translate([-20,-20,0])
#cube([40,40,3]);

#cylinder(d = 7.15, h = 20);
#cylinder(d = 10.15, h = 20);*/
*ScrewThread(thread_outer_d, 30, pitch = thread_pitch, tooth_angle = thread_angle, tooth_height = thread_tooth_height);

*ScrewHole(thread_outer_d, 20, pitch = thread_pitch, tooth_angle = thread_angle, tooth_height = thread_tooth_height) {
    cylinder(d = thread_outer_d + 5, h = 20);
}