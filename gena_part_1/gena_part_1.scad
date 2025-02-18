
part_angle = 60;
tube_h = 16.25;
tube_inner_d = 1.8;
tube_d = 3;
tube_inner_h = 2;
part_h = 3.4;
part_len = 9.5;
wall = 1.4;

tolerance = 0.1;


$fa = 0.1;
$fs = 0.1;

difference() {

union() {

    cylinder(d = tube_d, h = tube_h);

    linear_extrude(part_h)
    difference() {
        offset(tube_d / 2 + wall)
            polygon([[0,0], [cos(-part_angle/2) * 10, sin(-part_angle/2) * 10], [cos(part_angle/2) * 10, sin(part_angle/2) * 10]]);
        translate([part_len - tube_d/2 - wall, -50/2])
            square([50, 50]);
    }
    
    
    translate([0,0,part_h - tolerance])
    mount();
    
    
}

translate([0,0,-tolerance])
cylinder(d = tube_inner_d, h = tube_h + tolerance*2);

translate([0,0,-tolerance])
cylinder(d = tube_d + tolerance*2, h = tube_inner_h + tolerance);

}

module mount() {
    
    rail_width = 6;
    rail_thickness = 0.6;
    
    mount_height = 2.4;
    mount_width = 4;
    mount_thickness = 3.2;
    
    linear_extrude(mount_height + tolerance)
    translate([-mount_width/2,-mount_thickness/2]) {

        translate([-rail_thickness,0]) {
            square([rail_width, rail_thickness]);
            translate([0, mount_thickness - rail_thickness])
                square([rail_width, rail_thickness]);
        }
        square([mount_width, mount_thickness]);
        
    }

}




