
$fa = 2;
$fs = 0.1;

t = 1.9;
id1 = 118.4;
ir1 = id1 / 2;
er1 = ir1 + t;

ed2 = 125;
er2 = ed2 / 2;
ir2 = er2 - t;

h1 = 20;
h2 = 20;

h3 = 10;

function arc(r, s, e, p, n) = [for (i = [0:n]) let(a = s + (e - s) / n * i) [cos(a) * r + p[0], sin(a) * r + p[1]] ];

//echo(arc(5, 0, 180, [10,5], 90));


rotate_extrude()
polygon([ [ir1, 0], [er1, 0], [er1, h1], [ er2, h1 + h3 - t*2 ], [ er2 + t, h1 + h3 ], [er2, h1 + h3 ], [ er2, h1 + h2 + h3 ], [ir2, h1 + h2 + h3], [ir2, h1 + h3], [ir1, h1] ]);



/*
difference() {
    cylinder(d = ed2, h = 5);
    
    translate([0,0,-0.1])
        cylinder(d = ed2 - t*2, h = 5.2);
}*/