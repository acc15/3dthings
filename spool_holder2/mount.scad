thickness = 4;
tolerance = 0.2;

z_distance = 295;
y_distance = 150;

bolt_distance = 190;
bolt_dia = 4;
bolt_length = 12;
bolt_head = 3;

spool_length = bolt_distance;//10;
rod_dia = 8;
hole_dia = 7.6;
rod_length = spool_length + thickness * 4 + tolerance * 2 + 16;

mount_dia = rod_dia + thickness*2;
mount_rod_length = 40;

guide_holder_height = 10;
guide_dia = 4;

$fa = 0.5;
$fs = 0.5;

x_distance = (bolt_distance - spool_length)/2;

rod_vec = [x_distance, y_distance, z_distance - bolt_dia];
offset_angle = atan2(rod_vec[1], rod_vec[2]);
offset_dist = (rod_dia/2 + tolerance)*sin(90-offset_angle)/sin(offset_angle);

m8nut_d = 14.5;
m8nut_h = 6;

module rod() {
    #translate([(bolt_distance - rod_length) / 2,y_distance,z_distance])
    rotate([0,90,0])
    cylinder(d = rod_dia, h = rod_length);    
}


module mount_rod(lr = false) {
    #hull() {
        translate([lr ? 0 : bolt_distance, 0, bolt_dia])
        sphere(d = rod_dia);

        translate([(lr ? 0 : spool_length) + x_distance,y_distance,z_distance])
        sphere(d = rod_dia);
    }
}

module holder_mount(lr = false) {
    render()
    difference() {
        translate([lr ? 0 : bolt_distance,0,bolt_dia]) 
        rotate([-offset_angle,0,0])
        translate([0,0,norm(rod_vec) - mount_rod_length]) {
        union() {
        
            
            translate([0,0,mount_rod_length])
            difference() {
                sphere(d = mount_dia);
                translate([-mount_dia/2-tolerance,-mount_dia/2-tolerance, -mount_dia-tolerance])
                cube([mount_dia+tolerance*2, mount_dia + tolerance*2, mount_dia]);
            }
            
            translate([0,0,mount_rod_length-offset_dist])
                cylinder(d = mount_dia, h = offset_dist);
            
            difference() {
                linear_extrude(mount_rod_length-offset_dist+tolerance)
                difference() {
                    circle(d = mount_dia);
                    circle(d = hole_dia);
                }
                
                translate([0,-mount_dia/2+0.6,8])
                rotate([90,0,0])
                linear_extrude(0.6 + tolerance)
                text(lr ? "L" : "R", halign = "center", valign = "center", size = 7);
            }
        }
        
        
        }
        
        translate([(lr ? 0 : spool_length) + x_distance, y_distance, z_distance])
        rotate([90,0,90])
        translate([0,0,-mount_dia])
        linear_extrude(mount_dia*2)
        hull() {
            
            circle(d = rod_dia + tolerance*2);
            translate([0, mount_dia])
                circle(d = rod_dia + tolerance*2);
        }
    }
}


module guide_holder(align = true) {
    translate([0,0,mount_dia])
    rotate([align ? -offset_angle : 0,0,0])
    translate([0,0,200])
    difference() {
        union() {

            cylinder(d = mount_dia, h = guide_holder_height);


            translate([0,-thickness/2,0])
            cube([spool_length/2, thickness, guide_holder_height]);

            translate([0,-mount_dia/2,0])
            cube([spool_length/2, mount_dia, thickness]);
            
            translate([spool_length/2,0,0])
            difference() {
                sphere(r = guide_holder_height);
                translate([-guide_holder_height-tolerance, -guide_holder_height-tolerance, -guide_holder_height-tolerance])
                cube([guide_holder_height*2+tolerance*2,guide_holder_height*2+tolerance*2,guide_holder_height+tolerance]);
            }

        }
        

        translate([spool_length/2,0,0])
        rotate([90+offset_angle,0,0])
        translate([0,0,-guide_holder_height*1.5])
        cylinder(d = guide_dia + tolerance*2, h = guide_holder_height*3);

        translate([0,0,-tolerance])
        cylinder(d = hole_dia, h = guide_holder_height + tolerance*2);
        translate([0,0,-tolerance])
        cylinder(d = hole_dia, h = guide_dia + tolerance*2);
    }
}

module spool(h = 50, d = 200, id = 50) {
    difference() {
        union() {
            cylinder(d = d, h = 5);
            cylinder(d = id + 5, h = h);
            translate([0,0,h - 5])
            cylinder(d = d, h = 5);
        }
        translate([0,0,-5])
        cylinder(d = id, h = h + 20);
    }
}

module bolt_hole(d,h1,h2 = 0) {
    translate([0,0,-tolerance])
        cylinder(d = d+tolerance*2, h1 - bolt_head + tolerance*2);

    translate([0,0,h1 - bolt_head])
        cylinder(d1 = d+tolerance*2, d2 = d*2+tolerance*2, h = bolt_head);

    translate([0,0,h1 - tolerance])
        cylinder(d = d*2 + tolerance*2, h = h2 + tolerance*2);
}

module mount4_base() {
    
    translate([0,0,bolt_dia])
    difference() {
        rotate([-offset_angle,0,0])
            cylinder(d = mount_dia, h = mount_rod_length);
        
        translate([-mount_dia/2-tolerance,-mount_dia-tolerance,0])
            cube([mount_dia+tolerance*2,mount_dia, mount_dia*2]);
    }
    
    translate([-mount_dia/2,mount_dia/2,-bolt_dia-mount_dia/2])
        rotate([0,90,0])
            cylinder(d = mount_dia,h = mount_dia);
}

module mount4(lr) {
    
    translate([lr ? 0 : bolt_distance,0,0]) {
    
        difference() {
            
            hull() {
                translate([0,-thickness,0])
                rotate([-90,0,0])
                linear_extrude(thickness)
                hull()
                projection()
                rotate([90,0,0])
                mount4_base();
            
                mount4_base();
            }
            
            
            translate([0,0,bolt_dia])
            rotate([-offset_angle,0,0])
                translate([0,0,offset_dist])
                    cylinder(d = hole_dia, h = 200);
            
            translate([0,-thickness,0])
            rotate([-90,0,0])
                bolt_hole(d = 4, h1 = 8, h2 = 20);
            
            translate([-mount_dia/2-tolerance,mount_dia/2,-bolt_dia-mount_dia/2])
            rotate([0,90,0])
                cylinder(d = hole_dia, h = mount_dia + tolerance*2);

            
        }
        
    }
}

module wire_holder() {

linear_extrude(10)
difference() {
    
    hull() {
    circle(d = mount_dia);
    translate([-46,-1.8])
    square([46, 3.6]);
    }
    
    circle(d = hole_dia);
    translate([-46,-0.8])
    square([38, 1.6]);
}

}

module holder_mount2(lr, demo = true) {

    bd = m8nut_d + thickness*2;

    translate([lr || !demo ? 0 : bolt_distance,0,bolt_dia]) 
    rotate([demo ? -offset_angle : 0,0,0])
    translate([0,0,demo ? norm(rod_vec) - mount_rod_length : 0])
    difference() {

        hull() {

            cylinder(d = mount_dia, h = mount_dia);

            translate([-mount_dia/2, -bd/2, mount_rod_length - mount_dia/2])
            cube([mount_dia, bd, mount_dia]);
            
        }

        translate([0,0,-tolerance])
        cylinder(d = hole_dia, h = mount_rod_length-offset_dist+tolerance*2);

        translate([0,0,mount_rod_length])
        rotate([0,90,lr ? 0 : 180])
        union() {

            translate([0,0,-tolerance - mount_dia/2])
            hull() {
                cylinder(d = m8nut_d + tolerance*2, h = m8nut_h + tolerance, $fn = 6);
                translate([-bd,0,0])
                cylinder(d = m8nut_d + tolerance*2, h = m8nut_h + tolerance, $fn = 6);
            }

            translate([0,0,-tolerance - (mount_dia/2 - m8nut_h)])
            hull() {
                cylinder(d = rod_dia + tolerance*2, h = (mount_dia - m8nut_h) + tolerance*2);

                translate([-bd,0,0])
                cylinder(d = rod_dia + tolerance*2, h = (mount_dia - m8nut_h) + tolerance*2);
            }
        }
    }

}

/*
mount4(true);
mount4(false);


#translate([-mount_dia,mount_dia/2,-bolt_dia-mount_dia/2])
rotate([0,90,0])
cylinder(d = rod_dia, h = bolt_distance + mount_dia * 2);    


holder_mount2(false);
holder_mount2(true);
guide_holder(true);

if ($preview) {
    rod();
    mount_rod(false);
    mount_rod(true);
    
    spool_h = 80;
    translate([x_distance + spool_length / 2 - spool_h/2, y_distance, z_distance])
    rotate([0,90,0])
    spool(h = spool_h);
}

*/

holder_mount2(false, false);


echo(mount_dia = mount_dia, 
    join_rod_length = bolt_distance + mount_dia * 2, 
    screw_distance = mount_rod_length - offset_dist, 
    holder_rod_length = norm(rod_vec) - offset_dist*2);

