use <../bendlib/bendlib.scad>

$fa = 0.3;
$fs = 0.3;

xy_thickness = 0.48*2;
z_thickness = 0.2*5;

box_thickness = [xy_thickness,z_thickness,xy_thickness];

//box_inner_dimensions = [20, 20, 60];
box_inner_dimensions = [10,10,5];
box_outer_dimensions = box_inner_dimensions + box_thickness*2 - [0, box_thickness[1], 0];

box_handle_thickness = [xy_thickness, xy_thickness] * 1.5;

function box_handle_dimensions(outer_dim) = [
    min(box_outer_dimensions[0], 15), 
    min(z_thickness*4, outer_dim[2] / 4), 
    min(6, outer_dim[1] / 4) 
];

box_handle_positions = [0.5, 0];

shell_box_tolerance = 0.3; // distance between shell and box
shell_box_clip_distance = 0.3; // additional radius for box clip to fit inside shell (increases radius of box clip and radius of shell clip hole)
shell_box_clip_tolerance = 0.2; // additional radius for shell box clip hole (increases radius only for shell hole, box clip remains same)
shell_lock_tolerance = 0.15; // amount of offset of lock_shape between two shells
shell_shell_tolerance = 0; // additional distance between 2 shells

clip_radius = box_thickness[0] + shell_box_tolerance + shell_box_clip_distance;

shell_thickness = [xy_thickness, xy_thickness, z_thickness];
shell_inner_dimensions = box_outer_dimensions + [shell_box_tolerance*2,shell_box_tolerance*2,shell_box_tolerance];
shell_outer_dimensions = shell_inner_dimensions + shell_thickness*2 - [0,0,shell_thickness[2]];
shell_lock_dimensions = [shell_outer_dimensions[0] / 3, shell_thickness[0]*2];

// precomputed distance from shell to box
shell_box_distance = 
    [shell_lock_dimensions[1], shell_lock_dimensions[1], 0] 
    + shell_thickness 
    + bl_fill(shell_box_tolerance, len(shell_thickness));

// precomputed distance from shell to shell
shell_distance = shell_outer_dimensions 
    + [shell_lock_dimensions[1], shell_lock_dimensions[1], 0]
    + bl_fill(shell_shell_tolerance, len(shell_outer_dimensions));

function cells_dim(dim, cells) = [ for (i=[0:len(dim)-1]) (i < len(cells) ? shell_distance[i]*(cells[i]-1) : 0) + dim[i] ]; 

module clip_sphere(radius, factors) {
    dia = radius*2;
    
    translate([-(factors[1] - 0.5)*dia,0,0])
    intersection() {
        sphere(d = dia);
        translate([dia * (factors[0] - 0.5),-dia/2,-dia/2])
        cube([(factors[1] - factors[0])*dia, dia,dia]);
    }
}

module clip(lr, r = clip_radius) {
    mirror([lr,0,0])
    clip_sphere(r, [0,0.5]);
}

module box_clips(radius = clip_radius, cells = [1,1]) {   
    for (i=[0:cells[1]-1]) {
        translate([0,shell_distance[1]*i,box_outer_dimensions[2] - box_thickness[1] - clip_radius]) {
            translate([box_thickness[0], clip_radius,0])
            clip(0, radius);
            translate([box_thickness[0], box_outer_dimensions[1] - clip_radius,0])
            clip(0, radius);
            translate([shell_distance[0]*(cells[0]-1) + box_outer_dimensions[0] - box_thickness[0], box_outer_dimensions[1]*0.5,0])
            clip(1, radius);
        }
    }
}

module box_handle(box_dim = box_outer_dimensions) {
    
    handle_dim = box_handle_dimensions(box_dim);

    translate([
        (box_dim[0] - handle_dim[0])*box_handle_positions[0],
        (box_dim[1] - handle_dim[1])*box_handle_positions[1] + handle_dim[1],
        box_dim[2]
    ])
    rotate([90,0,0])
    linear_extrude(handle_dim[1])
    difference() {
        square([handle_dim[0], handle_dim[2]]);
        translate([box_handle_thickness[0],-1])
        square([handle_dim[0] - box_handle_thickness[0]*2, handle_dim[2] - box_handle_thickness[1] + 1]);
    }
    
}

module box(cells = [1,1], with_clips = true) {
    outer_dim = cells_dim(box_outer_dimensions, cells);
    inner_dim = cells_dim(box_inner_dimensions, cells);
    difference() {
        cube(outer_dim);
        translate(box_thickness)
        cube(inner_dim + [0,1,0]);
    }
    if (with_clips) {
        box_clips(clip_radius, cells);
    }
    box_handle(outer_dim);
}

module lock_shape(dim) {
    polygon([[dim[1]/2,0],[0,dim[1]],[dim[0],dim[1]],[dim[0]-dim[1]/2,0]]);
}

module shell_shape(cells = [1,1]) {
    difference() {
        union() {
            translate([shell_lock_dimensions[1], shell_lock_dimensions[1]]) {
                for (i=[1:cells[0]]) {
                    translate(cells_dim([
                        shell_outer_dimensions[0]/2-shell_lock_dimensions[0]/2, 
                        shell_outer_dimensions[1]
                    ], [i,cells[1]]))
                    lock_shape(shell_lock_dimensions);
                }
                for (j=[1:cells[1]]) {
                    translate(cells_dim([
                        shell_outer_dimensions[0], 
                        shell_lock_dimensions[0] + shell_outer_dimensions[1]/2 - shell_lock_dimensions[0]/2
                    ], [cells[0], j]))
                    rotate(-90)
                    lock_shape(shell_lock_dimensions);
                }
            }
            
            difference() {
                
                difference() {
                    square(cells_dim([shell_outer_dimensions[0] + shell_lock_dimensions[1], shell_outer_dimensions[1] + shell_lock_dimensions[1]], cells));
                    translate([shell_lock_dimensions[1] + shell_thickness[0], shell_lock_dimensions[1] + shell_thickness[1]])
                    square(cells_dim([shell_inner_dimensions[0], shell_inner_dimensions[1]], cells));
                }
                
                for (i=[1:cells[0]]) {
                    translate(cells_dim([
                        shell_lock_dimensions[1] + shell_outer_dimensions[0]/2-shell_lock_dimensions[0]/2, 
                        -shell_shell_tolerance
                    ], [i, 1]))
                    offset(shell_lock_tolerance)
                    lock_shape(shell_lock_dimensions);
                }
                
                for (j=[1:cells[1]]) {
                    translate(cells_dim([
                        -shell_shell_tolerance, 
                        shell_lock_dimensions[1] + shell_outer_dimensions[1]/2+shell_lock_dimensions[0]/2
                    ], [1, j]))
                    rotate(-90)
                    offset(shell_lock_tolerance)
                    lock_shape(shell_lock_dimensions);
                }

            }
            
        }
    }
}

module shell(cells = [1,1], with_clips = true) {
    render()
    difference() {
        union() {
            linear_extrude(shell_thickness[2])
            translate([shell_lock_dimensions[1] + shell_thickness[0],shell_lock_dimensions[1] + shell_thickness[1]])
            square(cells_dim([shell_inner_dimensions[0], shell_inner_dimensions[1]], cells));
            
            linear_extrude(shell_outer_dimensions[2])
            shell_shape(cells);
        }
        if (with_clips) {
            translate(shell_box_distance)
            box_clips(clip_radius + shell_box_clip_tolerance, cells);
        }
    }    
}
    
module box_with_shell(cells, with_clips = true, open_factor = 0) {
    translate(shell_box_distance + [0,0,open_factor*(box_outer_dimensions[2]-box_thickness[2]-shell_box_tolerance)])
    box(cells, with_clips);
    shell(cells, with_clips);
}

module box_system_demo(time) {
    
    boxes = [
        [ 0.00, [1,2], [0,0] ],
        [ 0.10, [1,1], [1,0] ],
        [ 0.20, [1,1], [1,1] ],
        [ 0.30, [2,1], [0,2] ],
        [ 0.40, [2,3], [2,0] ],
        [ 0.50, [4,1], [0,3] ],
        [ 0.60, [1,1], [4,0] ],
        [ 0.62, [1,1], [4,1] ],
        [ 0.64, [1,1], [4,2] ],
        [ 0.66, [1,1], [4,3] ],
        [ 0.68, [1,1], [4,4] ],
        [ 0.70, [1,1], [3,4] ],
        [ 0.72, [1,1], [2,4] ],
        [ 0.74, [1,1], [1,4] ],
        [ 0.76, [1,1], [0,4] ]
    ];
    
    open_factor_offsets = rands(0,180,len(boxes), 1325432);
    
    rotate([90,0,0])
    for (i = [0:len(boxes)-1]) {
        if (time > boxes[i][0]) {
            open_factor = abs(sin(time*5*180+open_factor_offsets[i]));
            translate([shell_distance[0]*boxes[i][2][0],shell_distance[1]*boxes[i][2][1]])
            box_with_shell(boxes[i][1], false, open_factor);
        }
    }

}

module print_aligned_box(cells) {
    translate([(cells[0]-1)*shell_distance[0] + box_outer_dimensions[0],0,0])
    rotate([90,0,180])
    box(cells);
}

module printable_box_with_shell(cells, distance = 5) {
    shell(cells);
    translate([(cells[0]-1)*shell_distance[0]+shell_distance[0] + distance,0,0])
    printable_box(cells);

}

module test_min_set() {
    shell([1,1]);
    
    translate([0,shell_distance[1] + 5])
    shell([1,1]);
    
    translate([shell_distance[1]+5, 0])
    print_aligned_box([1,1]);
    
}

module test_set() {

    shell([1,1]);
    
    translate([0,shell_distance[1] + 5])
    shell([1,1]);
    
    translate([0,(shell_distance[1] + 5)*2])
    shell([2,1]);
    
    translate([(shell_distance[0] + 5),0])
    shell([1,2]);
    
    translate([(shell_distance[1]+5)*2, 0])
    print_aligned_box([1,1]);
    
    translate([(shell_distance[1]+5)*2, box_outer_dimensions[2]+5])
    print_aligned_box([1,1]);
    
    translate([(shell_distance[1]+5)*2, (box_outer_dimensions[2]+5)*2])
    print_aligned_box([2,1]);
    
    translate([(shell_distance[1]+5)*2, (box_outer_dimensions[2]+5)*3])
    print_aligned_box([1,2]);
}

test_min_set();


