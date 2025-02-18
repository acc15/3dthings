
grid = [
    [1.0, 0], 
    [1.5, 0],
    [2.0, 0],
];

$fa = 0.1;
$fs = 0.1;

d = 5;
h = 10;
t = 1;
w = 20;


cube([w, d, t]);

translate([d/2, d/2, t])
cylinder(d = d, h = h);

translate([w-d/2, d/2, t])
cylinder(d = d, h = h);

/*
translate([d, w - d, t])
cylinder(d = d, h = h);

translate([w-d, w - d, t])
cylinder(d = d, h = h);*/