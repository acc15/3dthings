handle_d = 34;
thickness = 0.6*5;
bolt_outer_d = 11.5;
bolt_small_d = 10;
bolt_head_thickness = 4;
nut_thickness = 6;
bolt_thread_d = 6;
bolt_length = 40;
mount_width = 20;
tolerance = 0.2;

cup_min_d = 75;
cup_max_d = 80;

$fa = 0.2;
$fs = 0.2;

module handle_base(d,sq) {
    circle(d = d);
    translate([-d/2,0])
        square([d,sq]);
}

module bolt(length, head) {
    cylinder($fn = 6, d = bolt_outer_d + tolerance*2, h = head);
    translate([0,0,head-tolerance])
        cylinder(d = bolt_thread_d + tolerance*2, h = length + tolerance*2);
}

module test_bolt() {
    #bolt(bolt_length, bolt_head_thickness);
}

module mount() {

    full_d = handle_d + thickness*2;
    mount_len = handle_d/2 + tolerance + bolt_thread_d/2;
    
    difference() {

        union() {


            linear_extrude(mount_width)
            difference() {
                handle_base(full_d, mount_len);
                handle_base(handle_d, mount_len + tolerance);
            }
            
            
            translate([handle_d/2,mount_len,mount_width/2])
            rotate([0,90,0])
            cylinder(d = mount_width, h = thickness);
            
            
            hull() {
                translate([-handle_d/2,mount_len,mount_width/2])
                rotate([0,-90,0])
                cylinder(d = mount_width, h = thickness + bolt_head_thickness);
            
                translate([-handle_d/2,0,mount_width/2])
                rotate([0,-90,0])
                cylinder(d = mount_width, h = thickness + bolt_head_thickness);
            }
            
            translate([-handle_d/2,0,mount_width/2])
            rotate([0,-90,0])
            cylinder(d = mount_width, h = bolt_length - thickness*2 - tolerance*2);
            
            
        }
    
        
        translate([-full_d/2-bolt_head_thickness-tolerance,mount_len,mount_width/2])
            rotate([0,90,0]) 
                bolt(full_d, bolt_head_thickness+tolerance);
        

        /*
        translate([0,0,mount_width/2])
            rotate([0,-90,0])    
                bolt(thickness, handle_d/2+nut_thickness);*/
    
    }
    
}

module holder() {

   
    cup_mid_d = (cup_min_d + cup_max_d)/2;

    rotate_extrude()
    polygon([
        [cup_min_d/2, 0],
        [cup_min_d/2 + thickness, 0],
        [cup_max_d/2 + thickness, mount_width],
        [cup_max_d/2, mount_width]
    ]);
    
    translate([cup_min_d/2, 0, mount_width/2])
    rotate([0,90,0])
    cylinder(d = mount_width, h = cup_max_d/2 + thickness - cup_min_d/2);
            


}


module knob() {
    
    knob_r = mount_width/2;
    knob_chamfer = 2;
    knob_cut_r = 10;
    knob_cut_count = 6;

    difference() {

        rotate_extrude()
        polygon([
            [0,0],
            [knob_r - knob_chamfer,0],
            [knob_r, knob_chamfer],
            [knob_r, thickness + nut_thickness - knob_chamfer],
            [knob_r - knob_chamfer, thickness + nut_thickness],
            [0, thickness + nut_thickness]
        ]);

        for (i = [0:knob_cut_count-1])
            rotate([0,0,360/knob_cut_count*i])
                translate([knob_r + knob_cut_r - knob_chamfer,0, -tolerance])
                    cylinder(r = knob_cut_r, h = thickness + nut_thickness + tolerance*2);
     
        translate([0,0, thickness + nut_thickness + tolerance])
        rotate([180,0,0])
            bolt(thickness + tolerance, nut_thickness + tolerance); 
        
    }
    
}


/*
translate([-handle_d/2-thickness-bolt_head_thickness,handle_d/2+tolerance+bolt_thread_d/2,mount_width/2])
rotate([0,90,0])
test_bolt();

translate([-handle_d/2-bolt_head_thickness-bolt_length,0,mount_width/2])
rotate([0,90,0])
test_bolt();
*/
/* #cylinder(d = handle_d, h = mount_width); */


//mount();
knob();

/*
translate([-handle_d/2-bolt_length+thickness,0,mount_width/2])
rotate([0,-90,0])
#knob();

translate([-handle_d/2-bolt_length+thickness + tolerance + thickness,0,mount_width/2])
rotate([0,-90,0])
#cylinder(d=mount_width,h = thickness);*/











