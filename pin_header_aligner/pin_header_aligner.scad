pitch = 2.54;
t = 0.2 * 6;
pin = [0.64, 0.64, 3];
grid = [20, 8];

dim = grid * pitch;
tolerance = 0.1;

echo(dim);

translate([0,0,t])
linear_extrude(pin[2])
difference() {
    square(dim);
    
    for (i = [0:grid[1]-1])
        for (j = [0:grid[0]-1])
            translate([pitch / 2 + j * pitch, pitch / 2 + i * pitch])
                square([pin[0] + tolerance*2, pin[1] + tolerance*2], center=true);
        
        
}
cube([dim[0], dim[1], t]);