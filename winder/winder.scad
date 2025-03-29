$fa = 0.2;
$fs = 0.2;

tolerance = 0.2;

bearing_inner_dia = 6.4 - tolerance * 2;
bearing_external_dia = 12.7;
bearing_thickness = 4.8 + tolerance * 2;
bolt_d = 2.8 + tolerance * 2;

pin_space = 5;
handle_length = 50;

xy_thickness = 0.48 * 3;
z_thickness = 0.2 * 4;

module pin_shape(dia = bearing_inner_dia) {
    intersection() {
        circle(d = dia);
        translate([-dia*0.8/2,-dia/2])
        square([dia*0.8, dia]);
    }
}

module pin() {

    difference() {
        
        
        linear_extrude(bearing_thickness + pin_space*2)
        pin_shape();

        translate([-bearing_inner_dia/2,0,pin_space/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = bearing_inner_dia);

        translate([-bearing_inner_dia/2,0,pin_space+bearing_thickness+pin_space/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = bearing_inner_dia);

    }

}

module handle_base() {

    inner_d = bearing_inner_dia + 0.6;
    ext_d = inner_d + xy_thickness * 2;

    module handle_shape() {
        hull() { 
            circle(d = ext_d);
            translate([0,50,0])
            circle(d = bolt_d + xy_thickness * 2);
        }
    }
    
    difference() {

        linear_extrude(pin_space) {    
            translate([0,handle_length,0])    
            difference() {
                circle(d = bolt_d + xy_thickness * 2);
                circle(d = bolt_d);
            }
            
            difference() {
                handle_shape();
            
                offset(-xy_thickness)
                handle_shape();
            }
            
            difference() {
                circle(d = ext_d);
                pin_shape(inner_d);
            }
            
        }

        translate([-ext_d/2-tolerance,0,pin_space/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = ext_d + tolerance*2);
    
    }
    
}

module handle() {

    linear_extrude(z_thickness * 3)
    difference() {
        circle(d = bolt_d + xy_thickness*2);
        circle(d = bolt_d);
    }

}




//rotate([0,90,0])
//pin();

//handle_base();

handle();

//cylinder(d = 6.1, h = 5);