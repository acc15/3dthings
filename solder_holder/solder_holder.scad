$fa = 0.2;
$fs = 0.2;

tolerance = 0.2;
xy_thickness = 0.48*3;
z_thickness = 0.2*10;

spool_dia = 57;
spool_length = 54;
spool_hole = 21;

holder_length = 60;
holder_leg_length = 50;
holder_solder_length = 40;
holder_width = 10;

pillar_d = 6;
pillar_s = 4;
solder_d = 2.4;

module pillar_shape() {
    intersection() {
        circle(d = pillar_d);
        square([pillar_s, pillar_d], center=true);
    }
}

module ring_shape(d, t) {
    difference() {
        circle(d = d);
        circle(d = d - t*2);
    }
}

module ring(d, t, h) {
    linear_extrude(h)
    ring_shape(d, t);
}

module spool() {
    ring(spool_dia, (spool_dia - spool_hole)/2, spool_length);
}

module holder_pillar() {
    linear_extrude(holder_length + z_thickness*4)
    pillar_shape();
}

module solder_pillar() {
    difference() {
        holder_pillar();
        translate([-pillar_d/2, -solder_d/2, z_thickness*3])
            cube([pillar_d, solder_d, holder_length-z_thickness*2]);
    }
}

module pillar_placement() {
    children(0);
        
    rotate(-45)
    translate([holder_leg_length,0,0])
    rotate(90)
    children(1);
    
    rotate(-135)
    translate([holder_leg_length,0,0])
    rotate(90)
    children(1);
    
    rotate(135)
    translate([holder_solder_length,0,0])
    rotate(-135)
    children(2);
    
}


module holder_hull(angle, length = holder_leg_length) {
    hull() {
        circle(d = holder_width);
        rotate(angle)
        translate([0,length])
        circle(d = holder_width);
    }
}

module holder_base_shape() {
    difference() {
        union() {
            holder_hull(-135);
            holder_hull(45, holder_solder_length);
            holder_hull(135);
        }
        offset(tolerance)
        pillar_placement() {
            pillar_shape();
            pillar_shape();
            pillar_shape();
        }
    }
}

module holder_base(side) {
    mirror([side ? 1 : 0, 0, 0])
    union() {
    
        linear_extrude(z_thickness)
        holder_base_shape();

        translate([0,0,z_thickness])
        linear_extrude(z_thickness)
        difference() {
            holder_base_shape();

            offset(-xy_thickness)
            holder_base_shape();
        }
    }
}

module holder_pillars() {
    pillar_placement() {
        holder_pillar();
        holder_pillar();
        solder_pillar();
    }
}

module assembly() {

    translate([0,0,z_thickness*2])
    rotate([0,180,0])
    holder_base(true);
    translate([0,0,z_thickness*2 + holder_length])
    holder_base(false);
    holder_pillars();
    
    #translate([0,(pillar_d-spool_hole)/2,z_thickness*2 + (holder_length-spool_length)/2])
    spool();

}

rotate([90,0,0])
assembly();






