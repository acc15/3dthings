

tolerance = 0.1;

motor_h = 37.4;
motor_w = 42.4;
motor_d = 22;
motor_dh = 2;

motor_axis_d = 5;
motor_axis_h = 21;
motor_axis_cut_d = 4.5;
motor_axis_cut_h = 20;

bearing_d = 12.75;
bearing_inner_d = 6.3;
bearing_h = 4.8;
bearing_mount_t = 0.48*5;
bearing_tolerance = 0.1;
bearing_pad_d = 8;
bearing_pad_h = 1;

motor_hole_offset = 22;
motor_hole_d = 3.2;
motor_hole_h = 5;
motor_hole_n = 4;

board_dim = [59.35, 43.6];
board_hdim = [53, 37];
board_t = 1.5;
board_pad_h = 5;
board_pad_d = 6;
board_hole_d = 3.2;
board_offset = [board_dim[0]/2+motor_w/2+4,0,motor_h-board_t-board_pad_h-tolerance];

table_d = 150;

foot_n = 4;
foot_inset = 1;
foot_dim = [bearing_h + bearing_pad_h*2 + bearing_tolerance*2 + bearing_mount_t*2, bearing_d - foot_inset*2];
foot_spacing = 5;
foot_offset = table_d/2 - foot_dim[0]/2 - foot_spacing;


table_t = 0.2 * 8;
table_h_t = 0.48*5;
table_axis_d = motor_axis_d + tolerance*2;
table_stifferer_n = 8;
table_skirt = foot_dim[0] + foot_spacing*2; //bearing_h + bearing_tolerance*3 + bearing_mount_t + 5;
table_stiffener_h = 5;

motor_h_offset = 10;


base_t = 4;

$fa = 0.3;
$fs = 0.3;

module table_stiffener() {
    
    
    xmin = table_axis_d/2+table_h_t-tolerance;
    xmax = table_d/2 - table_skirt - tolerance;
    fillet = motor_axis_cut_h - table_stiffener_h;
    
    rotate([90,0,0])
    translate([0,0,-table_h_t/2])
    linear_extrude(table_h_t)
    difference() {
        polygon([
            [xmin,0], 
            [xmax,0], 
            [xmax, table_stiffener_h], 
            [xmin + fillet, table_stiffener_h],
            [xmin, motor_axis_cut_h],
        ]);
        translate([xmin + fillet, table_stiffener_h + fillet])
        circle(r = fillet);
    }
    
}

module table() {

    union() {

        cylinder(d = table_d, h = table_t);

        translate([0,0,table_t])
        linear_extrude(motor_axis_cut_h)
        difference() {
            circle(d = table_axis_d + table_h_t*2 + tolerance*2);

            difference() {
                circle(d = table_axis_d);
                
                translate([table_axis_d/2 - 0.5 ,-tolerance-table_axis_d/2])
                square(table_axis_d + tolerance*2);
            }
        }

        translate([0,0,table_t])
        for (i = [0:table_stifferer_n-1])
        rotate([0,0,i*(360/table_stifferer_n)])
        table_stiffener();
        
        translate([0,0,table_t])
        linear_extrude(bearing_d/2)
        difference() {
            circle(d = table_d - table_skirt*2);
            circle(d = table_d - table_skirt*2 - table_h_t*2);
        }

    }

}


module base() {
    
    fillet = 4;
        
    
    difference() {
        union() {
        
            linear_extrude(base_t)
            difference() {
            
                offset(-fillet)
                offset(fillet)
                union() {
                    
                    difference() {
                        circle(d = table_d);
                        circle(d = table_d - table_skirt*2 - fillet*2);
                    }
                    
                    difference() {
                        union() {
                            
                            offset(fillet) 
                                square(motor_w, center=true);
                            
                            offset(fillet) 
                                for (i = [0:foot_n-1])
                                    rotate(45 + i*360/foot_n)
                                        translate([motor_d/2+tolerance,-foot_dim[1]/2])
                                            square([table_d/2 - table_skirt - motor_d/2+tolerance, foot_dim[1]]);
                            
                        }

                        circle(d = motor_d + tolerance*2);
                    }
                    
                    offset(fillet)
                    translate([board_offset[0], board_offset[1]])
                    square(board_dim, center=true);
                
                }
            
                motor_holes(motor_hole_d);
                
                for (i = [0:foot_n-1])
                    rotate(45 + i * (360 / foot_n))
                    translate([foot_offset, 0])
                    offset(tolerance)
                    square([foot_dim[0], foot_dim[1]], center=true);
                
            }
            
            translate([board_offset[0], board_offset[1], -board_pad_h])
                linear_extrude(board_pad_h)
                    board_holes(board_pad_d);
            
        }
        
        translate([board_offset[0], board_offset[1], -board_pad_h-tolerance])
        linear_extrude(board_pad_h + base_t + tolerance*2)
        board_holes(board_hole_d);
        
    }
        
}

module board_holes(d) {
    translate([-board_hdim[0]/2,-board_hdim[1]/2])
        circle(d = d);
    
    translate([+board_hdim[0]/2,-board_hdim[1]/2])
        circle(d = d);
    
    translate([+board_hdim[0]/2,+board_hdim[1]/2])
        circle(d = d);
    
    translate([-board_hdim[0]/2,+board_hdim[1]/2])
        circle(d = d);
}

module board() {
    
    color("green")
    linear_extrude(board_t)
    difference() {
        square(board_dim, center=true);
        board_holes(board_hole_d);
    }
    
}

module battery() {
    
    cylinder(d = 14.2, h = 50);
    
}
    
module motor_holes(d) {
    for (i = [0:motor_hole_n-1]) {
        rotate([0,0,45+i*360/motor_hole_n])
        translate([motor_hole_offset,0,motor_h - motor_hole_h])
        circle(d = d);
    }
}

module motor() {


    color("gray")
    difference() {
        translate([-motor_w/2,-motor_w/2,0])    
        cube([motor_w, motor_w, motor_h]);
        linear_extrude(motor_hole_d + tolerance)
        motor_holes(motor_hole_d);
    }

    
    translate([0,0,motor_h])
    cylinder(d = motor_d, h = motor_dh);
    
    color("lightgray")
    translate([0,0,motor_h+motor_dh])
    difference() {
        cylinder(d = motor_axis_d, h = motor_axis_h);
        translate([-motor_axis_d/2+motor_axis_cut_d,-motor_axis_d/2,motor_axis_h - motor_axis_cut_h])
        cube([motor_axis_d, motor_axis_d, motor_axis_cut_h + tolerance]);
    }


}



module bearing() {
    
    
    #difference() {
        cylinder(d = bearing_d, h = bearing_h);
        translate([0,0,-tolerance])
        cylinder(d = bearing_inner_d, h = bearing_h + tolerance*2);
    }
    
}


module foot() {
    
    
    bearing_h_offset = motor_h_offset + motor_h + motor_dh + motor_axis_h - bearing_d/2;
    
    translate([-foot_dim[0]/2,0,0])
    difference() {
        union() {
            difference() {
                union() {
                
                    translate([0,-foot_dim[1]/2,0])
                    cube([foot_dim[0],foot_dim[1],bearing_h_offset]);
                    
                    translate([0,0,bearing_h_offset])
                    rotate([0,90,0])
                    cylinder(d = foot_dim[1], h = foot_dim[0]);
                        
                }
                translate([bearing_mount_t,0,bearing_h_offset])
                rotate([0,90,0])
                cylinder(d = bearing_d + foot_inset*2, h = bearing_h + bearing_tolerance*2 + bearing_pad_h*2);
            }
            
            translate([bearing_mount_t,0,bearing_h_offset])
            rotate([0,90,0])
            cylinder(d1 = foot_dim[1], d2 = bearing_pad_d, h = bearing_pad_h);
            
            translate([bearing_mount_t+bearing_pad_h*2 + bearing_h + bearing_tolerance*2,0,bearing_h_offset])
            rotate([0,-90,0])
            cylinder(d1 = foot_dim[1], d2 = bearing_pad_d, h = bearing_pad_h);
        }
        
        translate([-tolerance,0,bearing_h_offset])
        rotate([0,90,0])
        cylinder(d = bearing_inner_d, h = foot_dim[0] + tolerance*2);
        
    }
    
    
    foot_mount_d = 4.5;
    foot_mount_offset = motor_h_offset + motor_h - base_t - foot_mount_d - tolerance;
    foot_diff_x = foot_dim[0] + foot_mount_d*2 + tolerance*2;
    foot_diff_y = foot_dim[1] + foot_mount_d*2 + tolerance*2;
    
    module foot_diff() {
        translate([foot_dim[0]/2+foot_mount_d,foot_diff_y/2,0])
        rotate([90,0,0])
        cylinder(r = foot_mount_d, h = foot_diff_y);
        
        translate([-foot_dim[0]/2-foot_mount_d,foot_diff_y/2,0])
        rotate([90,0,0])
        cylinder(r = foot_mount_d, h = foot_diff_y);
            
        translate([foot_diff_x/2,-foot_dim[1]/2-foot_mount_d,0])
        rotate([0,-90,0])
        cylinder(r = foot_mount_d, h = foot_diff_x);
        
        translate([foot_diff_x/2,foot_dim[1]/2+foot_mount_d,0])
        rotate([0,-90,0])
        cylinder(r = foot_mount_d, h = foot_diff_x);
    }
     
    translate([0,0,foot_mount_offset])
    difference() {
        linear_extrude(base_t + foot_mount_d)
        offset(foot_mount_d)
        square([foot_dim[0], foot_dim[1]], center=true);//cube([foot_dim[0]*2, foot_dim[1]*2, base_t]);
        
        foot_diff();
    }
    
    
    translate([0,0,0])
    difference() {
        linear_extrude(base_t + foot_mount_d)
        offset(foot_mount_d)
        square([foot_dim[0], foot_dim[1]], center=true);//cube([foot_dim[0]*2, foot_dim[1]*2, base_t]);
        
        translate([0,0,foot_mount_d + base_t])
        foot_diff();
    }
    
}

union() {
translate([0,0,motor_h_offset]) {

translate([0,0,motor_h])
base();

motor();

translate(board_offset)
board();

translate([0,0,table_t + motor_h + motor_dh + motor_axis_h])
rotate([180,0,0])
table();
    
}

for (i = [0:3]) {    
    rotate([0,0,45 + i * 360/foot_n]) {
        translate([foot_offset,0,0]) {
            foot();
        }
    }
}
}

//foot();



module battery_pack() {
    
    
    battery_d = 14.8;
    battery_h = 50.1;
    
    wall_t = 0.48*4;
    battery_grid = [2,2];

    contact_w = 6;
    contact_t = 1;
    
    spring_space = 3;

    ext_sd = battery_d + wall_t;
    ext_hd = battery_d/2 + wall_t;
    
    box_dim = [wall_t + ext_sd * battery_grid[0], wall_t + ext_sd * battery_grid[1], battery_h];
     
    axis_d = 3;
    axis_d_tol = 0.4;
    axis_tol = 0.2;
    axis_ext_d = axis_d + wall_t * 2 + axis_d_tol*2;
    
    contact_hole_d = 8;
    
    lock_length = (box_dim[1] - ext_hd);
    axis_diff = axis_ext_d - axis_d;

    module box_shape() {
        
        translate([axis_ext_d, axis_ext_d])
        offset(axis_ext_d)
        square([box_dim[0],box_dim[1] - axis_ext_d*2]);
        
    }
    
    module box_grid_shape() {
        difference() {
            box_shape();
            
            translate([axis_ext_d + ext_hd, ext_hd])
            for (i = [0:battery_grid[0]-1], j = [0:battery_grid[1]-1])
                translate([i * ext_sd, j * ext_sd])
                circle(d = battery_d);
        }
    }
    
    module contacts(a = true, b = true, l = 1) {
        translate([-battery_d/2,0,spring_space]) {
        
            if (a) {
                translate([0,-contact_w/2,0])
                    cube([battery_grid[0]*ext_sd*l + axis_ext_d + tolerance, contact_w, contact_t]);
            }
            
            if (b) {
                translate([0,-contact_w/2 + ext_sd,0])
                    cube([battery_grid[0]*ext_sd*l + axis_ext_d + tolerance, contact_w, contact_t]);
            }
            
        }
    }

    module lock_shape(a = true, b = true) {
        module half_lock_shape() {
            polygon([
                [-tolerance,0],
                [-tolerance,-wall_t], 
                [wall_t, -wall_t], 
                [wall_t*2,-wall_t*2],
                [wall_t*2,0]
            ]);
        }
        
        union() {
        if (a) 
            half_lock_shape();
        if (b)
            mirror([0,1])
                half_lock_shape();
        }
    }
    
    
    module hinge(tol) {
        r_dh = axis_diff + tol;
        r_d1 = axis_d + tol*2;
        r_d2 = axis_ext_d + tol*2;
        r_h = box_dim[1]/3 + tol*2;

        translate([0,0,box_dim[1]/3 - tol])
            cylinder(d = axis_ext_d + tol*2, h = r_h);
        
        translate([0,0,box_dim[1]/3 - r_dh - tol])
            cylinder(d1 = r_d1, d2 = r_d2, h = r_dh);
        
        translate([0,0,box_dim[1]*2/3 + tol])
            cylinder(d1 = r_d2, d2 = r_d1, h = r_dh);
        
    }
    
    
    module hinge_diff() {

        translate([-axis_ext_d*1.5,-axis_ext_d+axis_tol,box_dim[1]/3 - axis_tol])
            cube([axis_ext_d*1.5, axis_ext_d*1.5, box_dim[1]/3 + axis_tol*2]);

        translate([-axis_ext_d+axis_tol,-axis_ext_d*1.5,box_dim[1]/3 - axis_tol])
            cube([axis_ext_d*1.5, axis_ext_d*1.5, box_dim[1]/3 + axis_tol*2]);
        
        hinge(axis_tol);
        
        
    }
    

    
    module box() {

        //#translate([ext_hd,ext_hd,0])
        #union() {
     
            render()
            difference() {
            
                linear_extrude(box_dim[2])
                box_grid_shape();
                
                translate([axis_ext_d + ext_hd, ext_hd,0]) {
                    contacts(a = false);

                    rotate([0,0,-90])
                        contacts(l = 0.5);
                }
                
                translate([axis_ext_d/2,0,box_dim[2] - axis_ext_d/2])
                rotate([-90,0,0]) 
                hinge_diff();
                
                translate([axis_ext_d/2,0,box_dim[2] - axis_ext_d/2])
                difference() {
                    translate([-axis_tol - axis_ext_d/2, -axis_tol, 0])
                        cube([axis_ext_d/2 + axis_tol, box_dim[1] + axis_tol*2, axis_ext_d/2 + axis_tol]);
                    
                    translate([0,-axis_tol*2,0])
                    rotate([-90,0,0])
                    cylinder(d = axis_ext_d, h = box_dim[2] + axis_tol*4);
                }

            }
            
            
            translate([0,0,-wall_t])
            linear_extrude(wall_t)
            difference() {
                box_shape();
                
                translate([axis_ext_d + ext_hd, ext_hd,0]) {
                
                    circle(d = contact_hole_d);
                    translate([ext_sd,0])
                    circle(d = contact_hole_d);
                    
                }
            }
            
        }




    }
    
    module lid() {

        translate([axis_ext_d/2,0,box_dim[2]-axis_ext_d/2])
        rotate([0,-30,0])
        translate([-axis_ext_d/2,0,axis_ext_d/2+axis_tol]) {
        
            translate([0,0,spring_space*2])
            linear_extrude(wall_t)
            box_shape();
        
            render()
            difference() {
                linear_extrude(spring_space*2)
                box_grid_shape();
                
                translate([axis_ext_d + ext_hd, ext_hd + ext_sd*(battery_grid[1]-1),-contact_t])
                rotate([0,0,-90])
                contacts();
            }
            
            translate([axis_ext_d/2, 0, -axis_ext_d/2 - axis_tol])
            rotate([-90,0,0])
            hinge(0);
            
            translate([0,box_dim[1]/3,-axis_ext_d/2-axis_tol])
            cube([axis_ext_d, box_dim[1]/3, axis_ext_d]);
            
        }
        
    }



        //hinge();
                
        


    box();
    lid();
    //lock();
    
   

    
}

//rotate([-90,0,0])
//battery_pack();


/*
translate([-30,0,30])
rotate([90,0,0])
battery();

translate([-30,50,30])
rotate([90,0,0])
battery();

translate([-45,0,30])
rotate([90,0,0])
battery();

translate([-45,50,30])
rotate([90,0,0])
battery();

*/

