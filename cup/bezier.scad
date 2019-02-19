


function radius_x(r) = r[0] == undef ? r : r[0];
function radius_y(r) = r[1] == undef ? r : r[1];
function ellipse_perimeter(r) = let(rx = radius_x(r), ry = radius_y(r)) 
    2 * PI * ((rx == ry) ? rx : sqrt((rx*rx + ry*ry) / 2));
function arc_step_count(r, a) = $fn > 0 ? $fn : ceil(max(min(a / $fa, ellipse_perimeter(r) / $fs), 5));
function arc_pt(r, a, p) = [cos(a) * radius_x(r) + p[0], sin(a) * radius_y(r) + p[1]];
function arc_loop(r, s, e, p, c, last = true) = [ for(i = [0 : last ? c : c - 1]) arc_pt(r, s + i * (e - s) / c, p) ];
function arc(r, s, e, p = [0,0], last = true) = arc_loop(r, s, e, p, arc_step_count(r, abs(e - s)), last);
function ngon_poly(n, r, p = [0, 0]) = arc_loop(r, 0, 360, p, n, false);

module ngon(n, r) 
    polygon(ngon_poly(n, r));

module arc_profile(r, s, e, thickness) {
    inner = arc(r - thickness, s, e);
    outer = arc(r, e, s);
    polygon(concat(inner, outer));
}

function fac(n) = n <= 1 ? 1 : n * fac(n - 1);
function bernstein_combination(i, n) = fac(n) / (fac(i) * fac(n - i));
function bernstein_polynome(i, n, t) = bernstein_combination(i, n) * pow(t, i) * pow(1 - t, n - i);
function bezier_component(i, n, t, p) = let (b = bernstein_polynome(i, n, t)) [ for (c = p) c * b ];

function bezier_step_count() = $fn > 0 ? $fn : 12;

function bezier_point(points, t, sum = [0,0], i = 0) = let(n = len(points) - 1) 
    i > n ? sum : bezier_point(points, t, bezier_component(i, n, t, points[i]) + sum, i + 1);

function bezier_curve(points, last = true) = len(points <= 2) ? points :
    let(segments = bezier_step_count()) [ for (i = [0 : last ? segments : segments - 1]) bezier_point(points, i / segments) ];
    
module line(p1, p2, d) {   
    vec = p2 - p1;
    a = atan2(vec[1], vec[0]);
    
    l = [cos(a - 90) * d / 2, sin(a - 90) * d / 2];
    r = [cos(a + 90) * d / 2, sin(a + 90) * d / 2];
    
    polygon([
        p1 + r,
        p1 + l,
        p2 + l,
        p2 + r
    ]);
}
    
module bezier_debug_point(pt, f, d) {
    translate([pt[0],pt[1],0]) 
        % color([f, (1 - f), 0]) circle(d = d);
}

module bezier_debug_line(p1, p2, f, d) {
    % color([f, (1 - f), 0]) line(p1, p2, d);
}

module bezier_debug(points, d = 2) {
    n = len(points);
    for (i = [0:n-2]) {
        f = i / (n - 1);
        bezier_debug_point(points[i], i / (n - 1), d);
        bezier_debug_line(points[i], points[i + 1], f, d / 2);
    }
    bezier_debug_point(points[n-1], 1, d);
}
    
mug_height = 100;
mug_max_radius = 40;
mug_min_radius = 20;
mug_thickness = 1.3;

mug_bezier = [[mug_max_radius, mug_height], [mug_max_radius, 0], [mug_min_radius, 0]];

mug_handle_points = [0.1, 0.5];

mug_handle_pt = [bezier_point(mug_bezier, mug_handle_points[0]), bezier_point(mug_bezier, mug_handle_points[1])];
mug_handle_bezier = [
    mug_handle_pt[0], 
    [mug_handle_pt[0][0] + 50, mug_handle_pt[0][1]], 
    [mug_handle_pt[1][0] + 20, mug_handle_pt[1][1] + 10], 
    mug_handle_pt[1]
];

module mug_profile() {
    polygon(concat([[0,0], [0,mug_height]], bezier_curve(mug_bezier, $fn = 128)));
}

module mug_handle() {
    polygon(bezier_curve(mug_handle_bezier, $fn = 64));
}

difference() {
    union() {

        rotate_extrude($fn = 256)
        mug_profile();

        
        translate([-3,0,0])
        rotate([90,0,0])
        minkowski($fn=32) {
            linear_extrude(5, center = true)
            difference() {
                mug_handle();
                offset(-mug_thickness)
                    mug_handle();
            }
            rotate([90,0,0]) cylinder(d=(mug_thickness));
        }
        
    }

    rotate_extrude($fn = 256)
    union() {
        offset(-mug_thickness)
            mug_profile();
        translate([0, mug_thickness]) square([mug_thickness + 0.1, mug_height]);
        translate([0, mug_height - mug_thickness - 0.1]) square([mug_max_radius - mug_thickness, mug_thickness + 0.2]);
    }
}
//scale(0.5)

/*rotate_extrude($fn = 256)
difference() {
    cup_profile();
    offset(-cup_thickness)
        cup_profile();
    translate([-0.1, cup_thickness])
        square([cup_thickness + 0.2, cup_height]);
    translate([0, cup_height - cup_thickness - 0.1])
        square([cup_max_radius - cup_thickness, cup_thickness + 0.2]);

}*/

    //translate([-0.1, cup_thickness])
        //square([cup_thickness+0.1, cup_height]);

//polygon(concat([[0,0], [0,cup_height]], bezier_curve([[cup_max_radius, cup_height], [cup_max_radius, 0], [cup_min_radius, 0]])));

//bez = [[10, 10], [50, 10], [20, 100], [20, 20], [-10, 50], [-30, 100], [-40, 30], [5,10]];
//polygon(bezier_curve(bez, $fn = 128));
//bezier_debug(bez);

