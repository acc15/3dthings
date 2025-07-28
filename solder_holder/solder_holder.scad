use <../bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

tolerance = 0.2;
xy_thickness = 2;
z_thickness = 2;

spool_dia = 57;
spool_length = 53;
spool_hole = 21;
solder_dia = 0.8;

rod_dia = 8;
rod_length = spool_length + tolerance*2;

spool_rod_dia = spool_hole - tolerance*2;
rod_distance = spool_dia/2+rod_dia/2+tolerance*4;
rod_hole = solder_dia + tolerance*2;

rods = [
    [0, 0, spool_rod_dia, false],
    [rod_distance, 45, rod_dia, true],
    [rod_distance, 225, rod_dia, false],
    [rod_distance, 315, rod_dia, false]
];


module rod_shape(d, c = 0.5) {
    intersection() {
        circle(d = d);
        translate([0,d*(c-0.5)/2])
        square([d, d*c], center=true);
    }
}

module rod_cut_shape(d) {
    square(bl_2d(d/2), center=true);
}

module rod(d, hole = false) {
    lock = z_thickness;
    cut = z_thickness + tolerance*2;
    
    translate([0,0,lock+cut+rod_length+cut])
    linear_extrude(lock)
    rod_shape(d);
    
    translate([0,0,lock+cut+rod_length])
    linear_extrude(cut)
    rod_cut_shape(d);
    
    translate([0,0,lock+cut])
    difference() {
        linear_extrude(rod_length)
        rod_shape(d,1);
        if (hole) {
            translate([-rod_hole/2,-d/2-tolerance,xy_thickness])
            cube([rod_hole, d+tolerance*2, rod_length - xy_thickness*2]);
        }
    }

    translate([0,0,lock])
    linear_extrude(cut)
    rod_cut_shape(d);
    
    linear_extrude(lock)
    rod_shape(d);    
}

module rod_mount_diff(d) {
    dw = sqrt(2) * d/2;
    
    translate([0,0,-tolerance])
    linear_extrude(z_thickness*2+tolerance*2)
    offset(delta=tolerance)
    union() {
        rod_shape(d);
        circle(d = dw);
    }
    
    translate([0,0,z_thickness])
    linear_extrude(z_thickness+tolerance)
    intersection() {
        circle(d = d+tolerance*2);
        bl_offset_clone([[-tolerance-d/2,0], [-tolerance-d/4,-d/2-tolerance]]) 
        square([d*3/4+tolerance*2, d/2+tolerance]);
    }
}

module rod_mount(d) {
    render()
    difference() {
        cylinder(d = d+xy_thickness*2, h = z_thickness*2);
        rod_mount_diff(d);
    }
}


module holder_shape() {
    for (rod = rods) {
        distance = rod[0];
        if (distance != 0) {
            angle = rod[1];
            dia = rod[2] + xy_thickness*2;
            rotate(angle)
            hull() {
                circle(d = dia);
                translate([distance,0])
                circle(d = dia);
            }
        }
    }
}

module holder_base() {
    difference() {
        union() {
            linear_extrude(z_thickness*2)
            difference() {
                holder_shape();
                offset(-xy_thickness)
                holder_shape();
            }
            linear_extrude(z_thickness)
            holder_shape();
            for (rod = rods) {
                translate(bl_polar(rod[0], rod[1]))
                cylinder(d = rod[2] + xy_thickness*2, h = z_thickness*2);
            }
        }
        for (rod = rods) {
            translate(bl_polar(rod[0], rod[1]))
            rod_mount_diff(rod[2]);
        }
    }
}

module spool() {
    linear_extrude(spool_length)
    bl_ring(outer_d = spool_dia, inner_d = spool_hole);
}


module assembly() {    
    translate([0,0,z_thickness*2 + spool_length+tolerance*2])
    holder_base();

    translate([0,0,z_thickness*2])
    mirror([0,0,1])
    holder_base();

    translate([0,0,-tolerance])
    for (rod = rods) {
        translate(bl_polar(rod[0], rod[1]))
        rotate(-90)
        rod(rod[2], rod[3]);
    }

    #translate([0,0,z_thickness*2 + tolerance])
    spool();
}

assembly();

*rotate([90,0,0])
rod(rods[3][2], rods[3][3]);

*holder_base();

*rotate([0,180,0])
mirror([0,0,1])
holder_base();


