d_inner = 4.4;
d_outer = d_inner+0.6*8;
distance = 0;

$fa = 0.4;
$fs = 0.4;

variants = [
    [0.2,0.2,0.2,0.2,0.2],
    [0.4,0.4,0.4,0.4,0.4],
    [0.6,0.6,0.6,0.6,0.6],
    [0.8,0.8,0.8,0.8,0.8],
    [1.0,1.0,1.0,1.0,1.0],
    [1.2,1.2,1.2,1.2,1.2]
];

module p(h) {
    linear_extrude(h)
    difference() {
        circle(d = d_outer);
        circle(d = d_inner);
    }
}

for(y = [0:len(variants)-1]) {
    v = variants[y];
    for (x = [0:len(v)-1]) {
        translate([x * (distance + d_outer), y * (distance + d_outer), 0])
            p(v[x]);
    }
}

