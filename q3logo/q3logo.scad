
$fa = 1;
$fs = 1;

tolerance = 0.15;

module d() {
    scale(3)
    translate([-18,-28])
    difference() {
        import("Quake_III_Arena_Logo.svg");
        square( [100, 28]);
    }
        
}

module magnet() {

    separator_off = 2;
    separator_t = 1;
    logo_t = 4;
    magnet_d = 5;
    magnet_h = 3;

    color("white")
    linear_extrude(magnet_h)
    difference() {
        offset(separator_off)
        d();
        
        translate([50, 30])
            circle(d = magnet_d + tolerance*2);
        
        translate([50, 60])
            circle(d = magnet_d + tolerance*2);
        
        translate([11, 55])
            circle(d = magnet_d + tolerance*2);
        
        translate([90, 55])
            circle(d = magnet_d + tolerance*2);
        
    }

    color("white")
    translate([0,0,magnet_h])
    linear_extrude(separator_t)
    offset(separator_off)
    d();

    color("red")
    translate([0,0,magnet_h+separator_t])
    linear_extrude(logo_t)
    d();

}

module silicone_form(lid = false) {
    
    d = 100;
    base_h = 1;
    logo_h = 3;
    wall_t = 2;
    top_h = 2;
    lid_h = 4;
    
    if (lid) {
        
        linear_extrude(base_h)
        circle(d = d + tolerance*2 + wall_t*2);
        
        translate([0,0,base_h])
        linear_extrude(lid_h)
        difference() {    
            circle(d = d + tolerance*2 + wall_t*2);
            circle(d = d + tolerance*2);
        }
        
        
    } else {
    
        linear_extrude(base_h)
        circle(d = d);
        
        translate([0,0,base_h])
        linear_extrude(logo_h)
        difference() {
            circle(d = d);
            translate([-50.5,-45])
            d();
        }
        
        translate([0,0,base_h+logo_h])
        linear_extrude(top_h)
        difference() {
            circle(d = d);
            circle(d = d - wall_t*2);
        }
        
    }
    
}

silicone_form(false);

