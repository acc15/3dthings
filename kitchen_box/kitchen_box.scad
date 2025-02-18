use <threads-library-by-cuiso-v1.scad>


x_cells = 7;
y_cells = 5;
z_cells = 2;
cell_spacing = 15;

lattice_width = 8;
lattice_thickness = 4;
lattice_fillet = 5;

tolerance = 0.2;

$fa = 0.5;
$fs = 0.5;


box_dim = [
    x_cells * cell_spacing + (x_cells - 1) * lattice_width,
    y_cells * cell_spacing + (y_cells - 1) * lattice_width,
    z_cells * cell_spacing + (z_cells - 1) * lattice_width
];


module inner_shape(dim) {
    translate([lattice_fillet, lattice_fillet])
    offset(lattice_fillet)
    square([dim[0] - lattice_fillet*2, dim[1] - lattice_fillet]);          
}

module outer_shape(dim) {
    translate([lattice_thickness, lattice_thickness])
    difference() {

        offset(delta = lattice_thickness)
        inner_shape(dim);

        inner_shape(dim);    
        
        translate([-lattice_thickness-tolerance, dim[1]])
        square([dim[0] + lattice_thickness*2 + tolerance*2, lattice_fillet + lattice_thickness + tolerance]);
    }
}

module inner_skirt_shape(dim) {
    
    translate([lattice_fillet, lattice_fillet])
    offset(lattice_fillet)
    square([dim[0] - lattice_fillet*2, dim[1] - lattice_fillet*2]);
    
}

module skirt_shape(dim) {
    
    linear_extrude(lattice_width)
    translate([lattice_thickness, lattice_thickness])
    difference() {
        offset(lattice_thickness)
            inner_skirt_shape(dim);
        inner_skirt_shape(dim);
    }
}

module lattice_box() {

    //inner_shape([box_dim[0], box_dim[2]]);
    for (i = [1:y_cells-1])
    translate([0,lattice_thickness + (lattice_width + cell_spacing)*i,0])
    rotate([90,0,0])
    linear_extrude(lattice_width)
    outer_shape([box_dim[0], box_dim[2]]);


    for (i = [1:x_cells-1])
    translate([lattice_thickness + (lattice_width + cell_spacing)*i - lattice_width,0,0])
    rotate([90,0,90])
    linear_extrude(lattice_width)
    outer_shape([box_dim[1], box_dim[2]]);

    for (i = [1:z_cells])
    translate([0,0,lattice_thickness + (lattice_width + cell_spacing)*i - lattice_width])
    skirt_shape([box_dim[0], box_dim[1]]);

}


ml = cell_spacing * 3 + lattice_width * 2;
mh = lattice_width * 3 + cell_spacing;

module mount() {
    
    mw = lattice_thickness*3 + tolerance*2;
    //ml = cell_spacing * 3 + lattice_width * 2;
    md = 40;
    
    
//translate([-lattice_thickness-tolerance,cell_spacing + lattice_width + lattice_thickness,cell_spacing - tolerance])
    difference() {
        cube([mw, ml, mh]);
        
        translate([lattice_thickness,-tolerance,lattice_thickness])
        cube([lattice_thickness + tolerance*2,
            ml + tolerance*2, 
            mh]);
        translate([lattice_thickness, cell_spacing, - tolerance])
            cube([lattice_thickness*2 + tolerance*3, lattice_width + tolerance*2, mh + tolerance*2]);
        translate([lattice_thickness, cell_spacing*2+lattice_width, - tolerance])
            cube([lattice_thickness*2 + tolerance*3, lattice_width + tolerance*2, mh + tolerance*2]);
    }

/*
intersection() {
translate([0,ml/2,mh/2])
rotate([0,-90,0])
thread_for_screw(50, 60);

translate([-60,0,0])
cube([60, ml, mh]);
}*/

ma = 90;

translate([-md/2,ml/2,0])
difference() {
    rotate([0,0,180 + ma/2])
    rotate_extrude(angle = 360 - ma)
    square([md/2+lattice_thickness, mh]);
    translate([0,0,-tolerance])
    cylinder(d = md, h= mh+tolerance*2);
}
//cylinder(d = md + lattice_thickness, h = mh);

}


//lattice_box();
mount();
