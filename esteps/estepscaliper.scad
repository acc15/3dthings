
filament_dia = 1.75;
filament_tolerance = 0;
effective_filament_dia = filament_dia + filament_tolerance;
measure_length = 100;
wheel_dia = measure_length / PI;
wheel_r = wheel_dia / 2;

wall_thickness = 1;
axis_dia = 8;

total_height = effective_filament_dia + wall_thickness * 2;


module mark(subdiv, off, zoff = 0) {
    for(m = [0 : measure_length / subdiv : measure_length - measure_length / subdiv]) {
        rotate([0, 0, m * 360 / measure_length]) {
            translate([wheel_r - off, 0, zoff]) {
                $val = m;
                children();
            }
        }
    }
}

//difference() {

*union() {
    mark_height = 0.4;
    
    teeth_size = 2;
    
    //rotate_extrude($fn=128) translate([wheel_r,0,0]) circle(d = filament_dia);
    
    mark(100, 1.1, (total_height + mark_height) / 2)
        cube([2, 0.5, mark_height], center=true);

    mark(10, 2.1, (total_height + mark_height) / 2) {
        cube([4, 0.5, mark_height], center=true);
        translate([-2.5, 0, 0])
            linear_extrude(mark_height, center=true, $fn=30)
                text(str($val), font="OpenSans Extra Bold", size=3.6, halign="right", valign="center");
    }

    /*
    mark(50, 2 + filament_dia/2, 0) 
        linear_extrude(effective_filament_dia, center=true)
            polygon([[0,-effective_filament_dia/2], [2, 0], [0,effective_filament_dia/2]]);
    */
    difference() {
        quality = 100;
        cylinder(d = wheel_dia, h = total_height, center=true, $fn = quality);
        cylinder(d = axis_dia, h = total_height + 1, center = true, $fn = quality);
        rotate_extrude($fn = quality) {
            translate([wheel_r,0,0]) {
                //square([effective_filament_dia + 2, effective_filament_dia], center=true);
                //translate([effective_filament_dia / 2, 0, 0]) square(effective_filament_dia, center=true);
                circle($fn = 100, d = effective_filament_dia);
            }
        }
    }
}
//cube(500);
//}





mount_thickness = 2.3;
mount_offset = 2;
mount_height = total_height + mount_offset + mount_thickness + 3;
axis_r_tolerance = 0.4;
axis_r = (axis_dia - axis_r_tolerance) / 2;
axis_h_tolerance = 1;
axis_h = total_height + mount_offset + axis_h_tolerance;
axis_pad = 2;

filament_pressure = 1;

translate([0,0, -total_height / 2 - mount_thickness - axis_pad]) {
    translate([wheel_r + mount_offset, -wheel_r - mount_offset - mount_thickness, 0]) cube([mount_thickness, wheel_r + mount_thickness + 3, mount_height]);
    translate([-wheel_r, -wheel_r - mount_offset - mount_thickness, 0]) {
        difference() {
            cube([wheel_dia + mount_offset, mount_thickness, mount_height]);
            rotate([90,0,0]) translate([wheel_dia, mount_height - total_height / 2 - 4, -mount_thickness - 1]) {
                cylinder($fn=50, r = mount_offset, h=mount_thickness + 2);
                translate([0, 5, 2]) 
                    cube([mount_offset * 2, 10, mount_thickness + 2], center=true);
            }
        }
    }
    // teeth
    linear_extrude(mount_height) 
        polygon([
            [wheel_r + mount_offset * (1 - filament_pressure), 0], 
            [wheel_r + mount_offset, -1], 
            [wheel_r + mount_offset, +1]]);
        
    linear_extrude(height=mount_thickness)
        polygon([[-axis_r - mount_thickness, axis_r + 2], [axis_r + mount_thickness, axis_r + 2], [wheel_r + mount_offset + mount_thickness, -wheel_r / 2], [wheel_r + mount_offset, -wheel_r - mount_offset], [-wheel_r, -wheel_r - mount_offset]]);
    
    translate([0,0,mount_thickness]) cylinder($fn = 100, r = axis_r + 1, h = mount_offset);
   
    translate([0,0,mount_thickness + mount_offset]) 
    difference() {
        union() {
            cylinder($fn = 100, r = axis_r, h = axis_h);
            translate([0,0,axis_h-2]) 
                rotate_extrude($fn = 100) translate([axis_r,0,0]) polygon([[0,-1],[0.6,0],[0,2]]);
        };
        translate([0,0, -1]) cylinder($fn = 100, r = axis_r - mount_thickness, h = axis_h + axis_pad);
        translate([0,0,axis_h/2 + 1]) {
            cube([axis_r * 2 + 2, 1, axis_h + 3],center=true);  
            cube([1, axis_r * 2 + 2, axis_h + 3], center=true);
        }
    }
};
   


    