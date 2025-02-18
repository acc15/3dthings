
$fa = 0.5;
$fs = 0.5;

sphere_d = 30;
sphere_offset = 6;
wire_d = [4, 4.5, 4.5, 4];
wire_depth = 0.8;

table_thickness = 10;
t = 5;

holder_length = 20;
holder_width = 25;
holder_height = table_thickness + t*2;
cyl_d = holder_length*2;

tolerance = 0.2;




module wire_holder() {

    difference() {

        union() {

            //cyl_d = holder_length*2;
            //scale([1,1,holder_height/cyl_d])
            rotate([0,90,0])
            cylinder(d = holder_height, h = holder_width);

            translate([0,0,-holder_height/2])
            cube([holder_width, holder_length, t]);
                
        }

        translate([-tolerance, 0, -table_thickness/2])
        cube([holder_width + tolerance*2, holder_height + tolerance, table_thickness+t+tolerance]);

/*
        translate([-tolerance,0,0])
        difference() {
            
            diff_d = holder_height - t*2;
            
            rotate([0,90,0])
            cylinder(d = diff_d, h = holder_width + tolerance*2);
            
            /*
            translate([-tolerance, -t, -diff_d/2-tolerance])
            cube([holder_width + tolerance*4, diff_d, diff_d + tolerance*2]);
        }*/

        for (i = [0:len(wire_d)-1]) {
            
            wire_dist = holder_width / len(wire_d);
            
            translate([(i + 0.5) * wire_dist,0,0])
                wire_diff(wire_d[i]);
            
        }
        
        

    }
}


module wire_diff(d) {
    
    cyl_r = cyl_d / 2;
    r = holder_height/2 - d/2 * wire_depth;
    
    //scale([1,cyl_r/r,1])
    rotate([0,90,180])
    rotate_extrude(angle = 90)
    translate([r,0])
    circle(d = d);
    
    /*
    translate([0,0,r])
    rotate([-90,0,0])
    cylinder(d = d, h = holder_length + tolerance);
    */
    
    translate([0,0,-r])
    rotate([-90,0,0])
    cylinder(d = d, h = holder_length + tolerance);
    
    translate([0,-r,0])
    //rotate([-90,0,0])
    cylinder(d = d, h = cyl_d/2);
    
    
    
    
}


/*


    r = holder_height/2 - 3.5/2 * wire_depth;
    
    rotate([0,90,180])
    rotate_extrude(angle = 90)
    translate([r,0])
    circle(d = 3.5);

*/


wire_holder();
//wire_diff(4);


