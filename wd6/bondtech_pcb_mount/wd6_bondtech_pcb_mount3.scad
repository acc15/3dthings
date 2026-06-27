use <bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

function jst_xh_dim(pins) = [4.9 + (pins-1)*2.5,5.75,7];
jst_xh_pin_offset = [2.5, 2.35, -2.5];
jst_xh_pin_dim = [0.64,0.64,jst_xh_dim(0)[2]-0.5-jst_xh_pin_offset[2]];

jst_xh_thickness = 0.75;

module jst_xh(pins) {
    dim = jst_xh_dim(pins);
    window_shape_offset = 1.85;
    
    module window_shape() {
    
        difference() {
            bl_square([pins == 2 ? 1.9 : 1.65, 4 + 1], [0,0,1,0]);
            translate([0,3.5])
            circle(d = 1);
            //cube([1.65, jst_xh_thickness+2, 4 + 1]);
        }
    
    }
    
    module front() {
        translate([0,jst_xh_thickness,0])
        rotate([90,0,0])
        linear_extrude(jst_xh_thickness)
        difference() {
            square([dim[0], dim[2]]);
            translate([window_shape_offset,dim[2]-4])
            window_shape();        
            translate([dim[0]-window_shape_offset,dim[2]-4])
            mirror([-1,0,0])
            window_shape();
        }
    }
    
    module side() {
        rotate([90,0,90])
        linear_extrude(jst_xh_thickness)
        difference() {
            square([dim[1],dim[2]]);
            translate([jst_xh_thickness,dim[2]-3])
            square([1,4]);
        }
    }
    
    module back() {
        translate([0,dim[1]-jst_xh_thickness,0])
        cube([dim[0], jst_xh_thickness, dim[2]]);            
    }
    
    module bottom() {
        cube([dim[0],dim[1],jst_xh_thickness]);
    }
        
    
    front();
    side();
    translate([dim[0],0,0])
    mirror([-1,0,0])
    side();    
    back();
    bottom();

    color("gray")
    for (i = [0:pins-1]) {
        translate([(dim[0]-jst_xh_pin_offset[0]*(pins-1))/2+jst_xh_pin_offset[0]*i-jst_xh_pin_dim[0]/2, jst_xh_pin_offset[1]-jst_xh_pin_dim[1]/2, jst_xh_pin_offset[2]])
        cube(jst_xh_pin_dim);
    }

}

jst_xh(5);


function jstvh_dim(pins) = [4.9 + (pins-1)*2.5,5.75,7];


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

motor_offset = [0,0,-plate_dim[0]];
motor_dim = [42,42,34];

mount_dim = [plate_dim[0], 26.5, plate_dim[2]+3];
mount_thickness = 3;
mount_pcb_distance = 2;
mount_pcb_width = 1.2;
mount_z = mount_dim[2] - mount_pcb_distance;
mount_bolt_length = 9.3;


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



part = "demo";

if (part == "demo") {


    pcb_mount();
    
    color("gray")
    plate();

    translate([0,0,-plate_dim[0]])
    motor();

} else if (part == "mount") {
    
    render()
    translate([0,mount_dim[2],0])
    rotate([90,0,0])
    pcb_mount();
    
}
















