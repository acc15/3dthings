

distance = 32;

y_distance = 14.5;
x_distance = sqrt(distance*distance - y_distance*y_distance);

$fa = 1;
$fs = 0.5;

linear_extrude()
difference() {
circle(d = 45);

translate([x_distance/2, y_distance/2])
circle(d = 3.5);

translate([x_distance/2, -y_distance/2])
circle(d = 3.5);

translate([-x_distance/2, y_distance/2])
circle(d = 3.5);

translate([-x_distance/2, -y_distance/2])
circle(d = 3.5);
    
translate([-45/2,y_distance/2 + 5])
square([45, 45]);
    
translate([-45/2,-y_distance/2 - 5 - 45])
square([45, 45]);
    
circle(d = 16);
    
}