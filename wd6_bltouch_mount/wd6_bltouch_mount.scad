

module bltouch() {
    translate([0,0,bltouch_h])
    rotate([180,0,180])
    import("bltouch.stl");
    
}


/*
translate([0,0,27])
cube([32, 35, 6]);

//import("WanhoaD6Bltouch.stl");

cylinder(d = 3, h = 5);
translate([24,0,0])
cylinder(d = 3, h = 5);*/




//linear_exx

module hole_hull() {
    hull() {
        circle(d = hole_dia);
        translate([0, bolt_offset])
            circle(d = hole_dia);
    }
}

off = 6;
hole_dist = 24;
head_dia = 6;
hole_dia = 3.4;
bolt_offset = 0;
fillet = 3;
t = 0.48*7;

mx = hole_dist+off*2;
my = bolt_offset + off*2;

bx = 26;
bl = 12;
b_hole_dist = 18;
w_hole_x = 12;
w_hole_y = 5;

bolt_length = 11 + 3; // 3mm head

bltouch_h = 36.3 + 5.5 + 3;
mount_h = 58 - t - my/2;

$fa = 0.1;
$fs = 0.1;




module bolt_shape(dist = 0) {
    union() {
        //hull() {
            translate([0,0,t])
                cylinder(d = head_dia, h = bl + off + 1);
            /*translate([0,-dist,t])
                cylinder(d = head_dia, h = bl + off + 1);
        }*/
        //hull() {
            translate([0,0,-1])
                cylinder(d = hole_dia, h = t + 2);
            /*translate([0,-dist,-1])
                cylinder(d = hole_dia, h = t + 2);
        }*/
    }
}

translate([0,0,58 - t - my/2]) 
union() {
    
    //difference() {
    
        //hull() {
        
        translate([0,t,t])
        rotate([90,0,0])
        linear_extrude(t)
        difference() {
            union() {

                translate([0, bolt_offset + off*2 - fillet*3]) 
                offset(fillet)
                offset(-fillet)
                square([hole_dist+off*2, fillet*3]);

                square([hole_dist+off*2, bolt_offset + off*2 - fillet]);

            }
            translate([off, off])
            hole_hull();
            
            translate([off + hole_dist, off])
            hole_hull();

        }

        linear_extrude(t)
        difference() {

            hull() {
            square([mx, t]);
            translate([(mx - bx)/2,0])
            offset(fillet)
            offset(-fillet)
            square([bx, bl + off + t]);
            }

            translate([mx / 2 - b_hole_dist/2, (bl / 2) + off + t]) {
                circle(d = hole_dia);
                
                translate([b_hole_dist,0])
                circle(d = hole_dia);
            }
            
            translate([0,t+w_hole_y/2])
            hull() {
            translate([mx/2 - w_hole_x/2,0])
            circle(d = w_hole_y);
            
            translate([mx/2 + w_hole_x/2,0])
            circle(d = w_hole_y);
            }

        }
            
        //}
        
        /*

        translate([off, 0, t + off + bolt_offset])
        rotate([-90,0,0])
        bolt_shape();
        
        translate([off + hole_dist, 0, t + off + bolt_offset])
        rotate([-90,0,0])
        bolt_shape();

        
        translate([mx/2 - b_hole_dist/2, (bl / 2) + off + t, 0])
        bolt_shape();
        
        translate([mx/2 + b_hole_dist/2, (bl / 2) + off + t, 0])
        bolt_shape();
        
        translate([mx/2 - w_hole_x/2,t+w_hole_y/2,-1])
        hull() {
            cylinder(d = w_hole_y, h = my + t + 2);
            translate([w_hole_x,0,0])
            cylinder(d = w_hole_y, h = my + t + 2);
        }*/
        
    //}
}

echo(bltouch_h = bltouch_h, mount_h = mount_h, h_dist = mount_h - bltouch_h);

*translate([mx/2,bl/2 + t + off,0])
bltouch();
