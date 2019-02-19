

t = 2;

fan_dim = [30,30];
fan_fillet = 5;

bolt_dia = 3.2;
bolt_offset = [4, 4];

module fillet(r) {
    offset(r)
    offset(-r)
    children();
}

function morph_poly(p1, p2, f) = let(
    l = max(len(p1), len(p2)), 
    p1 = interpolate_poly(p1, l), 
    p2 = interpolate_poly(p2, l)
) [ for (i = [0:l-1]) p1[i] * (1 - f) + p2[i] * f ];
    
function interpolate_poly(points, length) = let(l = len(points)) l == length 
    ? points : 
    [ for (i = [0:length-1]) points[floor(i / length * l)] ];
       
function to_3d(p, z = 0) = [ for (a = p) [a[0],a[1],z] ];
    
module skin_polys(polys) {
    l = max([ for (poly = polys) len(poly) ]);
    echo(l);

    // for (i = [1:len(polys)-1]) let(p1 = polys[i - 1], l), p2 = interpolate_poly(polys[i], l))
        
        
}
    
function arc(s, e, n = $fn > 3 ? $fn : 12, d = 1, r = -1, p = [0,0], c = false) = let(r = r < 0 ? d / 2 : r)
        [ for (i = [0: c ? n - 1 : n]) let(a = s + i * (e - s) / n) [cos(a) * r, sin(a) * r] ];

function sq(d, p = [0,0], c = false) = let(p = c ? -(d / 2) : p) [ 
    p + d,
    [p[0], p[1] + d[1]],
    p, 
    [p[0] + d[0], p[1]], 
];
              
        
a = arc(0,360, n = 64, r = 5, c = true);
b = sq([10,15], c = true);

//echo(equalize_poly(p, 16));
        
//for (i = [0:49]) let(f = i/50) 
    //translate([0,0,i])
    //linear_extrude(1)
        
// skin_polys([ for (i = [0:49]) let(f = i/50) to_3d(morph_poly(a, b, f), i) ]);
        
function unit(v) = v / norm(v);
function offset_line(l, off) = let(v = l[1] - l[0], ov = unit([v[1], -v[0]]) * off) [ l[0] + ov, l[1] + ov ];

function star(n, r1, r2) = let(n = n * 2) [ for (i = [0:n - 1]) let(a = i / n * 360, r = i % 2 == 0 ? r1 : r2) [ cos(a), sin(a) ] * r ];

function line_intersection(lines) = let(
    l1 = lines[0], 
    l2 = lines[1], 
    v1 = l1[0] - l1[1],
    v2 = l2[0] - l2[1],
    q1 = l1[0].x*l1[1].y - l1[0].y*l1[1].x,
    q2 = l2[0].x*l2[1].y - l2[0].y*l2[1].x,
    d = v1.x*v2.y - v1.y*v2.x
) d == 0 ? undef : [ 
(q1*v2.x - v1.x*q2) / d, 
(q1*v2.y - v1.y*q2) / d
];

function offset_poly(poly, off) = let(n = len(poly)) [ for (i = [0:n-1]) let(
    p1 = poly[i > 0 ? i - 1 : n - 1],
    p2 = poly[i],
    p3 = poly[(i + 1) % n],
    l1 = offset_line([p1, p2], off),
    l2 = offset_line([p2, p3], off),
    pt = line_intersection([l1, l2])
) pt ];


module point(p, t = 0.5) {
    
    $fn = 16;
    translate(p)
    circle(d = t);
}

module line(l, t = 0.5) {
    v = l[1] - l[0];
    n = norm(v);    
    
    
    translate(l[0])
    rotate(atan2(v[1], v[0]))
    translate([0,-t/2])
    square([n, t]);
    
    //point(l[0],t * 1.5);
    //point(l[1],t * 1.5);
}

module polyline(p, t = 0.5) {
    n = len(p);
    for (i = [0:n-1]) {
        line([p[i], p[(i + 1) % n]]);
    }
}

lines = [
    [[0,0], [10, 10]],
    [[2,5], [-2, 10]],
    [[-4,-4], [15, -5]],
    [[10,0], [15,-10]]
];

module line_intersection_demo() {
    
    n = len(lines);
    for (i = [0:n-1]) {
        l1 = lines[i];
        color([i / n, 0, 0]) {
            line(l1);
            
            if (i < n-1) {
                for (j = [i+1:n-1])
                    point(line_intersection([l1, lines[j]]), 1);
            }
        }
        
    }
    
    
}

module line_offset_demo() {
    for (l = lines) {
        color("blue")
        line(offset_line(l, 2));
        
        color("green")
        line(offset_line(l, -3));
        
        line(l);            
    }
}

module star_offset_demo() {
        
    shape = star(5, 10, 5);
    n = len(shape);

    for (i = [0:n-1]) {
        c = i / n;
        l1 = [i > 0 ? shape[i - 1] : shape[n - 1], shape[i]];
        l2 = [shape[i], shape[(i + 1) % n]];
        
        ol1 = offset_line(l1, -1);
        ol2 = offset_line(l2, -1);
        
        color([c,0,0])
            line(l2);
        
        color([0,c,0, 0.5])
            line(ol2);
        color([0,0,c])
            point(line_intersection([ol1, ol2]));
    
    }    
}

module poly_offset_demo() {
    shape = star(4, 10, 5);
    polyline(shape);
    
    polyline(offset_poly(shape, -2));
}

poly_offset_demo();




//module polymorph(src, trt, factor) {
    


module fan_mount(hole_offset, fillet) {
    
    
    difference() {
        fillet(fan_fillet)
            square(fan_dim, center=true);
    
        for (i = [0:3]) 
            rotate(i * 90)
                translate(fan_dim / 2 - bolt_offset)
                    circle(d = bolt_dia);
    }
    
    
}

//linear_extrude(t)
//fan_mount([30,30], 5, $fn = 64);