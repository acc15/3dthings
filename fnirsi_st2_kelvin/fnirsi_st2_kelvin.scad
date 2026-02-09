use <../bendlib/bendlib.scad>;
use <../bendlib/path_extrude.scad>;

usb_dim = [12, 4.5, 27];
usb_back_length = 12;
usb_front_length = 11.75;
usb_thickness = 0.3;
usb_back_hole_dia = 3;
usb_back_hole_offset = [2.5,4];

bolt_head_d = 5.4;
bolt_head_h = 3;
bolt_d = 3;
bolt_nut_d = bolt_head_d * 2/sqrt(3);
bolt_nut_h = 2;   

wire_dia = 2.3;

thickness = [0.4*5,0.4*5,0.2*10];
tolerance = [0.1,0.1,0.1];
mount_dim = [27, 17.25, thickness[2] + tolerance[2] + usb_dim[2] - usb_front_length];

$fa = 0.2;
$fs = 0.2;

module usb_back_holes(d = usb_back_hole_dia, h = usb_dim[1]+2) {
    translate([0,0,usb_back_hole_offset[1]])
    rotate([-90,0,0])
    translate([usb_back_hole_offset[0],0,0]) {
        cylinder(d = d, h = h);
        translate([usb_dim[0]-usb_back_hole_offset[0]*2,0,0])
        cylinder(d = d, h = h);
    }    
}


module usb_connector() {

    render()
    translate(bl_2d(-usb_dim/2))
    difference() {
        cube(usb_dim);

        w = 6;
        h = 1.5;

        translate([-1,0, (w+h+h)/2 + usb_back_length/2])
        rotate([0,90,0])
        linear_extrude(usb_dim[0] + 2)
        polygon([ [0,0], [w+h+h,0], [w+h, h], [h, h] ]);
        
        translate([0,-1,0])
        usb_back_holes(h=usb_dim[1]+2);
        
        translate([usb_thickness,0,0])
        cube([usb_dim[0]-usb_thickness*2,usb_dim[1]-usb_thickness,usb_back_length]);
    }
    
    wires();
    

}

module wires(dia = wire_dia) {
    distance = 7; // original usb distance is 7mm
    wire_count = 4;
    wire_distance = distance / (wire_count-1);
    echo(wire_distance=wire_distance, free_space = wire_distance - wire_dia);
    
    translate([-distance/2,0,-10]) {
        for (i = [0:wire_count - 1]) {
            color(i < wire_count/2 ? "red" : "black")
            translate([i * wire_distance, 0, 0]) {
                cylinder(d = dia, h = usb_back_length/2 + 10);
            }
        }
    }
}

*translate([0,0,thickness[2]+tolerance[2]]) {
    usb_connector();

}

module mount_shape() {
    bl_square(bl_2d(mount_dim), radius=2, $fn=1, center=true);
}

module mount_base() {
    linear_extrude(mount_dim[2])
    mount_shape();

    linear_extrude(mount_dim[2] + 0.5)
    difference() {
        mount_shape();
        offset(-1.75)
        mount_shape();
    }
}


module bolt_diff(l=mount_dim[1]) {
    tol = tolerance[1];
    
    rotate([0,0,30]) {
        translate([0,0,-tol])
        cylinder(d = bolt_head_d+tol*2, h = bolt_head_h+tol*2);
        cylinder(d = bolt_d+tol*2, h = l);
        translate([0,0,l-bolt_nut_h-tol])
        cylinder(d = bolt_nut_d+tol*2, h = bolt_nut_h+tol*2, $fn=6);
    }
}


module usb_diff() {

    translate([-usb_dim[0]/2,-usb_dim[1]/2,thickness[2]]) {
        difference() {
            
            union() {
                translate(-tolerance)
                cube([usb_dim[0] + tolerance[0]*2, usb_dim[1]+tolerance[1]*2, mount_dim[2]]);
                
                l = 10;
                w = 4;
                d = w+tolerance[0]*2;
            
                    
                translate([usb_dim[0]/2-(l-d)/2,usb_dim[1]/2,-10])
                linear_extrude(usb_back_length/2 + 10)
                hull() {
                    circle(d = d);
                    translate([l-d,0])
                    circle(d = d);
                }
            }
            
            translate([0,usb_dim[1]-usb_thickness*2-tolerance[1],0])
            usb_back_holes(d=usb_back_hole_dia-tolerance[0]*2, h = usb_thickness+tolerance[1]*3);
        }

    }
    
    translate([0,mount_dim[1]/2,mount_dim[2]/2]) {
        translate([mount_dim[0]/2-bolt_head_d/2-2,0,0])
        rotate([90,0,0])
        bolt_diff();
        translate([-mount_dim[0]/2+bolt_head_d/2+2,0,0])
        rotate([90,0,0])
        bolt_diff();
    }
}

module mount() {
    difference() {
        mount_base();
        usb_diff(); 
    }
}

module mount_part(y_offset) {
    intersection() {
        mount();
        translate([-mount_dim[0]/2-tolerance[0],y_offset,-tolerance[2]])
        cube([mount_dim[0]+tolerance[0]*2, mount_dim[1]/2+tolerance[1],mount_dim[2]+tolerance[2]*2]);
    }
}

module mount_parts() {
    translate([0,-1,0])
    rotate([90,0,0])
    module_part(-mount_dim[1]/2-tolerance[1]);

    rotate([-90,0,0])
    module_part(tolerance[1]);
    
}

module y_splitter() {
    
    d_inner = wire_dia + tolerance[0] * 2;
    d_outer = d_inner + thickness[0] * 2;
    
    *polygon(concat([[-4,0], [-4,10]], bl_arc(2, 45, position=[-6,10])));
    
    /*
    difference() {
        circle(d = d_outer);
        circle(d = d_inner);
    }*/
    
    //path_extrude([[-4,0,0], [-4,10,0],[-8,20,0],[-8,30,0]], bl_arc(d_inner/2, 360, slice=[0,-1]));
    
    for (i = [0:3]) {
        translate([i*(d_inner + thickness[0]),0,0])
        cylinder(d = d_inner, h = 10);
    }
    
    
        
   
}






y_splitter();




*usb_connector();

*bolt_diff();
*usb_diff();

