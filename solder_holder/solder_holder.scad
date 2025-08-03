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
rod_spool_dia = spool_hole - tolerance*2;
rod_lock_length = xy_thickness;
rod_cut_length = xy_thickness + tolerance*2;
rod_free_length = spool_length + tolerance*2;
rod_length = rod_lock_length * 2 + rod_cut_length * 2 + rod_free_length;

rod_distance = spool_dia/2 + rod_dia; // precise value = spool_dia/2 + rod_dia/2 + tolerance*2;
rod_hole = solder_dia + tolerance*2;

rods = [
    [0, 0, rod_spool_dia, false],
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
    bl_tower([rod_lock_length,rod_cut_length,rod_free_length,rod_cut_length,rod_lock_length]) {
        if ($index == 0 || $index == 4) {
            linear_extrude($length)
            rod_shape(d);
        } else if ($index == 1 || $index == 3) {
            linear_extrude($length)
            rod_cut_shape(d);
        } else {
            difference() {
                linear_extrude($length)
                rod_shape(d,1);
                if (hole) {
                    translate([-rod_hole/2,-d/2-tolerance,xy_thickness])
                    cube([rod_hole, d+tolerance*2, $length - xy_thickness*2]);
                }
            }
        }
    }
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
    translate([0,0,z_thickness*2+tolerance*2+rod_free_length])
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

    #translate([0,0,z_thickness*2 + tolerance + (rod_free_length - spool_length)/2])
    spool();
}

module printset(with_rods=true,with_base=true) {
    
    rod_offset_lengths = with_rods ? [ for (rod = rods) rod[2]+xy_thickness ] : [];
    
    module rods() {
        module print_rod(rod) {
            translate([rod[2]/2, rod_length, rod[2]*0.25])
            rotate([90,0,0])
            rod(rod[2], rod[3]);
        }
        bl_tower(rod_offset_lengths, [1,0,0]) {
            print_rod(rods[$index]);
        }
    }
    
    if (with_rods) {
        rods();
    }
    
    module bases() {
    
        x_rods = [for (rod = rods) bl_polar(rod[0],rod[1])[0]];
        y_rods = [for (rod = rods) bl_polar(rod[0],rod[1])[1]];
        
        holder_base_dim = [ max(x_rods) - min(x_rods)+rod_dia+xy_thickness*2, max(y_rods) - min(y_rods) + rod_dia + xy_thickness*2, z_thickness*2 ];
        
        translate([holder_base_dim[0]/2,holder_base_dim[1]/2 + rod_length + xy_thickness,0]) 
            holder_base();

        translate([bl_sum(rod_offset_lengths) + holder_base_dim[0]/2,holder_base_dim[1]/2,0])
        rotate([0,180,0])
        mirror([0,0,1])
        holder_base();
        
    }
    
    if (with_base) {
        bases();
    }

}

*assembly();

printset();


