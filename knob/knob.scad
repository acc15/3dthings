
$fa = 0.2;
$fs = 0.2;

module knob(i, h) {
linear_extrude(h)
offset(i)
difference()  {
circle(d = 28);
for (i=[0:5]) 
    rotate(i*60)
    translate([20,0])
        circle(d = 20);
}
}

difference() {
    union() {
        /*
        n = 10;
        h = 2;
        for (i = [0:n]) {
            
            translate([0,0,i/n*h])
            knob(sin(i/n*90)*h, 10 - (i/n)*2*h);

        }*/
        
        for (i = [0:5])
            translate([0,0,0.2*i])
                knob(0.2*i, 10-0.4*i);
        
        cylinder(d = 20, h = 25);
        
        translate([-0.5,0.25,1])
        cube([1, 15, 8]);
        translate([-2,-1,1])
        cube([1, 15, 8]);
        translate([1,-1,1])
        cube([1, 15, 8]);
        
    }

    translate([0,0,-1])
    cylinder(d = 3.2, h = 30);

    translate([0,0,25 - 8.2])
    cylinder(d = 5.3, h = 8.3, $fn = 6);
}


//knob(0, 10);