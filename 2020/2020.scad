
$fa = 3;
$fs = 3;

rotate([-90,0,0])
rotate([0,90,0])

difference() {
rotate_extrude(angle = 45)
translate([-10,0])
rotate(90)
text("2020", font = "Ubuntu:style=Medium", size = 45, halign="left", spacing = 0.7);


for (i = [16,42,64,90])
    rotate([0,0,45])
    translate([-51,12,i])
    rotate([90,0,0])
    cylinder(d = 2, h = 20, $fn = 64);

}
