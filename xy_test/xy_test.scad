d = 30;
h = 5;
id = d/3;

$fa = 0.2;
$fs = 0.2;

echo("Outer = ", d, "Inner = ", id);

linear_extrude(h)
difference() {
    square([d,d]);
    
    translate([d/4, d/4]) {    
        circle(d = id);
            
        translate([d/2,0])
        square([id,id], center=true);
        
        translate([0,d/2])
        rotate(90/4)
        circle(d = id, $fn = 8);
        
        translate([d/2,d/2])
        rotate(0)
        circle(d = id, $fn = 6);
    }
}