//#import("/home/acc15/Downloads/SHB_nut.stl");


dc = 33.7;
hc = 3;

dn = 42.724;
hn = 4.2;


fn = 8;

$fs = 0.2;
$fa = 0.2;


linear_extrude(4.2)
offset(fn)
offset(-fn)
circle(d = dn, $fn = 6);

translate([0,0,hn])
cylinder(d = dc, h = hc);