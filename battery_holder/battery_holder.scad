$fa = 0.5;
$fs = 0.5;

function closest_dim(dim, full_dim) = dim*floor(full_dim / dim);

// print extrusion width
e_w = 0.48;

// battery length
bg_l = 66 + 0.4;

// battery diameter
bg_d = 18.5 + 0.4;

// battery plus length
bg_pl = 1.25;

// battery plus diameter
bg_pd = 6;

// battery minus diameter
bg_md = 12;

// tape width 
t_w = 8+1;

// tape thickness
t_t = 0.6;

// wall thickness
t = e_w*3;


module battery() {
    color("yellow") difference() {
        cylinder(d=bg_d,h=bg_l);
        translate([0,0,-1])
        cylinder(d = bg_md, h=2);
    }
    color("gray") cylinder(d=bg_md,h=1);
    color("gray") translate([0,0,bg_l-1]) cylinder(d=bg_pd,h=bg_pl+1);
}


module holder_v1() {
    
    module contact(pole=+1) {
        translate([-t*2,0,0])
        rotate([0,90,0])
        union() {
        
            difference() {
           
                union() {
                    *difference() {
                        translate([t/2,0,3*t/2])
                        cube([bg_d+t,bg_d,3*t], center=true);
                        
    //                    translate([bg_d/2+t,-5,-1])
    //                    cube([10,10,3*t+2]);
                    }
                    
                    cylinder(d=bg_d+t*2, h = 3*t);
                    translate([0,-t_w/2,0])
                    cube([bg_d/2+t,t_w,3*t]);
                }
                
                translate([0,0,3*t])
                scale([1,1,4*t/(bg_d+t*2)])
                sphere(d = bg_d+t*2);
                

                translate([0, t_w/2+t, -1])
                cube([t_w, t/2, 3*t+2], true);
                
                translate([0, -t_w/2-t, -1])
                cube([t_w, t/2, 3*t+2], true);
                

            }
            
            c_h = t*2 - (pole > 0 ? bg_pl : 0) ;
            
            translate([0,0,c_h/2])
            cube([t_w,t_w,c_h],true);

            translate([t_w/2,t_w/2,0])
            rotate([90,0,0])
            linear_extrude(t_w)
            polygon([[0,0],[c_h,0],[0,c_h]]);
            
        }

    }

    translate([0,-t_w/2,-bg_d/2-t])
    cube([bg_l,t_w,t]);

    translate([0,0,0])
    contact(-1);

    translate([bg_l,0,0])
    mirror([1,0,0])
    contact(+1);
    
}


module holder_mini() {
    
    // holder width
    h_w = t_w+t*2;
    
    // positive pole wall thickness
    p_t = closest_dim(e_w, bg_pl);
    
    // pole length
    p_l = t + t_t + p_t;
    
    // box length
    b_l = bg_l + p_l * 2;
    
    
    difference() {
    
        union() {
        
            difference() {
                translate([-p_l,-h_w/2,-bg_d/2-t])
                cube([b_l,h_w,bg_d+t*2]);

                translate([-t_t-p_t,-h_w/2-1,-bg_d/2])
                cube([b_l - t*2,h_w+2,bg_d]);
            }
            
            // minus pole
            translate([-p_l,-h_w/2,-h_w/2])
            cube([p_l, h_w, h_w]);
            sphere(r=1, $fn=32);
            
            // plus pole
            translate([bg_l,-h_w/2,-h_w/2])
            cube([p_l, h_w, h_w]);
                  
            
        }
     
     
        // minus pole
        translate([-p_l-1,-t_w/2,t_w/2-t_t])
        cube([p_l+2, t_w, t_t]);
        
        translate([-p_l-1,-t_w/2,-t_w/2])
        cube([p_l+2, t_w, t_t]);
        

        // plus pole
        translate([bg_l-1,0,0])
        rotate([0,90,0])
        cylinder(d = bg_pd + 0.4, h = p_t + t_t + 1);
        
        translate([bg_l+p_t,-h_w/2-1,-t_w/2])
        cube([t_t, h_w+2, t_w]);
        


        
    }
    
}


*translate([0,0,0])
rotate([0,90,0])
battery();

//rotate([90,0,0])
holder_mini();


