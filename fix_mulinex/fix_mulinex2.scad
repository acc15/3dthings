use <MCAD/involute_gears.scad>

tolerance = 0.2;
gear_clearance = 0.2;

function gear_pitch_r(p, z) = z * p / 360;
function gear_inner_r(p, z) = p * (z - 2) / 360 - gear_clearance;


module gear_dia(z, d, h = 0, n = "") {    
    p = 180 * d / (z + 2);
    echo("gear pitch of ", n, " = ", p, " z = ", z, " d = ", d);
    gear(number_of_teeth = z, 
        circular_pitch = p,
        bore_diameter = h,
        clearance = gear_clearance,
        flat = true);
}

module gear_pitch(z, p, n = "") {    
    // p = 180 * d / (z + 2);
    r = gear_pitch_r(p, z);
    d = r*2;
    echo(gear = n, p = p, z = z, r = r, d = d);
    gear(number_of_teeth = z, 
        circular_pitch = p,
        bore_diameter = 0,
        flat = true);
}

axis1_d = 5;
axis2_d = 4;
axis_dist = 17;

drive_z = 15;
ratio1_z = 32;
ratio2_z = 14;
main_z = 28;

drive_p = 130;//(axis_dist * 360) / (drive_z + ratio1_z);
ratio1_p = drive_p;
ratio2_p = 145;//(axis_dist * 360) / (ratio2_z + main_z);
main_p = ratio2_p;

drive_h = 10;
drive_con_t = 1;
ratio1_h = 8;
ratio2_h = 11;
ratio_h = 21;
main_h = 10;
main_pad_h = 1.5;
main_pad_d = 11;
main_hole_d = 8;
main_hole_h = 9;
main_hex_d = 10;
main_hex_h = 6;
main_con_d = gear_inner_r(main_p, main_z)*2-tolerance*4;
main_con_h = 0.6;
main_con_t = 0.5;
ratio_pad_h = 1.5;
ratio_pad_d = 8;

rotator_d = 25;
rotator_h = 10;
rotator_t = 1;
rotator_blade_w = 11;
rotator_blade_h = 3;
rotator_blade_offset = 2;
rotator_mount_d = 16;
rotator_mount_h = main_hex_h;
rotator_mount_t = 3;




echo(gear_pitch_r(drive_p, drive_z) + gear_pitch_r(ratio1_p, ratio1_z));
echo(gear_pitch_r(ratio2_p, ratio2_z) + gear_pitch_r(main_p, main_z));



function arc_seg(n, r, a) = let(angle = min(360, abs(a[1] - a[0])) / 360) n == undef 
    ? $fn > 0 ? max($fn, 3) : ceil(max(min(360/$fa,r[0]*2*PI*angle/$fs),5))
    : n;

function arc(a, r, d, n, l = true, p = [0,0]) = let(
    angle = len(a) == undef ? [0, a] : a,
    radius = d == undef 
        ? (r[0] == undef ? [r, r] : r) 
        : (d[0] == undef ? [d/2,d/2] : d / [2,2]),
    segments = arc_seg(n, radius, angle)
) [ for (i = [0:l ? segments : segments - 1]) let(ca = angle[0] + i * (angle[1] - angle[0]) / segments) [cos(ca) * radius[0], sin(ca) * radius[1]] + p ];

$fn = 64;

module hexagon(d) {
    polygon(arc([0,360], d = d, n = 6));
}

module drive_gear() {
    
    
    linear_extrude(drive_h)
    difference() {
        gear_pitch(drive_z, drive_p, "drive");
        
        circle(d = axis1_d + tolerance*2);
        square([axis1_d + drive_con_t*2 + tolerance*2, drive_con_t + tolerance*2], center = true);
    }
    
}

module ratio_gear() {
    
    render()
    difference() {
    
        union() {
        
            translate([0,0,ratio_pad_h]) {
                        
                linear_extrude(ratio1_h)
                gear_pitch(ratio1_z, ratio1_p, "big ratio");
                
                translate([0,0,ratio1_h])
                linear_extrude(ratio2_h)
                gear_pitch(ratio2_z, ratio2_p, "small ratio");
                
            }
                
            cylinder(d = ratio_pad_d, h = ratio_h);
                    
        }
        
        translate([0,0,-tolerance])
        cylinder(d = axis2_d + tolerance*2, h = ratio_h + tolerance*2);
        
    }
    
}

module main_gear() {
    
    render()
    difference() {
        
        union() {
            translate([0,0,main_pad_h])
            linear_extrude(main_h)
                // changed dia from 23.56 to 23.8 (test)
                // changed dia from 23.56 to 25 (test)
                // changed dia from 25 to 24 (test)
                gear_pitch(main_z, main_p, "main gear");
            cylinder(d = main_pad_d, h = main_h + main_pad_h);
     
            translate([0,0,main_h + main_pad_h])
                linear_extrude(main_hex_h)
                    hexagon(main_hex_d);
            
            translate([0,0,main_h + main_pad_h])
            linear_extrude(main_con_h)
            difference() {
                circle(d = main_con_d);
                circle(d = main_con_d - main_con_t*2);
                square([main_con_d, main_con_t*4], center = true);
                square([main_con_t*4, main_con_d], center = true);
            }
            
        }
        
        translate([0,0,-tolerance])
        // only 1x tolerance for tight fit
        cylinder(d = main_hole_d + tolerance, h = main_hole_h + tolerance*2); 
            
    }
   
}

module rotator() {

    linear_extrude(rotator_h)
    difference() {
        circle(d = rotator_d);
    
        for (i = [0:3]) rotate(i * 90)
            translate([0,-rotator_blade_offset])
            square([rotator_blade_w, rotator_blade_h]);
    }
    
    
    translate([0,0,rotator_h])
    cylinder(d = rotator_d, h = rotator_t);
    
    translate([0,0,rotator_h + rotator_t])
    linear_extrude(rotator_mount_h)
    difference() {
        circle(d = main_hex_d + rotator_mount_t*2);
        hexagon(main_hex_d + tolerance*1.5);
    }

}

module helper() {
    
    difference() {
        cylinder(d = 15, h = 10);
        translate([0,0,-0.2])
        cylinder(d = 5.2, h = 10.4);
        
        translate([-10,-1.5,-0.2])
        cube([20, 3, 10.4]);
    }
    
    translate([0,0,15])
    cylinder(d = 7.2, h = 15, $fn = 6);
    
    hull() {
        translate([0,0,15])
        cylinder(d = 7.2, h = 1, $fn = 6);
        
        translate([0,0,10])
        cylinder(d = 15, h = 1);
    }
    
}

module mount() {
    
    t = 2;
    
    dist = 30;
    hole_dia = 7;
    
    r = sin(30)/sin(120)*dist;

    difference() {

        union() {

            linear_extrude(t)
            hull() {
            
                for (i = [0:2])
                    rotate(i*120)
                    translate([r,0])
                        circle(d = hole_d + t*2);

                translate([-16.5,0])
                    circle(d = axis2_d + t*2);
                
            }
            
            linear_extrude(2.5)
            translate([-16.5,0])
                circle(d = axis2_d + t*2);
            
            linear_extrude(4.5)
                circle(d = axis1_d + t*2);
        }
    
        translate([0,0,-0.1])
        linear_extrude(t+0.2)
        for (i = [0:2])
            rotate(i*120)
            translate([r,0])
                circle(d = hole_dia);
        
        translate([-16.5,0,-0.1])
        linear_extrude(2.7)
        circle(d = axis2_d);
        
        translate([0,0,-0.1])
        linear_extrude(4.7)
        circle(d = axis1_d);
    }
 
    
}

//21.5 - 2 - 2.5

//mount();

//helper();

//rotate([0,0,3])

module assembly() {

    drive_gear();

    #translate([-17,0,-2 + 1]) // -2mm offset + 1mm washer
    rotate([0,0,14])
    ratio_gear();

    translate([0,0,drive_h + 0.5]) // 0.5mm washer
    main_gear();

    cylinder(d = axis1_d, h = 20);

    translate([-17,0,-10])
    cylinder(d = axis2_d, h = 40);
    
}


//ratio_gear();
drive_gear();
//main_gear();
//rotator();

//assembly();


