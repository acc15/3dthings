wire = 2.6;
turns = 16;
distance = 0.6;
pinch = 1.4;
thickness = 0.6*4;
height = 8;

$fa = 0.05;
$fs = 0.05;

module shape() {
    
    r = wire/2;
    w = distance/2;
    h = pinch/2;
    
    cut_r = (2*r*w + w*w + h*h)/(2*(r - h));
    angle = asin((r + w) / (r + cut_r));
    
    x_off = (r + w)*2;
    
    polygon(concat(
        [
            for (i = [0:turns-1]) each concat(
                arc(i == 0 ? 180 : 270-angle, 270 + angle, r, x = x_off*i, end_point = 1),
                arc(90+angle, 90-angle, cut_r, x = x_off*i + (r+w), y = -cut_r-h, end_point = 1)
            )
        ],
        arc(270-angle, 270, r, x = x_off*turns, end_point = 1),
        arc(90, -90, thickness/2, x = x_off*turns, y = -r-thickness/2),
        arc(270, 90, r + thickness),
        arc(90, -90, thickness/2, x = x_off*turns, y = r+thickness/2),
        arc(90, 90+angle, r, x = x_off*turns, end_point = 1),
        [
            for (i = [turns-1:-1:0]) each concat(
                arc(270+angle, 270-angle, cut_r, x = x_off*i + (r + w), y = cut_r+h, end_point = 1),
                arc(90-angle, i == 0 ? 180 : 90 + angle, r, x = x_off*i, end_point = 1)
            )
        ]
    ));    
}

linear_extrude(height)
shape();

/*
circle(d = wire);

translate([wire+distance,0])
circle(d = wire);*/


function steps(r, angle = 360) = ceil(
    ($fn > 0 
        ? ($fn >= 3 ? $fn : 3) 
        : max(min(360 / $fa, 2*PI*r / $fs), 5)
    ) * abs(angle) / 360
);

function arc(
    start_angle, end_angle, 
    r = 0, d = 0, 
    x = 0, y = 0, 
    start_point = 0, end_point = 0
) = let(
    radius = d > 0 ? d / 2 : r,
    total = end_angle - start_angle, 
    steps = steps(radius, total)
) [
    for (i = [start_point:steps - end_point])
        let(deg = start_angle + total * i / steps) [ 
            x + cos(deg) * radius, y + sin(deg) * radius
        ]
];

