
$fa = 0.2;
$fs = 0.2;

module h(d,f,i=0) {
    offset(f)
    offset(-f-i)
    circle(d = 40, $fn = 6);
}

difference() {
union() {
    difference() {

    hull() {
    translate([0,0,2])
    linear_extrude(6)
    h(40,5);

    linear_extrude(10)
    h(30,5,2);
    }

    for (i = [0:5])
        rotate([0,0,30 + 60 * i])
            translate([25,0,-1])
                cylinder(d = 20, h= 12);
    }
    cylinder(d = 12, h = 25);
    cylinder(d = 20, h = 24);
    
    for (i = [0:2]) 
        translate([14.5,0,0])
            rotate([0,0,-20 + i*20])
            translate([0,-0.5,2])
            cube([5,1,6]);
   
    
}
    translate([0,0,-1])
    cylinder(d = 3.2, h=30);

    translate([0,0,25-9])
    cylinder(d = 5.6, h = 10,$fn = 6);
}
