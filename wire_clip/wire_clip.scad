
wire_count = 5;
wire_d = 1;
wire_dist = 0;
l = 10;
t = 0.8;

$fa = 0.1;
$fs = 0.1;

width = wire_count*(wire_d+wire_dist);

linear_extrude(l)
difference() {

hull() {
circle(d = wire_d + t*2);

translate([width,0])
circle(d = wire_d + t*2);
}


hull() {
translate([(wire_d + wire_dist)*wire_count,0])
circle(d = wire_d);

//translate([(wire_d + wire_dist)*wire_count,0])
circle(d = wire_d);
}

translate([width,0])
rotate(45)
square([wire_d/3,wire_d*2]);

}

