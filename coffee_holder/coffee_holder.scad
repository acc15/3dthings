shape_d = 70;
shape_h = 0.5;
shape_brim = 5;
tolerance = 0.2;

layer_h = 0.25;

wall_t = 0.48 * 4;
wall_h = layer_h * 4;

form_d = shape_d + tolerance*2 + wall_t*2;
form_h = wall_h + shape_h + layer_h * 2;

$fs = 0.2;
$fa = 0.2;


//translate([0,0,wall_h + tolerance])

module cut_shape() {
    union() {
        difference() {
            union() {
                circle(d = shape_d + tolerance*2);
                translate([-15-tolerance, -50])
                offset(5)
                offset(-5)
                square([30+tolerance*2, 100]);
            }

            translate([-shape_d/2 - tolerance,0])
            square([shape_d+tolerance*4, 50+tolerance]);
        }
        translate([-shape_d/2 - tolerance,0])
        square([shape_d+tolerance*2, 10]);
    }
}

module main_shape() {
    difference() {       
        union() {
            offset(wall_t)
            cut_shape();
        
            translate([-15-tolerance-wall_t, -100 - shape_d/2])
            offset(5)
            offset(-5)
            square([30 + tolerance*2 + wall_t*2, 100]);
        }
        circle(d=shape_d-shape_brim*2-tolerance*2);
        
        translate([-shape_d/2 + shape_brim + tolerance, 0])
        square([shape_d-shape_brim*2-tolerance*2, shape_d]);
        
        translate([-shape_d/2-wall_t-tolerance,10])
        square([shape_d+wall_t*2+tolerance*2, shape_d]);
    }
}


difference() {
    linear_extrude(wall_h * 2 + shape_h + tolerance*2)
    main_shape();
    
    translate([0,0,wall_h])
    linear_extrude(shape_h + tolerance*2)
    cut_shape();
}

/*

module form_shape() {
    polygon([
        [0,0], 
        [wall_t + tolerance + shape_brim, 0], 
        [wall_t + tolerance + shape_brim, wall_h],
        [wall_t, wall_h],
        [wall_t, wall_h + shape_h + tolerance*2],
        [wall_t + tolerance + shape_brim, wall_h + shape_h + tolerance*2],
        [wall_t + tolerance + shape_brim, wall_h*2 + shape_h + tolerance*2],
        [0, wall_h*2 + shape_h + tolerance*2]
    ]);
}


rotate_extrude(angle = 180)
translate([-shape_d/2-wall_t - tolerance,0])
form_shape();*/