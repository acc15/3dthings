*rotate([90,0,0])
import("Back_Center.stl");


*#translate([0,0,-3])
rotate([90,0,0])
import("Corner-3.stl");




*rotate([-90,0,0])
import("Corner-Tiny.stl");


$fa = 0.1;
$fs = 0.1;

t = 1.92;

module spool_holder_cap() {

    hole_d = 34;
    hex_d = 36.75;

    translate([0,0,4])
    linear_extrude(6)
    difference() {
        circle(d = hole_d);
        circle(d = hole_d - t * 2);
    }

    linear_extrude(4)
    offset(8)
    offset(-8)
    circle(d = hex_d * 2/sqrt(3), $fn = 6);
    
}

module cap_with_wire(width, height, thickness, h1, h2, d, off, outline, fillet) {
    
    module circle_hull() {
        translate([-off,0])
        hull() {
            circle(d = d);
            
            translate([-width-off,0])
            circle(d = d);
        }        
    }

    module base() {
        offset(fillet)
        offset(-fillet)
        square([width, height], center = true);
    }
    
    module base2() {
        difference() {
            base();
            circle_hull();
        }
    }
    
    linear_extrude(h1)
    difference() {
        offset(delta = outline)
        base();
        circle_hull();
    }
    
    translate([0,0,h1])
    linear_extrude(h2)
    difference() {
        base2();
        offset(-thickness)
        base2();
    }
    
}

module limiter_cap() {
    cap_with_wire(9.2, 19.2, t, 2, 5, 8, 4.5, 2.5, 3);    
}

module bed_wire_cap() {
    cap_with_wire(14.4, 34, t, 2, 5, 12, 4, 2.5, 3);
}

//limiter_cap();

//bed_wire_cap();


spool_holder_cap();