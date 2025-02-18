
translate([0,-140,0])
import("wanhao_duplicator_6_fan_duct_cooling_5015-B.STL");

module h() {
    hull() {
    circle(d = 3.4);
    translate([3.5,0,0])
    circle(d = 3.4);
    }
}

//color("green")
translate([61,65.555,19.9])
linear_extrude(4, $fa = 0.1, $fs = 0.1)
difference() {
offset(2.43)
h();
h();
}


//color("green")
translate([93,65.555,19.9])
linear_extrude(4, $fa = 0.1, $fs = 0.1)
difference() {
offset(2.43)
h();
h();
}