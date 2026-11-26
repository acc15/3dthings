$fa = 0.2;
$fs = 0.2;

layer_thickness = 0.3;
z_thickness = layer_thickness*2;
bridge_thickness = layer_thickness * 2;

base_d = 0.4*6;
tower_min_r = 5;
tower_max_r = 10;

tower_min_h = z_thickness*2;
tower_max_h = 10;
steps = 12;


for (i = [0:steps-1]) {
    angle = 360 / steps * i;
    h = (sin(angle) + 1)/2 * (tower_max_h - tower_min_h) + tower_min_h;
    
    rotate([0,0,angle]) {
        translate([tower_max_r,0,0])
        cylinder(d = base_d, h = h);
        
        
        translate([0,0,h])
        //rotate([angle,0,0])
        linear_extrude(bridge_thickness)
        hull() {
            circle(d = base_d);
            translate([tower_max_r,0,0])
            circle(d = base_d);
        }
    }
}
    

cylinder(d = base_d, h = tower_max_h);

cylinder(r = tower_max_r + base_d/2, h = z_thickness);