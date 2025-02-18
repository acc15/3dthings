
// steps = fps * 60 / rpm

rotate([0,0,$t * 360]) {

#cylinder(d = 150, h = 3);

translate([0,0,3])
linear_extrude(4)
text("hello world!!!", halign = "center", valign = "center");
}