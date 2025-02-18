cd = 0.48*2;
d = 90;
bt = 0.6;

$fa = 1;
$fs = 1;

linear_extrude(bt)
circle(d = d);

module txt(t) {
    text(t, halign = "center", size = 14, font = "Cantarell");
}

translate([0,0,bt])
linear_extrude(bt)
difference() {
for (i = [1:d/cd/2])
    difference() {
        circle(d = i * cd*2 + cd);
        circle(d = i * cd*2);
    }
    
translate([0,-20])
txt("для");

translate([0,-35])
txt("Моси");
}