import("PCB_Mount.STL");

$fa = 0.2;
$fs = 0.2;

mount_width = 37.5; 
mount_height = 6;
mount_thickness = 5;

clip_width = 19;
clip_thickness = 2.1;
clip_height = 27;

plate_thickness = 3;

*union() {

#cube([mount_height,mount_width,mount_thickness]);

#translate([mount_height,mount_width,0])
cube([clip_width,clip_thickness,clip_height]);

#translate([mount_height,-clip_thickness,0])
cube([clip_width,clip_thickness,clip_height]);

#translate([mount_height,0,0])
cube([plate_thickness, mount_width, clip_height]);
    
    
}
    
#translate([mount_height-1,10.25,clip_height-10])
cube([plate_thickness+2,17,11]);

#translate([mount_height/2,6.25,-1])
cylinder(d = 2.8, h = mount_thickness + 2);

#translate([mount_height/2,mount_width-6.25,-1])
cylinder(d = 2.8, h = mount_thickness + 2);