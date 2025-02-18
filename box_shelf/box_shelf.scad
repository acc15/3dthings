
cube_dim = [50, 50, 20];
grid = [2,5];
tolerance = 0.2;
thickness = 0.48*2;
lock_radius = 1;
lock_offset = 2;


function t_off(dim, i) = thickness + (dim + tolerance*2 + thickness) * i;

module half_sphere(r) {
    difference() {
        sphere(r, $fa = 0.2, $fs = 0.2);
        
        translate([0,r,0])
        cube(r*2, center=true);
    }
    
}

union() {

linear_extrude(cube_dim[1])
difference() {
    square([t_off(cube_dim[0], grid[0]), t_off(cube_dim[2], grid[1])]);
    
    for (i = [0:grid[0]-1])
        for (j = [0:grid[1]-1])
            translate([t_off(cube_dim[0], i), t_off(cube_dim[2], j)])
                square([cube_dim[0] + tolerance*2, cube_dim[2] + tolerance*2]);
}


    for (i = [0:grid[0]-1])
        for (j = [0:grid[1]-1])
            translate([t_off(cube_dim[0], i) + cube_dim[0]/2 + tolerance, t_off(cube_dim[2], j) + cube_dim[2] + tolerance*2, 0]) {
                
                translate([0,0,lock_offset])
                half_sphere(r = lock_radius, $fn = 32);
                
                translate([0,0,cube_dim[1] - lock_offset])
                half_sphere(r = lock_radius, $fn = 32);
            }
            
        
}