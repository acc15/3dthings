dim = [72, 73, 18];
xy_thickness = 0.48*2;


x_cells = 10;

cube([dim[0],xy_thickness, dim[2]]);
translate([0,dim[1]-xy_thickness,0])
cube([dim[0],xy_thickness, dim[2]]);

cell_width = (dim[0] - xy_thickness*(x_cells - 1))/x_cells;

for (k = [1:x_cells-1]) {
    translate([cell_width*k + xy_thickness*(k-1),0,0])
    cube([xy_thickness,dim[1],dim[2]]);
}

translate([cell_width*9 + xy_thickness*9,0,0])
#cube([cell_width,dim[1],dim[2]]);