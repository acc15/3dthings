use <threads-scad/threads.scad>;

$fa = 0.2;
$fs = 0.2;

screws = [
    [23.8, 4.75, 1.25, 60, 2],
    [20, 7, 1.814, 55, 3]
];

nut_height = 5; 

d1 = 19;
d2 = 15;
dt_height = (d1 - d2);

total_height = screws[0][1] + screws[1][1] + nut_height;

module cut_form() {

    translate([0,0,-1])
    cylinder(d = d1, h = 2);
    translate([0,0,1])
    cylinder(d1 = d1, d2 = d2, h = dt_height);
    translate([0,0,1 + dt_height])
    cylinder(d = d2, h = total_height - dt_height);

}

module converter() {
    difference() {
        union() {

            ScrewThread(screws[0][0], screws[0][1], pitch=screws[0][2], tooth_angle=screws[0][3]);

            translate([0,0,screws[0][1]])
            linear_extrude(nut_height)
            offset(screws[0][4])
            circle(d = 20, $fn = 6);
            
            translate([0,0,screws[0][1] + nut_height])
            ScrewThread(screws[1][0], screws[1][1], pitch=screws[1][2], tooth_angle=screws[1][3]);
            
        }
        cut_form();
    }
}

converter();