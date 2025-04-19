$fa = 0.2;
$fs = 0.2;

tolerance = 0.2;

box_inner_dimensions = [2.5*8, 65, 2.5*8];
box_thickness = [0.48*2, 0.48*2, 0.2*5];
box_outer_dimensions = box_inner_dimensions + box_thickness + [box_thickness[0], box_thickness[1], 0];

clip_dia = 4;

echo(box_inner_dimensions = box_inner_dimensions);

module box() {
    difference() {
        cube(box_outer_dimensions);
        translate(box_thickness)
        cube(box_inner_dimensions + [0,0,1]);
    }
}

module clip(dia, factors) {
    translate([factors[0] < 0.5 ? 0 : 0,0,0])
    intersection() {
        sphere(d = dia);
        #translate([dia * (factors[0] - 0.5),-dia/2,-dia/2])
        cube([(factors[1] - factors[0])*dia, clip_dia,clip_dia]);
    }
}

clip(4, [0.5,1]);


*box();

