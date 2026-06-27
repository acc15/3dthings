use <bendlib/bendlib.scad>;

height = 40;

cell_count = 8;
cell_width = 10;
thickness = 0.4 * 4;
z_thickness = 0.2 * 5;
rounding = 2;

rows = [
    [1, 5],
    [1, 5],
    [1, 8],
    [1, 8],
    [2, 8],
    [2, 8]
];



function compute_length(i = 0, e = len(rows)) = thickness + (i < e ? rows[i][1] + compute_length(i + 1, e) : 0);

dim = [ 
    thickness + cell_count * (cell_width + thickness),
    compute_length(0)
];


linear_extrude(z_thickness)
bl_square(dim, rounding);

translate([0,0,z_thickness])
linear_extrude(height)
difference() {
    bl_square(dim, rounding);

    for (i = [0:len(rows)-1]) {
        count = cell_count / rows[i][0];
        cell_width = cell_width * rows[i][0] + thickness * (rows[i][0] - 1);
        
        translate([thickness, compute_length(0, i)])
        for (j = [0:count-1]) {
            translate([(cell_width + thickness) * j, 0])
            bl_square([cell_width, rows[i][1]], rounding);
        }
    }
}