
angle = 45;
radius = 20;

//difference() {

translate([0,0,0])
rotate([-90+angle,0,0])
rotate([0,270,0])
rotate_extrude(angle = angle, $fn = 128)
translate([radius, 0])
rotate(-90)
text("51", font = "Hack:style=Bold", size = 30, halign = "left", valign = "bottom");


/*
translate([0,0,12])
cube([100,100,100]);
}
*/
