
$fa = 0.2;
$fs = 0.2;


difference() {

union() {

    cylinder(r = 7, h = 8);
        
    linear_extrude(7) {
    offset(1)
    offset(-1) {
        difference() {
            circle(d = 20);

            for (i = [0:5])
            rotate(i*60)    
            translate([12,0])
                    circle(d = 10);
        }
        
    }
        translate([-0.2+0.3,0])
        square([0.4,10.2]);
        translate([-0.2-0.3,0])
        square([0.4,10.2]);
    }

}

translate([0,0,-1])
cylinder(d = 5.5,h = 10,$fn = 6);
}