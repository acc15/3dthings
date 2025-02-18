width = 31 ;
height = 110;
thickness = 3.1;
battery_width = 15;
battery_depth = 5;
mount_height = 10;


cube([width, height, thickness]);
translate([width/2-battery_width/2, 10, thickness])
    cube([thickness, height - 20, battery_depth]);
translate([width/2+battery_width/2-thickness, 10, thickness])
    cube([thickness, height - 20, battery_depth]);

translate([width/2-battery_width/2,-mount_height+thickness,thickness])
translate([battery_width,0,0])
rotate([0,-90,0])
linear_extrude(battery_width)
polygon([[0,0],[thickness,0],[thickness,mount_height-thickness],[0,mount_height]]);

translate([width/2-battery_width/2,height-thickness,thickness])
cube([battery_width, thickness, 10]);