use <bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

function jstxh_dim(pins) = [4.9 + (pins-1)*2.5,5.75,7];

module jstxh(pins) {
    cube(jstxh_dim(pins));
}

m3_nut_d = 5.4 * 2/sqrt(3);
m3_nut_h = 2.4;
m3_bolt_d = 3.4;
m3_head_d = 5.5;
m3_head_h = 3;

bolt_length = 15;

plate_dim = [42, 3, 11];
plate_hole_offsets = [
    [8.5, plate_dim[2]-7],
    [plate_dim[0]-8.5,plate_dim[2]-7]
];

pcb_dim = [36,26.5,1.7];
pcb_hole_dia = 3.5;
pcb_hole_offsets = [
    [pcb_dim[0]-5,pcb_dim[1]/2],
    [12,pcb_dim[1]/2]
];
pcb_offset = [(plate_dim[0]-pcb_dim[0])/2,0,plate_dim[2]+3];

pcb_idc_dim = [44.75, 8.3, 28];
pcb_idc_offset = [
    (pcb_dim[0]-pcb_idc_dim[0])/2, 
    1,
    pcb_dim[2]
];
pcb_idc_end_y = pcb_offset[1] + pcb_idc_offset[1] + pcb_idc_dim[1];

pcb_estepper_jstxh_dim = jstxh_dim(4);
pcb_estepper_jstxh_offset = [
    (pcb_hole_offsets[0][0] + pcb_hole_offsets[1][0])/2 - pcb_estepper_jstxh_dim[0]/2,
    pcb_idc_offset[1] + pcb_idc_dim[1]+3.7,
    pcb_dim[2]
];

motor_offset = [0,0,-plate_dim[0]];
motor_dim = [42,42,34];

mount_dim = [plate_dim[0], pcb_dim[1], pcb_offset[2]];
mount_thickness = 3;
mount_pcb_distance = 2;
mount_pcb_width = 1.2;
mount_z = mount_dim[2] - mount_pcb_distance;
mount_bolt_length = pcb_idc_end_y;

mount_lid_tolerance = 0.2;
mount_lid_thickness = 2;

cable_dim = [28, 1.5, 20];

mount_lid_wire_lock_width = (pcb_idc_dim[1]-cable_dim[1])/2;
mount_lid_wire_lock_height = m3_nut_d + mount_lid_thickness*2;
mount_lid_chamfer = 20;
mount_lid_bolt_length = bolt_length - mount_bolt_length - mount_lid_tolerance;

mount_lid_dim = [ 
    mount_dim[0] + (mount_lid_thickness+mount_lid_tolerance)*2, 
    motor_dim[2] - pcb_idc_end_y - mount_lid_tolerance + 3, 
    mount_thickness + mount_pcb_distance + pcb_dim[2] + pcb_idc_dim[2] + mount_lid_wire_lock_height
];
    
mount_lid_offset = [
    (mount_dim[0] - mount_lid_dim[0])/2,
    pcb_idc_end_y + mount_lid_tolerance,
    mount_z - mount_thickness
];



module plate() {
    rotate([90,0,0])
    linear_extrude(plate_dim[1])
    difference() {
        square([plate_dim[0], plate_dim[2]]);
        for (off = plate_hole_offsets) {
            translate(off)
            circle(d = 3);
        }
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


module pcb() {
    color("darkgray")
    linear_extrude(pcb_dim[2])
    difference() {
        square([pcb_dim[0],pcb_dim[1]]);
        for (off = pcb_hole_offsets) {
            translate(off)
            circle(d = pcb_hole_dia);
        }
    }
    
    translate(pcb_idc_offset) {
        cube(pcb_idc_dim);
    
        translate([(pcb_idc_dim[0]-cable_dim[0])/2,(pcb_idc_dim[1]-cable_dim[1])/2,pcb_idc_dim[2]])
        cube(cable_dim);
    }
    
    
    translate(pcb_estepper_jstxh_offset)
    jstxh(4);
        
    translate([jstxh_dim(2)[1],0,pcb_dim[2]]) {
        
        translate([0,pcb_dim[1]-jstxh_dim(2)[0],0])
        rotate([0,0,90])
        jstxh(2);
        
        translate([0,pcb_dim[1]-jstxh_dim(2)[0]-1-jstxh_dim(2)[0],0])
        rotate([0,0,90])
        jstxh(2);
    }
    
}

module rail_shape(t) {
    translate([0,-t/2])
    polygon([[-1,0], [0,0], [t/2,t/2], [0,t], [-1,t]]);
}

module rail(t, l, s = undef) {
    translate([0,t,0])
    rotate([-90,0,0]) {
        linear_extrude(l-t)
        rail_shape(t);
        
        rotate([180,0,0])
        linear_extrude(t,scale=0)
        rail_shape(t);
        
        if (s != undef && !$preview) {
            ld = t;
            translate([0,0,-t+s])
            intersection() {
                sphere(d = ld);
                translate([0,-ld/2,-ld/2])
                cube([ld/2,ld,ld]);
            }
        }
    }
}

    

module mount_ear(h, bolt, bottom, add) {
    ext_d = m3_bolt_d + mount_thickness*2;
    ear_thickness = 2;
    
    base_d = m3_head_d + ear_thickness*2;
    
    module shape() {
        intersection() {
            translate([-base_d/2-add,-base_d/2])
            square([mount_z+add,base_d]);
            union() {
                translate([-base_d/2-add,-base_d/2])
                square([base_d/2+add, bottom?base_d/2:mount_z]);
                circle(d = base_d);
            }
        }
    }
    
    translate([base_d/2,0,mount_z/2])
    rotate([-90,0,0])
    difference() {
        linear_extrude(h)
        shape();
    
        translate([0,0,-1])
        cylinder(d = m3_bolt_d, h = h + 2);
        
        if (bolt) {
            translate([0,0,h - m3_head_h])
            cylinder(d = m3_head_d, h = m3_head_h + 1);
        } else {
            translate([0,0,-1])
            cylinder(d = m3_nut_d, h = m3_nut_h + 1, $fn = 6);
        }
    }
}


module pcb_mount() {
    
    stiffener_thickness = 2.6;

    module mount_pad() {
        
        rotate_extrude()
        polygon([
            [0, 0],
            [m3_nut_d/2+1.5,0],
            [m3_nut_d/2+1.5,mount_thickness],
            [m3_bolt_d/2+1.5,mount_thickness+mount_pcb_distance],
            [0, mount_thickness+mount_pcb_distance],
        ]);
        
    }

    module stiffener_shape() {
        polygon([
            [mount_pcb_distance,0], 
            [mount_dim[2],0], 
            [mount_dim[2],pcb_idc_end_y],
            [mount_pcb_distance+mount_thickness,mount_dim[1]], 
            [-pcb_dim[2], mount_dim[1]],
            [-pcb_dim[2], pcb_idc_end_y + mount_pcb_distance+pcb_dim[2]],
            [mount_pcb_distance, pcb_idc_end_y]
        ]);
    }

    module stiffener() {
        translate([0,0,mount_dim[2]])
        rotate([0,90,0])
        linear_extrude(stiffener_thickness)
        stiffener_shape();
    }

    
    color("green")
    translate([mount_dim[0]+mount_lid_tolerance,0,0])
    mount_ear(mount_bolt_length, false, false, stiffener_thickness + mount_lid_tolerance);
    
    color("green")
    translate([-mount_lid_tolerance,0,0])
    mirror([-1,0,0])
    mount_ear(mount_bolt_length, false, false, stiffener_thickness + mount_lid_tolerance);

    translate([0,mount_thickness,0])
    rotate([90,0,0])
    difference() {
        union() {
            cube([mount_dim[0],mount_z,mount_thickness]);
            translate([0,0,mount_thickness-mount_pcb_width])
            cube([mount_dim[0],mount_dim[2],mount_pcb_width]);
        }
        for (off = plate_hole_offsets) {
            translate([off[0],off[1],-1])
            cylinder(d = m3_bolt_d,h=mount_thickness+2);
        }
    }
        
    difference() {
        union() {
        
            translate([0,0,mount_z - mount_thickness])
            difference() {
            
                union() {
                    cube([mount_dim[0], mount_dim[1], mount_thickness]);
                
                    translate([pcb_offset[0], pcb_offset[1],0])
                    for (off = pcb_hole_offsets) {
                        translate(off)
                        mount_pad();
                    }
                }
                
                translate([pcb_offset[0], pcb_offset[1],-1])
                for (off = pcb_hole_offsets) {
                    translate(off) {
                        cylinder(d = m3_bolt_d, h=mount_thickness+mount_pcb_distance+2);
                        linear_extrude(m3_nut_h+1)
                        offset(0.5)
                        circle(d = m3_nut_d - 1, $fn=6);
                    }
                }
                
                mount_hole_dim = [24, 8];
                mount_hole_r = 5;
                
                translate([(mount_dim[0]-mount_hole_dim[0])/2,mount_dim[1]-mount_hole_dim[1],-1])
                translate([mount_hole_r,mount_hole_r,0])
                linear_extrude(mount_thickness+2)
                offset(mount_hole_r)
                square([mount_hole_dim[0]-mount_hole_r*2,mount_hole_dim[1]]);
                
            }
        
            stiffener();
            translate([mount_dim[0]-stiffener_thickness,0,0])
            stiffener();
            
        }
        
        translate([0,pcb_idc_end_y,mount_z-mount_thickness/2]) {
            rail(mount_thickness, mount_dim[1], mount_dim[1] - pcb_idc_end_y-mount_thickness/2);
            translate([mount_dim[0],0,0])
            mirror([-1,0,0])
            rail(mount_thickness, mount_dim[1], mount_dim[1] - pcb_idc_end_y-mount_thickness/2);
        }
    }

}

module mount_lid() {
       
    module lid_wall() {
        polygon([
            [0,0],
            [mount_lid_dim[1],0],
            [mount_lid_dim[1],mount_lid_dim[2] - mount_lid_chamfer],
            [mount_lid_dim[1] - mount_lid_chamfer, mount_lid_dim[2]],
            [0, mount_lid_dim[2]]
        ]);
    }
    
    module lid_inner() {
        difference() {
            
            union() {
                lid_wall();
                translate([-mount_lid_wire_lock_width, mount_lid_dim[2] - mount_lid_wire_lock_height])
                square([mount_lid_wire_lock_width,mount_lid_wire_lock_height]);
            }
            difference() {
                offset(-mount_lid_thickness)
                lid_wall();
                translate([0,mount_lid_dim[2]-mount_lid_wire_lock_height])
                square([mount_lid_dim[1],mount_lid_wire_lock_height]);
            }
            square([mount_lid_dim[1]-mount_lid_thickness,mount_lid_thickness+1]);
            square([mount_lid_thickness, mount_lid_dim[2]-mount_lid_wire_lock_height]);
        }
    }

    module m3_diff() {
        translate([0,-mount_lid_wire_lock_width,mount_lid_dim[2]-mount_lid_wire_lock_height/2])
        rotate([-90,0,0])
        union() {
            translate([0,0,-1])
            cylinder(d = m3_bolt_d, h = mount_lid_dim[1]+1);
            translate([0,0,bolt_length/2 - mount_lid_tolerance - m3_nut_h])
            cylinder(d = m3_nut_d, h = mount_lid_dim[1], $fn=6);
        }
    }

    
    module lid_model() {
        union() {
            difference() {

                rotate([90,0,90])
                union() {
                    linear_extrude(mount_lid_thickness)
                    lid_wall();
                    
                    linear_extrude(mount_lid_dim[0])
                    lid_inner();

                    translate([0,0,mount_lid_dim[0] - mount_lid_thickness])
                    linear_extrude(mount_lid_thickness)
                    lid_wall();                    
                }
            
                translate([mount_lid_thickness+m3_nut_d/2,0,0])
                m3_diff();
                translate([mount_lid_dim[0] - mount_lid_thickness-m3_nut_d/2,0,0])
                m3_diff();
                
            }
            
            translate([mount_lid_thickness,0,mount_thickness/2]) 
            rail(mount_thickness, mount_lid_dim[1], mount_dim[1] - pcb_idc_end_y - mount_thickness/2);
            
            translate([mount_lid_dim[0]-mount_lid_thickness,0,mount_thickness/2]) 
            mirror([-1,0,0])
            rail(mount_thickness, mount_lid_dim[1], mount_dim[1] - pcb_idc_end_y - mount_thickness/2);
        }
    }
        
    translate(mount_lid_offset)
    lid_model();

    translate([-mount_lid_tolerance, mount_bolt_length+mount_lid_tolerance,0])
    mirror([-1,0,0])
    mount_ear(mount_lid_bolt_length, true, true, 0);
    
    translate([mount_dim[0] + mount_lid_tolerance, mount_bolt_length+mount_lid_tolerance,0])
    mount_ear(mount_lid_bolt_length, true, true, 0);

}

module mount_lid_cable_tie() {
    
    module m3_diff() {
    
        translate([0,-bolt_length/2, mount_lid_wire_lock_height/2])
        rotate([-90,0,0]) {
        translate([0,0,-1])
        cylinder(d=m3_head_d, h=m3_head_h+1);
        cylinder(d=m3_bolt_d, h=bolt_length/2+1);
        }
        
    }
    
    difference() {
    
        linear_extrude(mount_lid_wire_lock_height)
        polygon(concat(
            bl_arc(bolt_length/2, [180,270], [bolt_length/2,0]), 
            bl_arc(bolt_length/2, [270,360], [mount_lid_dim[0]-bolt_length/2,0]),
            [
                [mount_lid_dim[0] - (mount_lid_dim[0] - cable_dim[0])/2, 0],
                [mount_lid_dim[0] - (mount_lid_dim[0] - cable_dim[0])/2, -cable_dim[1]]
            ],
            bl_arc([cable_dim[1]*2,cable_dim[1]], [360,180], [mount_lid_dim[0]/2,-cable_dim[1]]),
            [
                [(mount_lid_dim[0] - cable_dim[0])/2, -cable_dim[1]],
                [(mount_lid_dim[0] - cable_dim[0])/2, 0],
            ]
        ));
        
        translate([mount_lid_thickness + m3_nut_d/2,0,0])
        m3_diff();
        
        translate([mount_lid_dim[0] - mount_lid_thickness - m3_nut_d/2,0,0])
        m3_diff();

    }
     
    
}

part = "mount";

if (part == "demo") {

    translate([0,-mount_lid_wire_lock_width-mount_lid_tolerance,mount_lid_dim[2]-mount_lid_wire_lock_height])
    translate(mount_lid_offset)
    mount_lid_cable_tie();

    mount_lid();

    pcb_mount();
    
    color("gray")
    plate();

    translate([0,0,-plate_dim[0]])
    motor();

    translate(pcb_offset)
    pcb();
    
} else if (part == "lid") {
    
    render()
    translate([-mount_lid_offset[0],-mount_lid_offset[2],mount_lid_offset[1]+mount_lid_dim[1]])
    rotate([-90,0,0])
    mount_lid();
    
} else if (part == "tie") {
    
    render()
    mount_lid_cable_tie();
    
} else if (part == "mount") {
    
    render()
    translate([0,mount_dim[2],0])
    rotate([90,0,0])
    pcb_mount();
    
}
















