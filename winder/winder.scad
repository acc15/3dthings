$fa = 0.2;
$fs = 0.2;

tolerance = 0.2;

bearing_inner_dia = 6.4 - tolerance;
bearing_ext_dia = 12.7 + tolerance * 2;
bearing_thickness = 6 + tolerance * 2;
bolt_d = 4;//2 + tolerance * 2;

pin_space = 8;
handle_base_length = 25;
handle_length = 25;
handle_dia = 12;

rack_height = 60;
rack_length = 50;


xy_thickness = 0.48 * 3;
z_thickness = 0.2 * 4;

module pin_shape(dia = bearing_inner_dia, cut = true) {
    cut_mult = 0.7;
    
    intersection() {
        circle(d = dia);
        
        translate([-dia*cut_mult/2,-dia/2])
        square([dia*(cut ? cut_mult : 1), dia]);
        
    }
}


module pin_hole() {
    difference() {
        linear_extrude(pin_space)
        pin_shape();
        translate([-bearing_inner_dia / 2 - tolerance, 0, pin_space/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = bearing_inner_dia + tolerance*2);
    }
}

module pin() {

    pin_hole();
    translate([0,0,pin_space])
    linear_extrude(bearing_thickness)
    pin_shape(cut = false);
    
    translate([0,0,pin_space + bearing_thickness])
    pin_hole();
    

}

module handle_base() {

    inner_d = bearing_inner_dia + 0.6;
    ext_d = inner_d + xy_thickness * 2;
    height = pin_space - 2;

    module handle_shape() {
        hull() { 
            offset(xy_thickness)
            pin_shape(inner_d);
            
            translate([0,handle_base_length,0])
            circle(d = bolt_d + xy_thickness * 2);
        }
    }


    

    difference() {

        linear_extrude(height) {    
            
            difference() {
                offset(xy_thickness)
                pin_shape(inner_d);
                pin_shape(inner_d);
            }
            
            translate([0,handle_base_length,0])    
            difference() {
                circle(d = bolt_d + xy_thickness * 2);
                circle(d = bolt_d);
            }
            
            difference() {
                handle_shape();
            
                offset(-xy_thickness)
                handle_shape();
            }
        }

        translate([-ext_d/2-tolerance,0,height/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = ext_d + tolerance*2);
    
    }
    
}

module handle() {
    
    nut_d = 6 + xy_thickness * 2;
    nut_thickness = 2.5;
    
    difference() {
        union() {
            cylinder(d1 = bolt_d + xy_thickness*2, d2 = handle_dia, h = handle_length * 0.5);
            translate([0,0,handle_length*0.5])
            cylinder(d = handle_dia, h = handle_length * 0.5);
        }
        
        translate([0,0,-tolerance])
        cylinder(d = bolt_d, h = handle_length + tolerance * 2);
        
        translate([0,0,handle_length - nut_thickness * 3])
        cylinder(d = nut_d, h = nut_thickness * 3 + tolerance);
        
        
        for (i=[0:60:360])
        rotate([0,0,i])
        translate([handle_dia/2 + 2.2,0,-tolerance*2])
        
        cylinder(d = 6, h = handle_length + tolerance*4);

    }
    
}

module rack() {
    
    module rack_shape() {
        hull() {
            circle(d = bearing_ext_dia + xy_thickness * 2);
            translate([rack_height,-rack_length/2])
            square([xy_thickness, rack_length]);
        }        
    }

    thickness = bearing_thickness + z_thickness;

    
    difference() {
        
        linear_extrude(thickness)
        union() {
            difference() {
                
                ext_dia = bearing_ext_dia + xy_thickness * 2;
                
                union() {
                    circle(d = ext_dia);
                    translate([0,-xy_thickness/2])
                        square([rack_height, xy_thickness]);
                    
                    center_length = ext_dia + (rack_length - ext_dia)*0.5;
                    
                    translate([rack_height*0.5,-center_length/2])
                    square([xy_thickness, center_length]);
                }
                circle(d = bearing_ext_dia);
            }
            difference() {
                rack_shape();
                offset(-xy_thickness)
                rack_shape();
            }
        }
        
        translate([rack_height-tolerance,0,thickness/2]) {
            
            translate([0,-rack_length/4,0])
            rotate([0,90,0])
            cylinder(d = bolt_d, h = xy_thickness + tolerance*2);
            
            translate([0,rack_length/4,0])
            rotate([0,90,0])
            cylinder(d = bolt_d, h = xy_thickness + tolerance*2);
                
        }
        
    }
    
    
    difference() {
        cylinder(d = bearing_ext_dia + xy_thickness * 2, h = z_thickness);
        translate([0,0,-tolerance])
        cylinder(d = bearing_ext_dia - xy_thickness * 2, h = z_thickness+tolerance*2);
    }
}

module rack_base() {
    
}

//rack();


//pin_shape(cut = false);
//echo(acos(0));


rotate([0,-90,0])
pin();



//handle_base();

//handle();

//cylinder(d = 6.1, h = 5);