$fa=0.2;
$fs=0.2;

module main_shape() {
    difference() {
        union() {
            square([96,9.5]);
            translate([(96-30)/2,0])
            square([30,108]);
        }

        translate([96/2,108-16-12.5/2])
        circle(d = 12.5);
    }
}

difference() {

    union() {
        

        linear_extrude(5)
        main_shape();


        translate([0,0,5])
        linear_extrude(1)
        difference() {
            main_shape();
            translate([96/2,10])
            rotate(90)
            text("Мосе от Мурзи", size = 7, valign="center");
        }
        
    }
    
    translate([-1, 9.5/2, 6/2])
    rotate([0,90,0])
    cylinder(d = 2.7,h=11);
    
    translate([96-10, 9.5/2, 6/2])
    rotate([0,90,0])
    cylinder(d = 2.7,h=11);
    
}