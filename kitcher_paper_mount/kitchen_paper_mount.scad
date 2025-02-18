
mount_inner_thickness = 1;
mount_outer_thickness = 1.38;
mount_width = 10;
mount_inner_length = 50;
mount_outer_length = 50;
mount_paper_diameter = 100;
mount_diameter = 10;
mount_height = 30;
desk_thickness = 19;

linear_extrude(mount_width)
polygon([
    [0, 0],
    [mount_inner_length, 0], 
    [mount_inner_length, desk_thickness + mount_inner_thickness + mount_outer_thickness],
    [mount_inner_length - mount_outer_length + mount_inner_thickness, desk_thickness + mount_inner_thickness + mount_outer_thickness],
    [mount_inner_length - mount_outer_length + mount_inner_thickness, desk_thickness + mount_inner_thickness + mount_outer_thickness + mount_paper_diameter / 2],
    [mount_inner_length - mount_outer_length, desk_thickness + mount_inner_thickness + mount_outer_thickness + mount_paper_diameter / 2],
    [mount_inner_length - mount_outer_length, desk_thickness + mount_inner_thickness],
    [mount_inner_length - mount_inner_thickness, desk_thickness + mount_inner_thickness],
    [mount_inner_length - mount_inner_thickness, mount_inner_thickness],
    [0, mount_inner_thickness],
]);

translate([mount_inner_thickness / 2, mount_inner_thickness + desk_thickness + mount_outer_thickness + mount_paper_diameter / 2])
cylinder(d = mount_diameter, h = mount_width + mount_height, $fn = 64);