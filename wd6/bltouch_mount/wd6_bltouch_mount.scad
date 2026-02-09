
use <../bendlib/bendlib.scad>;

off = 6;
hole_dist = 24;
hole_dia = 3.4;
bolt_offset = 0;
fillet = 3;
xy_thickness = 0.48*4;
z_thickness = 0.2*10;
mount_thickness = 3.4;
//t = 0.48*7;

mx = hole_dist+off*2;
my = bolt_offset + off*2;

bx = 26;
bl = 12;
b_hole_dist = 18;

bolt_length = 11 + 3; // 3mm head

wireholder_inner_dia = 8;
wireholder_outer_dia = wireholder_inner_dia + xy_thickness*2;
wireholder_position = [mx + wireholder_outer_dia/2,wireholder_outer_dia/2];
wireholder_open_distance = 4;
wireholder_open_angle = asin( (wireholder_open_distance/2+xy_thickness/2) / (wireholder_inner_dia/2+xy_thickness/2) );

// ((a + b) / 2) 
// -------------
// ((c + b) / 2)

$fa = 0.1;
$fs = 0.1;


module bltouch_mount() {

    union() {
        translate([0,xy_thickness,z_thickness])
        rotate([90,0,0])
        difference() {
            union() {
                linear_extrude(xy_thickness)
                bl_square([wireholder_position[0], bolt_offset + off*2], [0,fillet,0,0]);
                
                h = mount_thickness - xy_thickness;
                
                translate([off, off, -h]) {
                    cylinder(d1 = hole_dia + xy_thickness*2, d2 = hole_dia + xy_thickness * 2 + h*2, h = h);
                    
                    translate([hole_dist, 0])
                    cylinder(d1 = hole_dia + xy_thickness*2, d2 = hole_dia + xy_thickness * 2 + h*2, h = h);
                }
            }
            #translate([off, off, xy_thickness - mount_thickness - 1]) {
                cylinder(d = hole_dia, h = mount_thickness + 2);
                
                translate([hole_dist, 0])
                cylinder(d = hole_dia, h = mount_thickness + 2);
            }
        }
        
        linear_extrude(z_thickness)
        difference() {
            hull() {
                square([mx, mount_thickness]);
                
                translate([(mx - bx)/2,0])
                bl_square([bx, bl + off + mount_thickness], [fillet, fillet, 0, 0]);
                
                translate(wireholder_position)
                circle(d = wireholder_outer_dia);
            }
            translate([mx / 2 - b_hole_dist/2, (bl / 2) + off + mount_thickness]) {
                circle(d = hole_dia);
                
                translate([b_hole_dist,0])
                circle(d = hole_dia);
            }
            translate(wireholder_position)
            circle(d = wireholder_outer_dia);
        }
        
        translate([mx/2 - xy_thickness/2,0,0])
        rotate([90,0,90])
        linear_extrude(xy_thickness)
        polygon([[0,0], [bl + off + mount_thickness,0],[bl + off + mount_thickness,z_thickness],[xy_thickness, bolt_offset + off*2 + z_thickness], [0,bolt_offset + off*2+ z_thickness]]);

        


        translate(wireholder_position)
        union() {
            rotate([0,0,wireholder_open_angle])
            translate([wireholder_inner_dia / 2 + xy_thickness / 2,0,0])
            cylinder(d = xy_thickness, h = my+z_thickness);
            
            rotate([0,0,-wireholder_open_angle])
            translate([wireholder_inner_dia / 2 + xy_thickness / 2,0,0])
            cylinder(d = xy_thickness, h = my+z_thickness);
            
            rotate([0,0,wireholder_open_angle])
            rotate_extrude(angle = 360 - wireholder_open_angle*2)
            translate([wireholder_inner_dia/2,0])
            bl_square([xy_thickness, my+z_thickness], [0,0,xy_thickness,0], $fn = 8);
        }
            
        *translate(wireholder_position)
        translate([0,-wireholder_open_distance/2])
        square([10, wireholder_open_distance]);
        
    }

}



//translate([0,0,58 - z_thickness - my/2])
bltouch_mount();


bltouch_h = 36.3 + 5.5 + 3;
*translate([mx/2,bl/2 + xy_thickness + off,bltouch_h])
rotate([180,0,0])
import("bltouch.stl");






    
