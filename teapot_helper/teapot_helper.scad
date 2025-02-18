
use <bendlib.scad>

inner_d = 45;
ext_d = 100;
handle_d = 15;
handle_hole_d = 10;
t = 0.48*2;
h = 50;

$fa = 0.5;
$fs = 0.5;

shape = concat([[ext_d/2,0]], bl_bezier([[ext_d/2,t], [inner_d/2,0], [inner_d/2,h]], $fn = 50));
offset_shape = concat([[inner_d/2 - t, h]], bl_reverse(bl_sub(bl_offset_poly(shape, -t), 25, -1)), [[(inner_d + ext_d)/4, 0]], [[ext_d/2, 0]]);

rotate_extrude($fn = 200)
polygon(concat(
   shape
   , offset_shape
   ));
  
linear_extrude(t) 
difference() {
   
hull() {   
translate([ext_d/2+handle_d/2,0])
circle(d = handle_d);
translate([(inner_d+ext_d)/4,-handle_d/2])
square([1, handle_d]);
}

translate([ext_d/2+handle_d/2,0])
circle(d = handle_hole_d);
}

//echo(bl_offset_poly([[0,0], [10,10]], 5));