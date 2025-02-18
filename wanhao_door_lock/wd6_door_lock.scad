    

//square([75.5, 7]);

$fn = 64;

fillet = 2.5;

magnet_dia = 5;
magnet_count = 5;
magnet_thickness = 3;

xy_thickness = 2;
z_thickness = 0.8;
tol = 0.2;

mount_height = 74;
mount_width = magnet_dia + xy_thickness*2;
handle_thickness = 6.6;

handle_width = 15;

module square_fillet_one_edge(dim, fillet)  {
    
    translate([0,-fillet])
    difference() {
    
    offset(fillet)
    offset(delta = -fillet)
    square([dim[0], dim[1] + fillet]);
    //translate([-tol,-tol])
    
    translate([-1,-1])
    square([dim[0] + 2, fillet + 1]);
    }
}

module magnet_side() {

    difference() {

        linear_extrude(magnet_thickness)
        square_fillet_one_edge([mount_height, mount_width], fillet);

        for (i = [0:magnet_count-1])
            translate([i * (mount_height / magnet_count) + mount_height / (magnet_count*2), mount_width / 2, -tol])
                cylinder(d = magnet_dia + 0.1, h = magnet_thickness + tol*2);

    }
}


module main_side() {
    
    hole_distance = 64;
    
    
    
    //translate([0,-handle_width])
    difference() {
        linear_extrude(handle_thickness)
        difference() {
            
            square_fillet_one_edge([mount_height, handle_width + mount_width], fillet);
            
            translate([(mount_height - hole_distance) / 2, 9.3 / 2])
            circle(d = 4.2);
            
            translate([(mount_height - hole_distance) / 2 + hole_distance, 9.3 / 2])
            circle(d = 4.2);            
        }
        
        translate([-tol,0,0])
        rotate([90,0,90])
        linear_extrude(mount_height + tol*2)
        polygon([
            [9.6 - tol, -tol], 
            [handle_width + mount_width + tol, -tol], 
            [handle_width + mount_width + tol, magnet_thickness + tol], 
            [9.6 + magnet_thickness + tol, magnet_thickness + tol]
        ]);
        
        translate([xy_thickness,xy_thickness + handle_width + tol,magnet_thickness])
            cube([mount_height - xy_thickness*2, magnet_dia + tol*2, 1 + tol*2]);

    }

}



//tt = 5;


//translate([0,0,6])
*rotate([180,0,0])
main_side();

translate([0,10,magnet_thickness])
rotate([180,0,0])
magnet_side();

