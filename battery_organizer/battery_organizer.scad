thickness = 1.2;

$fa = 0.4;
$fs = 0.4;

module battery_organizer(dia, grid) {
        
    height = dia*0.75;
    tolerance = 0.25;
    d = dia + tolerance*2;
    
    module base() {
        hull() {
            circle(d = d + thickness*2);
            translate([d*(grid[0]-1),0])
            circle(d = d + thickness*2);
            translate([d*(grid[0]-1),d*(grid[1]-1)])
            circle(d = d + thickness*2);
            translate([0,d*(grid[1]-1)])
            circle(d = d + thickness*2);
        }
    }
    
    module grid_shape(d_hole) {
        difference() {
            base();
            for (x = [0:grid[0]-1], y = [0:grid[1]-1]) {
                translate([x * d, y * d])
                circle(d = d_hole);
            }
        }
    }
    
    linear_extrude(thickness)
    difference() {
        grid_shape(d/1.5);
        offset(-thickness)
        grid_shape(d);
    }
    
    linear_extrude(height)
    difference() {
        grid_shape(d+0.01);
        offset(-thickness)
        grid_shape(d);
    }
    

}

battery_organizer(10, [5,5]);
