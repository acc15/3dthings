
// battery length
bg_l = 66;

// battery diameter
bg_d = 18.5;

// battery plus length
bg_pl = 67.25;

// battery plus diameter
bg_pd = 6;

// battery minus diameter
bg_md = 12;

// tape width 
t_w = 8;

// wall thickness
t = 2;

// bottom plane width
f_w = 8;


$fa = 0.5;
$fs = 0.5;

module battery() {
    color("yellow") difference() {
        cylinder(d=bg_d,h=bg_l);
        translate([0,0,-1])
        cylinder(d = bg_md, bg_l/2 + 1);
        translate([0,0,bg_l/2-1])
        cylinder(d = bg_pd, bg_l/2 + 1);
    }
    color("gray") cylinder(d=bg_md,h=bg_l/2);
    color("gray") translate([0,0,bg_l/2]) cylinder(d=bg_pd,h=bg_pl-bg_l/2);
}




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
                translate([0,-f_w/2,0])
                cube([bg_d/2+t,f_w,3*t]);
            }
            
            translate([0,0,3*t])
            scale([1,1,4*t/(bg_d+t*2)])
            sphere(d = bg_d+t*2);
            

            translate([0, t_w/2+t, -1])
            cube([t_w, t/2, 3*t+2], true);
            
            translate([0, -t_w/2-t, -1])
            cube([t_w, t/2, 3*t+2], true);
            

        }
        
        c_h = t*2 - (pole > 0 ? bg_pl - bg_l : 0) ;
        
        translate([0,0,c_h/2])
        cube([t_w,t_w,c_h],true);

        translate([t_w/2,t_w/2,0])
        rotate([90,0,0])
        linear_extrude(t_w)
        polygon([[0,0],[c_h,0],[0,c_h]]);
        

        
    }

}


*translate([0,0,0])
rotate([0,90,0])
battery();

translate([0,-f_w/2,-bg_d/2-t])
cube([bg_l,f_w,t]);

translate([0,0,0])
contact(-1);

translate([bg_l,0,0])
mirror([1,0,0])
contact(+1);


