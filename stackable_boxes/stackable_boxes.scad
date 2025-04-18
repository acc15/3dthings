$fa = 0.2;
$fs = 0.2;

box_thickness = 0.4*2;
tolerance = 0.2;
container_thickness = 0.4*2;

inner_box_dimensions = [2.5*8, 65, 2.5*8];
clip_distance = 5;
clip_dia = 4;

module clip(d, s, e) {

    translate([s < 0.5 ? (0.5-e)*d : 0, 0, 0])
    intersection() {
        sphere(d = d);
        translate([d * (s - 0.5),-d/2,-d/2])
        cube([d*(e-s),d,d]);
    }
}

module box() {
    difference() {
        cube([
            inner_box_dimensions[0] + box_thickness * 2, 
            inner_box_dimensions[1] + box_thickness*2,
            inner_box_dimensions[2] + box_thickness
        ]);
        translate([box_thickness, box_thickness, box_thickness])
        cube([
            inner_box_dimensions[0], 
            inner_box_dimensions[1],
            inner_box_dimensions[2] + 1
        ]);
    }
    translate([0,box_thickness + clip_distance,box_thickness + inner_box_dimensions[2]/2])
    clip(clip_dia, 0.8, 1);
    
}

 box();

