$fa = 0.2;
$fs = 0.2;

tolerance = 0.2;

bearing_inner_dia = 6.4 - tolerance * 2;
bearing_external_dia = 12.7;
bearing_thickness = 4.8 + tolerance * 2;
bolt_d = 2.8 + tolerance * 2;


thickness = 0.2 * 4;

module pin_shape() {
    intersection() {
        circle(d = bearing_inner_dia);
        translate([-bearing_inner_dia*0.8/2,-bearing_inner_dia/2])
        square([bearing_inner_dia*0.8, bearing_inner_dia]);
    }
}

module pin() {

    difference() {
        
        add = 8;
        
        linear_extrude(bearing_thickness + add*2)
        pin_shape();

        translate([-bearing_inner_dia/2,0,add/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = bearing_inner_dia);

        translate([-bearing_inner_dia/2,0,add+bearing_thickness+add/2])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = bearing_inner_dia);


    }

}

//rotate([0,90,0])
pin();

//cylinder(d = 6.1, h = 5);