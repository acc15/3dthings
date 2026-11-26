use <threads-scad/threads.scad>;
use <bendlib/bendlib.scad>;

$fa = 0.5;
$fs = 0.5;

ptfe_d = 4.2;
ptfe_h = 4;
filament_d = 3;

rounding = 2;
rounding_steps = 2;

thread_h = 8;
thread_a = 45;

d = 20;
h = 30;
t = 2;

module shape(inner=true) {

    r = (ptfe_d-filament_d)/2;
    
    polygon(concat(
        [ [ptfe_d/2,0] ],
        bl_arc(rounding, [-90,0], [d/2-rounding, rounding]),
        [ [d/2, h/2-thread_h/2] ],
        inner ? [ [d/2-t*2,h/2-thread_h/2], [d/2-t,h/2-thread_h/2-t], ] : [ [d/2-t,h/2-thread_h/2] ],
        bl_arc(rounding-t, [0,-90], [d/2-rounding, rounding]),
        [ 
            [ ptfe_d/2+t, t ],
            [ ptfe_d/2+t, ptfe_h + t - r ],
            [ ptfe_d/2+t - r, ptfe_h + t ],
            [ filament_d/2, ptfe_h + t ],
            [ filament_d/2, ptfe_h + r ],
            [ ptfe_d/2, ptfe_h  ],
        ]
    ));
    
}

module part(inner=true) {
    translate([0,0,h/2-thread_h/2])
    if (inner) {
        difference() {
            ScrewThread(d-t*2, thread_h, tooth_angle = thread_a);
            translate([0,0,-1])
            cylinder(d = d - t * 4, thread_h+2);
        }
    } else {
        ScrewHole(d-t*2, thread_h, tooth_angle = thread_a) {
            cylinder(d = d, h = thread_h);
        }
    }
    rotate_extrude()
    shape(inner);
}

*part(true);

part(false);

//shape(true);




//

/*
polygon(
    bl_arc(rounding, 
*/
