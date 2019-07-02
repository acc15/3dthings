include <threads.scad>;

d = 45;
p = 3;
h = 80;
l = 15;
t = 0.39*3;
tol = p/2;

l_f = 5;
b_f = 5;

q = 128;

function circ(r) = let(steps = $fn >= 3 ? $fn : 12) [ for (i = [0:steps-1]) let(a = i * 360 / steps) [ cos(a), sin(a), z ] * r ];



module r_cyl(d, h, f) {
    
    l = d + 2;
    
    translate([0,0,f])
    difference() {
        minkowski() {
            cylinder(d = d - f*2, h = h - f);
            sphere(r = f);
        }
        
        translate([-l/2,-l/2, h - f])
        cube([l, l, f + 1]);
    }
}

module box() {

    difference() {
        
        union() {
            
            r_cyl(d, h, b_f, $fn = q);

            translate([0,0,h - l ])
                metric_thread(diameter = d + p, pitch = p, length = l, internal = false, taper = 0, leadin = 2);
        }

        translate([0,0,t])
        r_cyl(d - t*2, h + t, b_f, $fn = q);

    }

}

module lid() {
    
    difference() {
        r_cyl(d + p + tol + t*2, l + t, l_f, $fn = q);
        
        
        /*
        translate([0,0,-t])
        cylinder(d = d + p + tol, h = l + t, $fn = q);*/
        
        translate([0,0,t])
        metric_thread(diameter = d + p + tol, pitch = p, length = l + t, internal = true, taper = 0, leadin = 2);
    }
    
}


//box();



rotate([180,0,0])
translate([0, 0, - l - t])
translate([0,0,h-l])
lid();



//cylinder(d = 20, h = 30, $fn = q);

