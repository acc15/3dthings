use </home/acc15/MyProgs/bendlib/bendlib.scad>

thread_d = 12;
thread_ball_d = 2.5;
thread_pitch = 4;
thread_n = 64;

$fa = 0.4;
$fs = 0.4;

module thread_ball(i,n,p,d,bd) {
    rotate([0,0,i * 360 / n])
    translate([d/2,0,i * p / n])
        sphere(d = bd);
}

module ball_hull() {
    hull() {
        translate([-thread_ball_d*2,0,0])
            sphere(d = thread_ball_d);
        sphere(d = thread_ball_d);
    }    
}

module thread_ball_2(i, n, p, d1, d2, a1, a2, inv) {
    rotate([0,0,a1 + (i/n) * (a2 - a1)])
    translate([d1 + (inv ? 1-cos(i/n*90) : sin(i/n*90)) * (d2 - d1),0,(inv ? (sin(i/n*90)) : (1-cos(i/n*90))) * p ])
        ball_hull();
}


module thread_1(n, p, d, bd) {
    for (i = [0:n-1])    
        hull() {
            thread_ball(i, n, p, d, bd);
            thread_ball(i+1, n, p, d, bd);
        }
}

n = 20;

module diff_thread() {

    translate([0,0,-thread_pitch/2])
    for (i = [0:n-1]) 
        hull() {
            thread_ball_2(i, n, thread_pitch/2, thread_d/2, thread_d/2+thread_ball_d, 30, 0, false);
            thread_ball_2(i+1, n, thread_pitch/2, thread_d/2, thread_d/2+thread_ball_d, 30, 0, false);
        }
        
        
    for (i = [0:n-1]) 
        hull() {
            thread_ball_2(i, n,  thread_pitch/2, thread_d/2+thread_ball_d, thread_d/2, 0, -30, true);
            thread_ball_2(i+1, n, thread_pitch/2, thread_d/2+thread_ball_d, thread_d/2, 0, -30, true);
        }
    
}
    

//hull() {



//hull()

module insert() {

    insert_d = 7.8;
    insert_a = 73;

    difference() {

        union() {

            difference() {

                intersection() {
                    translate([0,0,-4])
                    cylinder(d = 22, h = 8);

                    //translate([0,0,-7.8/2])
                    rotate([0,90,0])
                    cylinder(d = 7.8, h = 22);
                
                
                }
                
                translate([0,0,-4])
                cylinder(d = 13, h = 8);
            }
            
            difference() {
                rotate([0,0,-insert_a/2])
                    rotate_extrude(angle = insert_a)
                    translate([thread_d/2+0.9,0])
                    union() {

                        translate([0, thread_pitch/2])
                        circle(d = 2);

                        translate([0, -thread_pitch/2])
                        circle(d = 2);

                        translate([-0.4,-insert_d/2])
                        square([0.8, insert_d]);

                    }
                    
                rotate([0,90,0])
                union() {
                    
                    translate([0,-insert_d - insert_d/2,-1])
                    cube([insert_d, insert_d, thread_d+2]);
                    
                    translate([-insert_d,insert_d/2,-1])
                    cube([insert_d, insert_d, thread_d+2]);
                    
                    difference() {
                    
                        union() { 
                        
                            translate([0,0,-1])
                            cube([insert_d, insert_d, thread_d+2]);
                            
                            translate([-insert_d,-insert_d,-1])
                            cube([insert_d, insert_d, thread_d+2]);
                        }
                        
                        translate([0,0,-2])
                        cylinder(d = insert_d, thread_d + 4);
                        
                    }
                    

                }
            }
            
        }
            
        diff_thread();
    }

}


module boot() {
    
    boot_d = 16;
    boot_h = 4;
    
    circle_d = thread_ball_d;//2.5boot_h - 1 - 1 - 0.4;


    difference() {

        union() {
        
            linear_extrude(boot_h)
            difference() {
                circle(d = boot_d);
                circle(d = thread_d);
            }
            
            difference() {
                for (i = [-1:1])
                    translate([0,0,i*thread_pitch])
                        thread_1(thread_n, thread_pitch, thread_d, 1.6);
                
                translate([0,0,-10])
                cylinder(d = thread_d*2, h = 10);
                
                translate([0,0,thread_pitch])
                cylinder(d = thread_d*2, h = 10);
            }
            
        }

        translate([0,0,circle_d/2 + (boot_h - 0.4 - circle_d)/2])
        rotate_extrude()
        translate([boot_d/2, 0])
        circle(d = circle_d);
    }
    
}

boot();



