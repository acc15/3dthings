use <../bendlib/bendlib.scad>;
use <../threads-scad/threads.scad>;

thickness = 1.5;

$fa = 0.2;
$fs = 0.2;

pump_d = 7.5;
pump_h = 6.5;

mattress_h = 10;
switch_angle = 50;

function switch_height(mattress_d) = (mattress_d/2 - pump_d/2)*tan(switch_angle);


module shape(mattress_d) {
    polygon([
        [0,0],
        [mattress_d/2,0],
        [mattress_d/2,mattress_h],
        [pump_d/2,mattress_h + switch_height(mattress_d)],
        [pump_d/2,mattress_h + switch_height(mattress_d) + pump_h],
        [0,mattress_h + switch_height(mattress_d) + pump_h]
    ]);
}

module shape2(mattress_d) {
    difference() {
        shape(mattress_d);

        offset(delta=-thickness)
        shape(mattress_d);
        
        square([pump_d/2-thickness,pump_h + switch_height(mattress_d) + mattress_h]);
        square([mattress_d/2-thickness,thickness]);
    }
}


module screw_adapter() {
    
    mattress_d = 26;
    mattress_thread_d = 22.75;
    mattress_pitch = 2.5;
    
    ScrewHole(mattress_thread_d, mattress_h-thickness,pitch=mattress_pitch, tolerance = 0.2) { 
        rotate_extrude()
        union() {
            shape2(mattress_d);
            square([mattress_d/2, mattress_h - thickness]);
        }
    }
}

module flat_adapter() {
    mattress_d = 17.5;
    rotate_extrude()
    shape2(mattress_d);
}


flat_adapter();





