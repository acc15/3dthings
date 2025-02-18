
t = 0.8;
h = 20;

$fa = 0.1;
$fs = 0.1;

module base() {
    
    offset(10) 
    offset(-10)
    square([50, 50]);    
    
}

linear_extrude(t)
offset(t)
base();

translate([0,0,t])
linear_extrude(h)
difference() {
    offset(t)
    base();
    base();
}

