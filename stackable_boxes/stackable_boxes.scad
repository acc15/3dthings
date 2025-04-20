$fa = 0.3;
$fs = 0.3;

xy_thickness = 0.48*2;
z_thickness = 0.2*5;

box_thickness = [xy_thickness,z_thickness,xy_thickness];
box_inner_dimensions = [10, 10, 5];
//box_inner_dimensions = [2.5*5, 2.5*5, 65];
box_outer_dimensions = box_inner_dimensions + box_thickness*2 - [0, box_thickness[1], 0];
box_handle_dimensions = [box_outer_dimensions[0], 3, 4];


shell_box_tolerance = 0.3;
shell_box_clip_tolerance = 0.3;
shell_lock_tolerance = 0.15;
shell_thickness = [xy_thickness, xy_thickness, z_thickness];
shell_inner_dimensions = box_outer_dimensions + [shell_box_tolerance*2,shell_box_tolerance*2,shell_box_tolerance];
shell_outer_dimensions = shell_inner_dimensions + shell_thickness*2 - [0,0,shell_thickness[2]];
shell_lock_dimensions = [shell_outer_dimensions[0] / 3, shell_thickness[0]*1.5];

clip_radius = box_thickness[0] + shell_box_tolerance + 0.4;



echo(box_inner_dimensions = box_inner_dimensions);


module clip_template(radius, factors) {
    dia = radius*2;
    
    translate([-(factors[1] - 0.5)*dia,0,0])
    intersection() {
        sphere(d = dia);
        translate([dia * (factors[0] - 0.5),-dia/2,-dia/2])
        cube([(factors[1] - factors[0])*dia, dia,dia]);
    }
}

module clip(lr, r = clip_radius) {
    mirror([lr,0,0])
    clip_template(r, [0,0.5]);
}

module box_clips(radius = clip_radius) {
    translate([box_thickness[0],0, box_outer_dimensions[2] - box_thickness[1] - clip_radius]) {
        translate([0,clip_radius,0])
        clip(0, radius);
        translate([0,box_outer_dimensions[1]-clip_radius,0])
        clip(0, radius);
        translate([box_inner_dimensions[0],box_outer_dimensions[1]*0.5,0])
        clip(1, radius);
    }
    
}

module box_handle() {
    difference() {
        cube(box_handle_dimensions);
        translate([box_thickness[0],-1,-1])
        cube([box_handle_dimensions[0] - box_thickness[0]*2, box_handle_dimensions[1] + 2, box_handle_dimensions[2] - box_thickness[2] + 1]);
    }        
}

module box() {
    difference() {
        cube(box_outer_dimensions);
        translate(box_thickness)
        cube(box_inner_dimensions + [0,1,0]);
    }
    box_clips();
    translate([0,0,box_outer_dimensions[2]])
    box_handle();
}

module lock_shape(dim) {
    polygon([[dim[1]/2,0],[0,dim[1]],[dim[0],dim[1]],[dim[0]-dim[1]/2,0]]);
}


module shell_lock_shape() {
    difference() {
        union() {
            
            translate([shell_lock_dimensions[1], shell_lock_dimensions[1]]) {
                
                translate([
                    shell_outer_dimensions[0]/2-shell_lock_dimensions[0]/2, 
                    shell_outer_dimensions[1]])
                lock_shape(shell_lock_dimensions);
                
                translate([
                    shell_outer_dimensions[0], 
                    shell_lock_dimensions[0] + shell_outer_dimensions[1]/2 - shell_lock_dimensions[0]/2])
                rotate(-90)
                lock_shape(shell_lock_dimensions);
                
            }
            
            difference() {
                square([shell_outer_dimensions[0] + shell_lock_dimensions[1], shell_outer_dimensions[1] + shell_lock_dimensions[1]]);
                
                translate([0, shell_lock_dimensions[1] + shell_outer_dimensions[1]/2+shell_lock_dimensions[0]/2])
                rotate(-90)
                offset(shell_lock_tolerance)
                lock_shape(shell_lock_dimensions);
                
                translate([shell_lock_dimensions[1] + shell_outer_dimensions[0]/2-shell_lock_dimensions[0]/2, 0])
                offset(shell_lock_tolerance)
                lock_shape(shell_lock_dimensions);
            }
            
        }
        
        translate([shell_lock_dimensions[1] + shell_thickness[0], shell_lock_dimensions[1] + shell_thickness[1]])
        square([shell_inner_dimensions[0], shell_inner_dimensions[1]]);
    }
}

module shell() {
    
    difference() {
        
        union() {
        
            linear_extrude(shell_thickness[2])
            translate([shell_lock_dimensions[1] + shell_thickness[0],shell_lock_dimensions[1] + shell_thickness[1]])
            square([shell_inner_dimensions[0], shell_inner_dimensions[1]]);
            
            linear_extrude(shell_outer_dimensions[2])
            shell_lock_shape();

        }
        
        translate([shell_lock_dimensions[1], shell_lock_dimensions[1], 0] + shell_thickness + [shell_box_tolerance,shell_box_tolerance,shell_box_tolerance])
        box_clips(clip_radius + shell_box_clip_tolerance);
        
    }
    
}
    
//translate([shell_lock_dimensions[1]+shell_thickness[0]+shell_box_tolerance,shell_lock_dimensions[1]+shell_thickness[1] + shell_box_tolerance, shell_thickness[2] + shell_box_tolerance])
rotate([90,0,0])
box();


*shell();

*translate([shell_thickness[0] + shell_outer_dimensions[0] + tolerance,0,0])
shell();





