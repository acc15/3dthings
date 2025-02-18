
ih = 10;
id = 25;
kd = 10;
t = 2;

tol = 0.2;

hd = 5;
ehd = hd + t*2;

ed = id + t * 2;

$fa = 0.2;
$fs = 0.1;



difference() {
union() {

    hull() {
        cylinder(d = ed, h = ih + t);

        translate([ed, 0, 0])
            cylinder(d = kd, h = t);           
    }
    
    translate([ed/2,0,0])
        cylinder(d = ehd + tol*2, h = ih + t);
}

    translate([ed/2,0,-tol])
        cylinder(d = hd + tol*2, h = ih + t + tol * 2);
}
