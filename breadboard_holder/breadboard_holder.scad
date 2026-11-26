use <bendlib/bendlib.scad>;

$fa = 0.3;
$fs = 0.3;

board_dim = [82, 54.5, 8.5];

board_ear_x_center = 54;
board_ear_y_distance = 4.75;

ear_width = 3.5;
ear_dim = [4, 1.5, 4.5];
ear_tolerance = 0.1;
thickness = ear_dim[1];

box_dim = board_dim + bl_2d(thickness);

module fill_square(dim) {
    vent_d = thickness;
    spacing = thickness;
    distance = spacing + vent_d;
    plane_distance = sqrt(2) * distance;
    fill_dim = dim - bl_2d(vent_d);
    count = [for (d = fill_dim) floor(d / plane_distance)];

    translate([vent_d/2, vent_d/2]) {
        for (i = [-count[1]:count[0]]) {
            off = i >= 0 ? [plane_distance*i, 0] : [0,-i*plane_distance];
            translate(off)
            hull() {
                circle(d = vent_d);
                translate(bl_2d(min(fill_dim - off)))
                circle(d = vent_d);
            }
        }
    }
}

module bottom_shape() {
    vent = 8;
    spacing = thickness;
    dim = board_dim - bl_2d(spacing);
    count = [ for (d = dim) floor(d / (vent+spacing)) ];
    grid_dim = [ for (i = [0:len(dim)-1]) dim[i] / count[i] ];

    difference() {
        square(board_dim + bl_2d(thickness*2));
        translate(bl_2d(thickness))
        for (x = [0:count[0]-1], y = [0:count[1]-1]) {
            translate(bl_mul(grid_dim, [x,y]))
                translate(bl_2d(spacing))
                    fill_square(grid_dim - bl_2d(spacing));
        }
    }
    
}

module wall() {
    difference() {
        square(board_dim + bl_2d(thickness*2));
        translate(bl_2d(thickness))
        square(bl_2d(board_dim));
    }
}

module ear_shape() {
    polygon([
        [-ear_width/2,0],
        [-ear_width/2,-thickness],
        [ear_width/2,-thickness],
        [ear_width/2,0],
        [ear_dim[0]/2,ear_dim[1]],
        [-ear_dim[0]/2,ear_dim[1]]
    ]);
}

module x_ears() {
    translate([board_dim[0]/2-board_ear_x_center/2, board_dim[1]])
    ear_shape();
    translate([board_dim[0]/2+board_ear_x_center/2, board_dim[1]])
    ear_shape();
}

module y_ears() {
    translate([0,board_ear_y_distance])
    rotate(90)
    ear_shape();
    
    translate([0,board_dim[1]/2])
    rotate(90)
    ear_shape();
    
    translate([0,board_dim[1] - board_ear_y_distance])
    rotate(90)
    ear_shape();
}

module wall_outer_ears() {
    difference() {
        wall();
        offset(ear_tolerance)
        translate(bl_2d(thickness)) {
            x_ears();
            y_ears();
        }
    }
}

module wall_ears() {
    union() {
        wall_outer_ears();
        
        offset(-ear_tolerance*2)
        translate(bl_2d(thickness)) {
            translate([0,-board_dim[1]])
            x_ears();
            
            translate([board_dim[0],0])
            y_ears();
        }
    }
}


module holder() {    
    linear_extrude(thickness)
    bottom_shape();

    translate([0,0,0])
    linear_extrude(ear_dim[2]+thickness)
    wall_ears();

    translate([0,0,ear_dim[2]+thickness])
    linear_extrude(board_dim[2]-ear_dim[2])
    wall_outer_ears();
}

//wall_outer_ears();

holder();