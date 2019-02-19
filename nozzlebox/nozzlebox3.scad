thickness = 1.92;
tolerance = 0.1;
spacing = [8, 8];
fillet = 3;

e3d_height = 7.5;
volcano_height = 16.5;

nozzle_dia = 6;
nozzle_roof = 10;

e3d_labels = [
    ["0.1", "0.2", "0.25", "0.3", "0.5"],
    ["0.4", "0.4", "0.4",  "0.4", "0.4"],
    ["0.4", "0.4", "0.4",  "0.4", "0.4"],
    ["0.5", "0.6", "0.8",  "0.8", "1.0"]
];

volcano_labels = [
    ["0.4", "0.6", "0.8", "1.0", "1.2"],
    ["0.4", "0.6", "0.8", "1.0", "1.2"],
    ["0.4", "0.6", "0.8", "1.0", "1.2"],
    ["0.4", "0.6", "0.8", "1.0", "1.2"]
];

mode = "lock";

module label(t, va = "bottom") {
    text(t, size = 4, halign = "center", valign = va, $fn = 64);    
}

e3d_grid = [len(e3d_labels[0]), len(e3d_labels)];
volcano_grid = [len(volcano_labels[0]), len(volcano_labels)];
cell_dim = [nozzle_dia+spacing[0], nozzle_dia+spacing[1]];


function nozzle_grid_dim(grid, height, dia, spacing) = [
    grid[0] * (dia + spacing[0]),
    grid[1] * (dia + spacing[1]),
    height
];

// 8.5, 5.5
module nozzle_grid(grid, height, dia, spacing) {    
    for (j = [0:grid[0] - 1], i = [0:grid[1] - 1])
        translate([j * cell_dim[0] + cell_dim[0]/2, i * cell_dim[1] + cell_dim[1]/2, 0])
            cylinder(d = dia, h = height, $fn = 32);
}


e3d_dim = nozzle_grid_dim(e3d_grid, e3d_height, nozzle_dia, spacing);
volcano_dim = nozzle_grid_dim(volcano_grid, volcano_height, nozzle_dia, spacing);

cube_dim = [max(e3d_dim[0], volcano_dim[0]), max(e3d_dim[1], volcano_dim[1]), e3d_dim[2] + thickness + volcano_dim[2]];
lock_length = cube_dim[0]/2 - thickness;

module box_shape(off = 0) {
    offset(fillet + off)
        square([cube_dim[0], cube_dim[1]]);    
}

module box_belt() {
    hull($fn = 64) {
        translate([0,0,thickness + tolerance])
        linear_extrude(thickness * 4 - tolerance * 2)
            offset(thickness + tolerance)
                box_shape();
        linear_extrude(thickness * 6)
            box_shape();        
    }
}

module box() {
    
    module lock_guide() {
        translate([0,-fillet-thickness-tolerance*3,cube_dim[2]/2])
        rotate([90,0,90]) {
            
            linear_extrude(lock_length*2+tolerance*2)
                lock_guide_shape();
            
            translate([0,0,lock_length*2 + tolerance])
            linear_extrude(thickness)
                lock_guide_shape_close();
        }
    }
    
    
    difference() {
        
        union() {
        
            linear_extrude(cube_dim[2] / 2 - thickness * 3 + tolerance, $fn = 64)
                box_shape();
        
            translate([0, 0, cube_dim[2] / 2 - thickness * 3])
            box_belt();
            
            translate([0,0,cube_dim[2] / 2 + thickness * 3 - tolerance])
            linear_extrude(cube_dim[2] / 2 - thickness * 3 + tolerance, $fn = 64)
                box_shape();
            
            lock_guide();
            
            translate([cube_dim[0], cube_dim[1], 0])
            rotate([0,0,180])
                lock_guide();
            
        }
        
        translate([0,volcano_dim[1],volcano_dim[2] - tolerance])
            rotate([180,0,0])
                nozzle_grid(volcano_grid, volcano_height, nozzle_dia, spacing);

        translate([0,0,volcano_dim[2] + thickness + tolerance])
            nozzle_grid(e3d_grid, e3d_height, nozzle_dia, spacing);
    }
    
}

module lock_tri(tol = 0) {
    //translate([/*cube_dim[0] - lock_length*2 - thickness*2*/0,-fillet-tolerance-thickness,0])
    render()
    rotate([90,0,90]) {
        
        //translate([0,0,thickness])
        
        translate([0,0,-tol])
        linear_extrude(lock_length + tol*2)
            offset(tol)
            lock_tri_shape();
        
        translate([0,0,thickness*2])
        sphere(r = thickness + tol, $fn = 64);
        
    }
}


module lid_base() {
    h = nozzle_roof + cube_dim[2]/2 - thickness*2 - tolerance;
    
    module lid_wall() {
        render()
        difference() {
            linear_extrude(h, $fn = 64)
            difference() {
                box_shape(thickness + tolerance);
                box_shape(tolerance);
            }
            
            translate([0,0,-thickness*5 + tolerance])
            box_belt();
        }
    }
    
    module lock_tri_aligned() {
        translate([0,-fillet-tolerance-thickness,-thickness*2])
            lock_tri();
    }
        
    translate([0,0,-thickness]) {
        linear_extrude(thickness, $fn = 64)
            box_shape(thickness + tolerance);
        
        translate([0,0,-h])
            lid_wall();
            
        lock_tri_aligned();
        
        translate([cube_dim[0], cube_dim[1],0])
        rotate([0,0,180])
            lock_tri_aligned();

    }
}


module lid_e3d() {
    difference() {
        lid_base();
        
        translate([cube_dim[0]/2, cube_dim[1]/2,-thickness/2 + tolerance])
        linear_extrude(thickness/2)
        text("E3D", size = 8, halign = "center", valign = "center", font = "Cantarell", $fn = 64);    
    }
}

module lid_volcano() {
    difference() {
        mirror([0,0,1])
            lid_base();

        translate([cube_dim[0]/2, cube_dim[1]/2,thickness/2 - tolerance])
        rotate([180,0,0])
        linear_extrude(thickness/2)
        text("Volcano", size = 8, halign = "center", valign = "center", font = "Cantarell", $fn = 64); 
    }
}

module lock_guide_shape() {
    h = cube_dim[2]/2;
    t = thickness;
    tol = tolerance;
    polygon([
        [tol*2, t*2 - tol],
        //[0,t*2 - tol],
        [-t-tol*2, t*2 - tol],
        [-t-tol*2, h],
        [-t*2-tol*2,h],
        [-t*2-tol*2,-h],
        [-t-tol*2, -h],
        [-t-tol*2, -t*2 + tol],
        //[0, -t/2-tol],
        [tol*2, -t*2 + tol]
    ]);
}

module lock_guide_shape_close() {
    h = cube_dim[2]/2;
    t = thickness;
    tol = tolerance;
    polygon([
        [tol*2, t*2 - tol],
        //[0,t*2 - tol],
        //[-t-tol*2, t*2 - tol],
        [-t-tol*2, h],
        [-t*2-tol*2,h],
        [-t*2-tol*2,-h],
        [-t-tol*2, -h],
        //[-t-tol*2, -t*2 + tol],
        //[0, -t/2-tol],
        [tol*2, -t*2 + tol]
    ]);
}

module lock_tri_shape() {
    b = thickness;
    polygon([
        [tolerance,b],
        [0,b],
        [-b,0],
        [0,-b],
        [tolerance,-b]
    ]);
    
}

module lock_tri_close_shape() {
    b = thickness;
    polygon([
        [tolerance,b],
        [0,b],
        [-b,0],
        [-b,-b*1.5+tolerance],
        [tolerance,-b*1.5+tolerance]
    ]);
}


module fillet(r) {
    
    offset(r)
    offset(-r)
    children();
}


module lock_handle_shape() {
    t = thickness;
    difference() {
        fillet(1, $fn = 64)
        translate([-t*3-tolerance, -cube_dim[2]/2-thickness-nozzle_roof]) {
            square([t*3+tolerance, cube_dim[2] + nozzle_roof * 2 + thickness*2]);
        }
        
        offset(tolerance, $fn = 32)
            lock_guide_shape();
    }
    /*
        
        translate([-t,-t*4.5,0])
        offset(tolerance, $fn = 32)
        lock_tri_shape();
        
        translate([-t,t*4.5,0])
        offset(tolerance, $fn = 32)
        lock_tri_shape();*/
    
    
}

module lock_icon() {
       
    module arrow() {
        l = 4;
        t = 2;
        polygon([[0,0], [l,0], [l,-1], [l*2,t/2], [l,t+1], [l,t], [0,t]]);
    }
    

    module lock(closed = true) {
        translate([closed ? 0 : -3, 0])
        difference() {
        
            translate([1,4]) {
                translate([2,3], $fn = 32)
                    circle(r = 2);
                square([4, 3]);
            }
        
            translate([2,3]) {
                translate([1,4])
                circle(r = 1, $fn = 32);
                square([2, 4]);
            }
        }
        
        square([6,4]);
    }
    
    lock(true);
    
    translate([8,6])
    arrow();
    
    translate([16,2])
    rotate(180)
    arrow();
    
    translate([20,0,0])
    lock(false);

}


module lock_handle() {
    
    difference() {
    
    linear_extrude(lock_length)    
        lock_handle_shape();
    
    lock_offset = cube_dim[2]/2 + nozzle_roof - thickness*2;
    
    translate([0,lock_offset,0])
    rotate([90,-90,180])
    lock_tri(tolerance);
    
    translate([0,-lock_offset,0])
    rotate([90,-90,180])
    lock_tri(tolerance);
        
    }
    
    /*
    color("green")
    render() {
    difference() {
        linear_extrude(lock_length)    
            lock_handle_shape();
    
        translate([-thickness,thickness*4.5,thickness*2])
            sphere(r = thickness, $fn = 64);
        translate([-thickness,-thickness*4.5,thickness*2])
            sphere(r = thickness, $fn = 64);
    }
    
        translate([-thickness*3.5,-4,lock_length / 2 - 13])
        rotate([0,-90,0])
        linear_extrude(thickness)
        lock_icon();
    
    }*/
    
}

module nozzle_label(txt) {
    
    cell_dim = [nozzle_dia + spacing[0], nozzle_dia + spacing[1]];
    
    dim = [cell_dim[0] - tolerance*2, cell_dim[1] - tolerance*2];
    
    translate([tolerance, tolerance,0])
    difference() {
        linear_extrude(thickness)
        difference() {
            fillet(fillet, $fn = 32)
                square(dim);
            translate([dim[0]/2, spacing[1]])
                circle(d = nozzle_dia + tolerance*2, $fn = 32);            
        }
        
        translate([dim[0]/2, tolerance*2, thickness/2 + tolerance])
            linear_extrude(thickness/2)
                label(txt);
        
    }

}

module lock_guide() {
    guide_length = lock_length * 2 + tolerance + thickness;
    translate([cube_dim[0] - guide_length,-fillet-tolerance,cube_dim[2]/2])
    rotate([90,0,90]) {
        linear_extrude(guide_length)
            lock_guide_shape();
        translate([0,0,guide_length - thickness])
            linear_extrude(thickness)
                lock_guide_shape_close();
    }
}

module lock_handle_aligned() {
    
    translate([cube_dim[0] - thickness*2 - tolerance,-fillet - thickness -tolerance*3,cube_dim[2]/2])
    rotate([90,0,90])
    lock_handle();
}


module label_grid(grid) {
    for (i = [0:len(grid) - 1], j = [0:len(grid[0])-1]) 
        translate([j * cell_dim[0], ((len(grid)-1) - i) * cell_dim[1] - (spacing[1] - nozzle_dia + tolerance)/2, 0])
            nozzle_label(grid[i][j]);
}


if (mode == "box") {
    box();
} else if (mode == "lock") {
    lock_handle();
} else if (mode == "lid_e3d") {
    
    translate([0,cube_dim[1],0])
    rotate([180,0,0])
    lid_e3d();
    
} else if (mode == "lid_volcano") {
    lid_volcano();
} else if (mode == "label") {
    
    label_grid(concat(e3d_labels, volcano_labels));

} else if (mode == "all") {
    
    translate([-abs($t*2-1) * lock_length,0,0]) {
        lock_handle_aligned();


        translate([cube_dim[0] + lock_length * 2, cube_dim[1],0])
        rotate([0,0,180])
        lock_handle_aligned();
    }
    
    color("lightblue", 0.3)
    box();
    
    translate([0,0,cube_dim[2]])
    label_grid(e3d_labels);
    
    translate([0,cube_dim[1],0])
    rotate([180,0,0])
    label_grid(volcano_labels);
    
    color("white",0.5)
    translate([0,0,cube_dim[2] + thickness + nozzle_roof])
        lid_e3d();
   
    color("white",0.5)
    translate([0,0,-thickness - nozzle_roof])
        lid_volcano();
    
}