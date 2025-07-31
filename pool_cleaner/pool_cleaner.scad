use <../threads-scad/threads.scad>;
use <../bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;


module p() {
    polygon([[0,0],[12,0],[12,12],[24,24],[24,48],[0,48]]);
}

thickness = 2;
tolerance = 0.2;

thread_dia = 20.4;
thread_pitch = 1.814;
thread_angle = 55;
nose_height = 12;
hole_dia = 15;

filter_hole_dia = 1;

module filter(holes = true) {
    difference() {
        ScrewHole(thread_dia, nose_height, pitch=thread_pitch, position=[0,0,thickness], tooth_angle=thread_angle, tolerance=tolerance) {
            ScrewThread(thread_dia+thickness*4+tolerance, nose_height + thickness, pitch=thread_pitch, tooth_angle=thread_angle, tolerance=tolerance);
        }
        translate([0,0,-tolerance])
        if (holes) {            
            loop_count = 4;
            for (i = [0:loop_count-1]) {
                loop_dia = i * (hole_dia / loop_count);
                
                loop_length = PI * loop_dia;
                filter_hole_count = ceil(max(1, loop_length / (filter_hole_dia + thickness)));
                for (j = [0:filter_hole_count-1]) {
                    angle = j * 360 / filter_hole_count;
                    translate(bl_polar(loop_dia/2, angle)) {
                        cylinder(d = filter_hole_dia, h = thickness+tolerance*2, $fa = 0.1, $fs=0.1);
                    }
                }
            }
        } else {
            echo("Requires filter mesh with dia = ", thread_dia - tolerance*2);
            cylinder(d = hole_dia, h = thickness+tolerance*2);
            
        }

    }
}

module tube() {
    
    module shape() {               
        polygon([
            [0,0],
            [thread_dia/2+thickness*3, 0],
            [thread_dia/2+thickness*3, nose_height],
            [thread_dia/2+thickness*3+nose_height/2, nose_height*2],
            [thread_dia/2+thickness*3+nose_height/2, nose_height*3],
            [thread_dia/2+thickness*3, nose_height*4],
            [thread_dia/2+thickness*3, nose_height*5],
            [0,nose_height*5]
        ]);
    }
    
    ScrewHole(thread_dia+thickness*4, nose_height, pitch=thread_pitch, tooth_angle=thread_angle, tolerance=tolerance)
    rotate_extrude() 
    union() {
        difference() {
            shape();
            offset(-thickness)
            shape();
            translate([-tolerance,-tolerance])
            square([thread_dia/2+thickness*2+tolerance, nose_height*5+tolerance*2]);
        }
        square([thread_dia/2+thickness*3, nose_height]);
    }
    
}
*tube();

filter(false);

