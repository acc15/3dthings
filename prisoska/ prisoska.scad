
d = 25;
ed = 6;
id = 4.2;
eh = 3;
ih = 1.6;
t = 2;

cw = ed + t*2;
ch = 10;
tol = 0.1;

module cutter() {

    union() {

        translate([-tol,-ed/2, ih])
        cube([d + tol, ed, eh]);

        translate([-tol,-id/2,-tol])
        cube([d + tol, id, ih + tol]);
        
    }
        
}

/*
difference() {
    translate([0,-cw/2,0])
        cube([d * 3, cw, (ih + eh) * 2 + t]);
    
    cutter();
    translate([d*2+tol,0,0])
        cutter();
}*/

module shape() {

    //linear_extrude(ch)
    polygon([
        [0,0],
        [cw/2 - id/2, 0],
        [cw/2 - id/2, ih],
        [cw/2 - ed/2, ih],
        [cw/2 - ed/2, ih + eh],
        [cw/2 + ed/2, ih + eh],
        [cw/2 + ed/2, ih],
        [cw/2 + id/2, ih],
        [cw/2 + id/2, 0],
        [cw, 0],
        [cw, (ih + eh)*2 + t],
        [cw/2 + id/2, (ih + eh)*2 + t],
        [cw/2 + id/2, ih + eh*2 + t],
        [cw/2 + ed/2, ih + eh*2 + t],
        [cw/2 + ed/2, ih + eh + t],
        [cw/2 - ed/2, ih + eh + t],
        [cw/2 - ed/2, ih + eh*2 + t],
        [cw/2 - id/2, ih + eh*2 + t],
        [cw/2 - id/2, ih*2 + eh*2 + t],
        [0, ih*2 + eh*2 + t],
    ]);
}
linear_extrude(d + ch*2)
shape();


    

/*
hull($fn = 64) {
    cylinder(d = 25, h = 15);
    
    translate([50,0,0])
    cylinder(d = 25, h = 15);
}*/