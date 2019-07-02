  //include <e3d_v6_all_metall_hotend.scad>;

xplate_dim = [100,120,3.2];
xplate_holes = [32.5, 42];
xplate_hole_d = 5;

xplate_offset = [0,0,20];

e3d_dim = [0,0,65.6];
volcano_dim = [0,0,69.8];

titan_dim = [44.5, 46.5, 24.5];
titan_hole_offset = [5.65, 7.65, -0.5];
titan_hotend_holes = [[16.5, 1.4], [12.5, 6], [16.5, 5]];
titan_hotend_offset = [titan_dim[0] - titan_hotend_holes[0][0] / 2 - 2.65, titan_dim[2] - titan_hotend_holes[0][0] / 2 - 1.65];

motor_dim = [42.3, 42.3, 22.75];
motor_hole_offset = [15.5, 15.5, 0];

hotend_height = 65.6;
hotend_depth = titan_hotend_holes[0][1] + titan_hotend_holes[1][1] + titan_hotend_holes[2][1] + 0.2;

titan_motor_distance = 2.2;
extruder_offset = [(xplate_dim[0] - motor_dim[0]) / 2, hotend_height - hotend_depth - 20, 5];

mount_dim = [xplate_holes[0] * 2 + 15, xplate_holes[1] + 35.5, titan_motor_distance];
mount_offset = [(xplate_dim[0] - mount_dim[0]) / 2, xplate_dim[1] / 2 - mount_dim[1] + 17.5, motor_dim[2] + extruder_offset[2]];
mount_round_r = 5;

bltouch_dim = [26, 11.54, 42.5];

fan_dim = [51.3, 51.3, 15];

fan_mount_d = 15;
fan_mount_thickness = 3;

union_tolerance = 0.1;

echo(mount_offset);


nozzle_offset = [ -extruder_offset[0] - titan_hotend_offset[0], mount_offset[2] + mount_dim[2] + titan_hotend_offset[1] ];


function arc(start, end, pos = [0,0], radius = 1, steps = 16) = [ for (i = [0:steps]) 
    let(a = start + (end - start) / steps * i) 
    [ 
        cos(a) * radius + pos[0],
        sin(a) * radius + pos[1]
    ] 
];

module fillet(r) {
    offset(r, $fn = 32) 
        offset(-r)
            children();
}

module profile(t) {
    difference() {
        children();
        offset(-t)
            children();
    }
}

module half_profile(dim, start = 0.5, end = 1.0, tol = 0.1 ) {
    //translate([-dim[0] * start, 0]) {
        difference() {
            children();
            if (start > 0) {
                translate([-tol,-tol])
                    square([dim[0] * start + tol, dim[1] + tol*2]);
            }
            if (end < 1) {
                translate([dim[0] * end, -tol])
                    square([dim[0] * (1 - end) + tol, dim[1] + tol*2]);
            }                        
        }
    //}
}

module rot_ext(angle = 360, max_r = 100, min_z = -50, max_z = 50, $fn = 64) {
    if (angle < 0 || angle > 360) {
        rotate_extrude()
            children();
    } else {
        render()
        intersection() {
            translate([0,0,min_z])
                linear_extrude(max_z - min_z)
                    polygon(concat([[0,0]],arc(180, 180 + angle, radius = max_r)));
            rotate_extrude()
            children();
        }
    }
}

module bltouch() {
    color("green") import("BL touch by MD3DD.stl");
}

module xplate() {
    color("blue") import("Y Carriage.STL");
}

module base_mount_holes() {
    translate([motor_dim[0] / 2, motor_dim[1] / 2,0])
    for (x = [-motor_hole_offset[0],motor_hole_offset[0]], y = [-motor_hole_offset[1], motor_hole_offset[1]])
        translate([x,y, - 1]) cylinder(d = 3.5, h = titan_motor_distance + 2);
}

module xplate_bolts_layout() {    
    for (x = [-xplate_holes[0], xplate_holes[0]], y = [0,xplate_holes[1]]) 
        translate([xplate_dim[0] / 2 + x, xplate_dim[1] / 2 - y])
            children();
}

module xplate_bolts() {
    color("cyan")
    xplate_bolts_layout()
        cylinder(d = 5.4, h = motor_dim[2] + extruder_offset[2] + titan_motor_distance + 1, $fn = 32);
        /*
        hull() {
            translate([0,5,0])
                cylinder(d = 5.4, h = motor_dim[2] + extruder_offset[2] + titan_motor_distance + 1, $fn = 32);
            translate([0,-5,0])
                cylinder(d = 5.4, h = motor_dim[2] + extruder_offset[2] + titan_motor_distance + 1, $fn = 32);
        }*/
}

rail_dim = [20, extruder_offset[1], 5];

module bltouch_rail_hole_poly() {
    polygon([[rail_dim[0] * 2 / 6, -union_tolerance], [rail_dim[0] / 6, rail_dim[2] - union_tolerance], [rail_dim[0] * 5 / 6, rail_dim[2] - union_tolerance], [rail_dim[0] * 4 / 6, -union_tolerance]]);
}
        

module base_mount_with_rail() {
    difference() {
        union() {
            linear_extrude(mount_dim[2])
                polygon(rect([mount_dim[0],mount_dim[1]], mount_round_r));
            
            translate([extruder_offset[0] - rail_dim[0]/2,0,-rail_dim[2]])
                cube(rail_dim);
        }
        
        translate([extruder_offset[0] - rail_dim[0]/2,rail_dim[1] - union_tolerance,-rail_dim[2]])
        rotate([90,0,0])
            linear_extrude(rail_dim[1] + union_tolerance * 2)
                bltouch_rail_hole_poly();
        
    }
    
}

module base_mount() {
    difference() {
        translate(mount_offset)
            base_mount_with_rail();

        translate([0,0,motor_dim[2]])
            translate(extruder_offset)
                base_mount_holes($fn = 64);
        
        xplate_bolts();
    }
}

module xplate_spacer() {
    difference() {
        cylinder(d = 5.4 + 3.2 * 2, h = motor_dim[2] + extruder_offset[2] - fan_mount_thickness);
        translate([0,0,-0.5]) cylinder(d = 5.4, h = motor_dim[2] + extruder_offset[2] + 1);
    }    
}


module extruder() {
    translate([0,motor_dim[1] / 2 - (motor_hole_offset[1] + titan_hole_offset[1]),motor_dim[2] + titan_motor_distance])
    color("lightgreen") titan(); 
    
    emotor();
    
    translate([titan_dim[0] - titan_hotend_holes[0][0] / 2 - 2.65,
        hotend_depth,
        motor_dim[2] + titan_motor_distance + (titan_dim[2] - titan_hotend_holes[0][0] / 2 - 1.65)])
        rotate([0,-90,90]) 
            e3d();
    
}


module cylinder_tower(p, t, i = 0, z = 0) {
    if (i < len(p)) {
        translate([0,0,z])
        cylinder(d = p[i][0], h = p[i][1] + t);
        
        cylinder_tower(p, t, i + 1, z + p[i][1] - t);
    }
}

module titan() {
    difference() {
        union() {
            cube(titan_dim);
            translate([motor_hole_offset[0] * 2 + titan_hole_offset[0], motor_hole_offset[1] * 2 + titan_hole_offset[1],titan_dim[2] - 4 - 15])
                cylinder(d = 34, h = 4);
        }
    
        chamfer = 4.5;
        
        translate([0,0,-0.5])
        rotate([0,0,45])
        translate([-chamfer/2, -chamfer/2])
        cube([chamfer, chamfer, titan_dim[2] + 1]);
     
        translate(motor_hole_offset + titan_hole_offset)
        for (i = [0:2]) {
            rotate([0,0,-i*90])
            translate(-motor_hole_offset)
            cylinder(d = 3, h = titan_dim[2] + 1, $fn = 32);
        }
        
        
        translate([titan_hotend_offset[0], -0.1, titan_hotend_offset[1]])
        rotate([-90,0,0])
        cylinder_tower(titan_hotend_holes, 0.1);
        
    }   
}

module emotor() {
    difference() {
        cube(motor_dim);
        
        translate([motor_dim[0] / 2, motor_dim[1]/2,0])
        for (i = [0:3]) 
            rotate([0,0,90 * i])
            translate([0,0,motor_dim[2] - 5] - motor_hole_offset)
            cylinder(d = 3, h = 5.5, $fn = 32);
            
            
        chamfer = norm([motor_dim[0], motor_dim[1]]) - 54;
            
        translate([motor_dim[0] / 2, motor_dim[1] / 2])
        for (i = [0:3]) 
            rotate([0,0,90 * i])
            translate([-motor_dim[0] / 2, -motor_dim[1] / 2])
            rotate([0,0,45])
            translate([-chamfer/2,-chamfer/2,-0.5])
            cube([chamfer,chamfer,motor_dim[2] + 1]);
            
    }
            
    difference() {
        translate([motor_dim[0]/2, motor_dim[1]/2, motor_dim[2]])
            cylinder_tower([[22, 2], [5, 20.75]], 0.1, $fn = 32);
        
        translate([motor_dim[0]/2 + 2, motor_dim[1]/2 - 5, motor_dim[2] + 2 + 20.75 - 18.5])
            cube([10, 10, 18.6]);
    }
    
    translate([motor_dim[0]/2 - 16.25 / 2,motor_dim[1] - 0.1,0]) cube([16.25, 6.1, 9]);
    
}

module fan() {   
    ear_d = 6.75;
    ear_r = ear_d / 2;
    ear_hole = 4.5;
    
    module fan_ears() {
    
        
        difference() {
            hull() {
                translate([fan_dim[0] - 4 - ear_r,50.4 - ear_r])
                circle(d = ear_d, $fn = 32);
            
                translate([fan_dim[0] - 48.9 + ear_r,1.2 + ear_r])
                circle(d = ear_d, $fn = 32);    
            }
            
            translate([fan_dim[0] - 4 - ear_r,50.4 - ear_r])
            circle(d = ear_hole, $fn = 32);
            
            translate([fan_dim[0] - 48.9 + ear_r,1.2 + ear_r])
            circle(d = ear_hole, $fn = 32);
        }
      
    }

    render()
    difference() {
        linear_extrude(fan_dim[2]) {
            
            fan_ears();
            
            sq_dim = [26.5, 19.4];
            translate([fan_dim[0] - sq_dim[0],0])
                square(sq_dim);
            
            fan_d = 48;
            translate([fan_d/2 + 2,fan_d / 2,0]) circle(d = fan_d, $fn = 64);
                
        }
        
        
        translate([fan_dim[0] - 24.2, 27.5, 1.3])
            cylinder(d = 32, h = fan_dim[2]);
    }

}

module mirror_clone() {
    mirror([1,0,0])
        children();
    children();
}

module fan_mount() {    
    //thickness = 3;
    
    //translate([xplate_dim[0]/2,-(motor_dim[2]+extruder_offset[2]-fan_mount_thickness),20 + xplate_dim[1]/2])
    
    translate([xplate_holes[0] + (xplate_dim[0]/2-xplate_holes[0]), -(motor_dim[2] + extruder_offset[2] - fan_mount_thickness), 20])
        mirror_clone()
            translate([-fan_mount_d / 2 - xplate_holes[0],0,0])
            rotate([90,0,0])
            fan_mount_base();
}

module fan_mount_base() {
    linear_extrude(fan_mount_thickness)
    difference() {
        polygon(rect([fan_mount_d,fan_mount_d + 20 + xplate_holes[1]],[mount_round_r,0,0,mount_round_r]));
        hull($fn = 32) {
            translate([fan_mount_d / 2, fan_mount_d / 2]) circle(d = 5.4);
            translate([fan_mount_d / 2, fan_mount_d / 2 + 20]) circle(d = 5.4);
        }
        hull($fn = 32) {
            translate([fan_mount_d / 2, fan_mount_d / 2 + xplate_holes[1]]) circle(d = 5.4);
            translate([fan_mount_d / 2, fan_mount_d / 2 + xplate_holes[1] + 20]) circle(d = 5.4);
        }
    }
}

module e3d_volcano() {
    import("E3D_Volcano_1.75mm_0.8mm_Hotend_Assembly_fixed.STL");
}


module a_e3d() {
    
    translate([0,0,e3d_dim[2]])
    rotate([180,0,-90]) 
        e3d();
    
}

module a_volcano() {
    rotate([90,0,0])
    translate([-18.26,0,-32.13])
    e3d_volcano();
}


*translate(nozzle_offset) {

translate(xplate_offset) {
    rotate([90,0,0]) {    
        %base_mount();

        translate(extruder_offset)
            extruder();
        
        xplate_bolts_layout()
            xplate_spacer($fn = 32);   
    }

    rotate([0,0,0]) xplate();
    
}

translate([extruder_offset[0] + 10, -(bltouch_dim[1]/2 + 2), bltouch_dim[2]])
    rotate([180,0,0])    
        bltouch();

}



echo([[10,10], [5,5]] + [15,15]);



module sq_duct() {
    
    sz = [25,25];
    dim = [6,10];
    f = 1.5;
    a = 10;
    t = 1.2;
    u = 0.1;
    
    c = 0.4;
    

    prof = [[0,dim[1]], [0,0], [dim[0],0], [dim[0] - sin(a)/cos(a)*dim[1], dim[1]]];
    off = dim[0]*(1-c);// + f;
    
    
    module make_profile() {
        profile(t)
            fillet(f)
                polygon(prof);
    }
    
    module hole_profile(start = 0, end = 1) {
        half_profile(dim, start, end)
        difference() {
            make_profile();
            translate([dim[0] -  t / sin(90 - a),0,0])
                rotate(a)
                    translate([-t,-t/2,0])
                        square([t,t*2]);
        }
    }
    
    module profile_wall(l, start = 0) {    
        rotate([90,0,90])
            linear_extrude(l)
                hole_profile(start, 1);
    }
    
    /*
    profile_wall(false);
    translate([sz[0],0,0])
        mirror([1,0,0])
        profile_wall(false);
    */
    
    module profile_wall_l() {

        profile_corner_lb();
        
        translate([0,sz[1],0])
            mirror([0,1,0])
                profile_corner_lb();

        translate([-dim[0], sz[1],0])
            rotate([0,0,-90])
                profile_wall(sz[1], c);
        
    }
    
    module profile_wall_t() {
        translate([0,-dim[0],0])
            profile_wall(sz[0]);
    }
    
    
    profile_wall_l();
    
    translate([sz[0],0,0])
    mirror([1,0,0])
        profile_wall_l();
    
    translate([0,sz[1],0])
        mirror([0,1,0])
            profile_wall_t();
    
    profile_wall_t();
    

    
    module profile_corner_lb() {
        
        rot_ext(angle = 90)
            translate([-dim[0], 0])
                half_profile(dim, c)
                    make_profile();
                    
        profile_corner_fill();
        translate([0,0,dim[1]-t])
            profile_corner_fill();
    
        translate([-off,-off-dim[0]*c,0])
            rotate([90,0,90])
                linear_extrude(off)
                    half_profile(dim, 0, c)
                        make_profile();
    
    }
   
    module profile_corner_fill() {
        translate([-off, -off])
        linear_extrude(t)
        difference() {
            square(off);
            
            translate([off + u, off + u])
                circle(r = off - u, $fn = 64);
        }
    }
}

xplate();

//base_mount();

//sq_duct();
//translate([18,12,-5])
//a_e3d();

//fan_mount();


/*

translate([0,-mount_offset[2] - titan_motor_distance - 5,fan_dim[1] + 20])
rotate([0,-25,0])
translate([fan_dim[2],0,0])
rotate([90,90,-90])
fan();

translate([xplate_dim[0] + 20,-mount_offset[2] - titan_motor_distance - 5,fan_dim[1] + 20])
rotate([0,25,0])
rotate([90,90,-90])
fan();

*/

