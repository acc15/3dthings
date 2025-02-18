use <tinylib.scad>

thickness = 2;

fan_dim = [40,40];
fan_mount_fillet = 3;
fan_hole_dist = [32, 32];
fan_hole_dia = 3.8;
fan_main_dia = fan_dim[0] - thickness*2;

$fa = 1;
$fs = 0.2;

module mount() {

    linear_extrude(thickness)
    difference() {
        polygon(fillet_rect_poly(fan_dim, fan_mount_fillet, true));
        
        for (i = [0:3])
            translate(
                [
                    (i % 2 == 0 ? 1 : -1) * fan_hole_dist[0] / 2, 
                    (floor(i/2) == 0 ? 1 : -1) * fan_hole_dist[1] / 2
                ])
            circle(d = fan_hole_dia);
        
        circle(d = fan_main_dia);
    }

}

p_start = fillet_rect_poly(fan_dim, fan_dim[0]/2, true, $fn = 128);
p_end = fillet_rect_poly([20, 40], 1, true, $fn = 128);
p_steps = 128;

echo(len(p_start), len(p_end));

module interpolate_skin(start_poly, end_poly, steps, height) {
    skin([ for (i = [0:steps]) let(f = i/steps) to_3d(interpolate_poly(start_poly, end_poly, f), f*f*height) ]);
}

translate([0,0,thickness])
interpolate_skin(p_start, p_end, p_steps, 20);

mount();



//rotate_extrude(angle = 170, $fn = 6)
//square(10);


//echo(fan_dim / 2 * [10,10]);