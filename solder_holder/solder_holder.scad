use <../bendlib/bendlib.scad>;

$fa = 0.1;
$fs = 0.1;

tolerance = 0.2;
xy_thickness = 2;
z_thickness = 2;

spool_dia = 57;
spool_length = 53;
spool_hole = 21.4;
solder_dia = 0.8;

rod_dia = 10;
rod_length = spool_length + tolerance*2;

module rod_shape(d) {
    intersection() {
        circle(d = d);
        translate([0, d/8])
        square([d, d*3/4], center=true);
    }
}

module rod_lock_shape(d) {
    intersection() {
        circle(d = d);
        square([d, d/2], center=true);
    }
}

module rod_cut_shape(d) {
    square([d/2,d/2], center=true);
}

module rod(d, hole = undef) {
    lock = z_thickness;
    cut = z_thickness + tolerance*2;
    
    translate([0,0,lock+cut+rod_length+cut])
    linear_extrude(lock)
    rod_lock_shape(d);
    
    translate([0,0,lock+cut+rod_length])
    linear_extrude(cut)
    rod_cut_shape(d);
    
    translate([0,0,lock+cut])
    difference() {
        linear_extrude(rod_length)
        rod_shape(d);
        if (hole != undef) {
            translate([-hole/2,-d/2-tolerance,xy_thickness])
            cube([hole, d+tolerance*2, length - xy_thickness*2]);
        }
    }

    translate([0,0,lock])
    linear_extrude(cut)
    rod_cut_shape(d);
    
    linear_extrude(lock)
    rod_lock_shape(d);    
}

module rod_mount(d) {
    lock = z_thickness;
    dw = sqrt(2) * d/2;
    
    render()
    difference() {
   
        linear_extrude(z_thickness*2)
        difference() {
            circle(d = d + xy_thickness*2);
        
            offset(delta=tolerance)
            union() {
                rod_lock_shape(d);
                circle(d = dw);
            }
            
        }
        
        translate([0,0,z_thickness])
        linear_extrude(z_thickness+tolerance)
        intersection() {
            circle(d = d+tolerance*2);
            union() {
                translate([-tolerance-d/4,0])
                square([d*3/4+tolerance*2, d/2+tolerance]);
            
                translate([-tolerance-d/2,-d/2-tolerance])
                square([d*3/4+tolerance*2, d/2+tolerance]);
            }
        }
        
    }
    
}

rods = [
    [0, 0, spool_hole - tolerance*2, false],
    [45, spool_dia/2+rod_dia/2+tolerance*4, rod_dia, true],
    [225, spool_dia/2+rod_dia/2+tolerance*4, rod_dia, false],
    [315, spool_dia/2+rod_dia/2+tolerance*4, rod_dia, false]
];



demo_dia = rod_dia;//spool_hole - tolerance*2;

color("green")
rotate([0,0,0])
translate([0,0,-rod_length-z_thickness*2-tolerance*3])
rod(demo_dia);
rod_mount(demo_dia);