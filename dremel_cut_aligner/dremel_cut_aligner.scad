use <bendlib/bendlib.scad>;
use <threads-scad/threads.scad>;

$fa = 0.8;
$fs = 0.8;

handle_d_min = 16;
handle_d_max = 26;
handle_length = 110;
handle_thread_height = 7;
handle_thread_d_min = 11.2;
handle_thread_d_max = 12.6;
handle_thread_pitch = 1.27;
handle_mount_nut_h = 15;
handle_mount_nut_d = 10;

saw_handle_d = 4.5; 
saw_handle_length = 12;

saw_d = 25; 
saw_t = 0.7;
saw_bolt_d = 6;
saw_bolt_h = 2;


module handle_mount() {
    ScrewThread(handle_thread_d_max, handle_thread_height, pitch = handle_thread_pitch);    
    
    translate([0,0,handle_thread_height])
    cylinder(d = handle_mount_nut_d, h = handle_mount_nut_h);
    
    translate([0,0,handle_thread_height + handle_mount_nut_h])
    cylinder(d = saw_handle_d, h = saw_handle_length);
    
    translate([0,0,handle_thread_height + handle_mount_nut_h + saw_handle_length])
    cylinder(d = saw_d, h = saw_t);
    
    translate([0,0,handle_thread_height + handle_mount_nut_h + saw_handle_length + saw_t])
    cylinder(d = saw_bolt_d, h = saw_bolt_h);
}

module handle() {

    rotate_extrude()
    polygon(concat(
        [[0,0]],
        bl_arc([(handle_d_max - handle_d_min)/2, handle_length/2], [-90, 90], [handle_d_min/2,handle_length/2]),
        [[0,handle_length]]
    ));
    
    translate([0,0,handle_length])
    handle_mount();

    
}


module handle_cut_demo() {

    translate([0,0,0])
    rotate([-90-10,0,0])
    translate([0,-saw_d/2,-handle_length-handle_thread_height-handle_mount_nut_h-saw_handle_length-saw_t/2])
    handle();
        
}

*handle_cut_demo();

thickness = 0.4*5;
saw_space = 5;

adapter_mount_d = handle_thread_d_max;
adapter_saw_d = saw_d + saw_space*2;
adapter_expansion_h = handle_mount_nut_h+saw_handle_length+saw_t/2 - saw_space;
adapter_saw_h = saw_space*2 + saw_t;
adapter_heel_h = 20;
adapter_saw_depth = 5;
adapter_saw_mark = 1;
adapter_angle = 10;

module adapter_base_shape() {
    polygon(concat([
        [0,0], 
        [adapter_mount_d/2,0],
        [adapter_saw_d/2,adapter_expansion_h],
        [adapter_saw_d/2,adapter_expansion_h+adapter_saw_h],
        [0,adapter_expansion_h+adapter_saw_h]
    ]));
}

module adapter_base_outer_shape() {
    intersection() {
        offset(delta=thickness)
        adapter_base_shape();
        square([adapter_saw_d/2+thickness,adapter_expansion_h+adapter_saw_h+thickness]);
    }
    
    translate([adapter_saw_d/2+thickness,adapter_expansion_h+adapter_saw_h/2])
    rotate(45)
    square([adapter_saw_mark*sqrt(2),adapter_saw_mark*sqrt(2)], center=true);
    
    translate([0,adapter_expansion_h+adapter_saw_h])
    square([adapter_saw_d/2+thickness, adapter_heel_h]);
}

module adapter_base_extrude_outer_shape() {
    union() {
        mirror([1,0,0])
        adapter_base_outer_shape();
        adapter_base_outer_shape();
    }
}

module adapter_outer_shell() {

    rotate_extrude(angle=180)
    adapter_base_outer_shape();

    rotate([90,0,0])
    linear_extrude(adapter_saw_d/2+thickness)
    adapter_base_extrude_outer_shape();

}


module adapter_form_cube(for_diff = false) {
    w = adapter_saw_d+thickness*2+adapter_saw_mark*2;
    h = adapter_expansion_h+adapter_saw_h+adapter_heel_h;
    
    translate([0,-adapter_saw_d/2-thickness+15,adapter_expansion_h+adapter_saw_h+8])
    rotate([-adapter_angle,0,0])
    translate([-w/2,(for_diff?thickness:0),-h])
    cube([
        w,
        w,
        h
    ]);
}

module adapter_cut_shell() {

    intersection() {
        rotate_extrude()
        adapter_base_shape();
        adapter_form_cube(true);
    }

    rotate([90,0,0])
    linear_extrude(adapter_saw_d/2+thickness+1) {
        translate([-adapter_saw_d/2,adapter_expansion_h])
        square([adapter_saw_d, adapter_saw_h]);
    }
    
    translate([0,0,adapter_expansion_h+adapter_saw_h-1])
    cylinder(d = saw_bolt_d, h = thickness+adapter_heel_h);
    
}

    
module adapter() {

    translate([0,0,handle_thread_height])
    intersection() {
        difference() {
            adapter_outer_shell();
            adapter_cut_shell();
        }
        #adapter_form_cube();
    }
    
    ScrewHole(handle_thread_d_max, handle_thread_height, pitch = handle_thread_pitch) {
        cylinder(d = handle_thread_d_max+thickness*2, h = handle_thread_height);
    }

}

module adapter_printable() {
    rotate([180+adapter_angle,0,0])
    adapter();
}

module adapter_preview() {
    rotate([90+adapter_angle,0,0])
    translate([0,saw_d/2,-handle_thread_height-adapter_expansion_h-adapter_saw_h/2]) {
    
        adapter();

        translate([0,0,-handle_length])
        handle();
    }
}

*adapter_printable();


adapter_preview();

