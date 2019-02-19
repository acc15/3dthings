include <threads.scad>


function radius_x(r) = r[0] == undef ? r : r[0];
function radius_y(r) = r[1] == undef ? r : r[1];
function ellipse_perimeter(r) = let(rx = radius_x(r), ry = radius_y(r)) 2 * PI * ((rx == ry) ? rx : sqrt((rx*rx + ry*ry) / 2));
function arc_step_count(r, a) = $fn > 0 ? a / 360 * $fn : ceil(max(min(a / $fa, ellipse_perimeter(r) / $fs), 5));
function arc_step(s, e, c) = (e - s) / c;
function arc_pt(r, a, p) = [cos(a) * radius_x(r) + p[0], sin(a) * radius_y(r) + p[1]];
function arc_loop_no_close(r, s, e, p, c) = [ for(i = [0 : c-1]) arc_pt(r, s + i * arc_step(s, e, c), p) ];
function arc_loop(r, s, e, p, c, close = true) = close 
    ? concat(arc_loop_no_close(r,s,e,p,c), [arc_pt(r, e, p)])
    : arc_loop_no_close(r,s,e,p,c);
function arc(r, s, e, p = [0,0], close = true) = arc_loop(r, s, e, p, arc_step_count(r, abs(e - s)), close);

function ngon_poly(n, r, p = [0, 0]) = arc_loop_no_close(r, 0, 360, p, n);
module ngon(n, r) 
    polygon(ngon_poly(n, r));

module arc_shape(r, s, e, thickness) {
    inner = arc(r - thickness, s, e);
    outer = arc(r, e, s);
    polygon(concat(inner, outer));
}


holder_dia = 44.7;
holder_count = 8;
holder_length = 7;
holder_angle = 360 * holder_length / (PI * holder_dia);
small_dia = 43.5;
main_dia = 58.4;


$fa = 0.1;
$fs = 0.1;




difference() {
    difference() {

        union() {
            cylinder(d = small_dia, h = 12, $fn = 128);
            cylinder(d = main_dia, h = 3, $fn = 128);

            linear_extrude(12, $fn = 128)translate([0,0,-1]) 
                for (i = [0:holder_count - 1]) {
                    st = i * 360 / holder_count - holder_angle / 2;
                    arc_shape(holder_dia / 2, st, st + holder_angle, 2); 
                }
                
        }
        
        translate([0,0,-0.1]) cylinder(d = main_dia - 4, h = 2.2);       
        metric_thread(41.5, 2.5, 14, internal = true, angle = 45, groove = true);
    }
    translate([0,0,10.5]) cylinder(d = 41.5, h = 5);
}
