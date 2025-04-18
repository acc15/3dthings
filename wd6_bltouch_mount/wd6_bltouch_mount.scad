
use <../bendlib/bendlib.scad>;

off = 6;
hole_dist = 24;
hole_dia = 3.4;
bolt_offset = 0;
fillet = 3;
t = 0.48*7;

mx = hole_dist+off*2;
my = bolt_offset + off*2;

bx = 26;
bl = 12;
b_hole_dist = 18;

bolt_length = 11 + 3; // 3mm head

bltouch_h = 36.3 + 5.5 + 3;
mount_h = 58 - t - my/2;

wireholder_inner_dia = 8;
wireholder_outer_dia = wireholder_inner_dia + t*2;
wireholder_position = [mx + wireholder_outer_dia/2,wireholder_outer_dia/2];

$fa = 0.1;
$fs = 0.1;


module bltouch_mount() {

    union() {
        translate([0,t,t])
        rotate([90,0,0])
        linear_extrude(t)
        difference() {
            bl_rect([wireholder_position[0], bolt_offset + off*2], [0,fillet,0,0]);
            translate([off, off]) {
                circle(d = hole_dia);
                
                translate([hole_dist, 0])
                circle(d = hole_dia);
            }
        }

        linear_extrude(t)
        difference() {
            hull() {
                square([mx, t]);
                translate([(mx - bx)/2,0])
                offset(fillet)
                offset(-fillet)
                square([bx, bl + off + t]);
                
                translate(wireholder_position)
                circle(d = wireholder_outer_dia);
            }
            translate([mx / 2 - b_hole_dist/2, (bl / 2) + off + t]) {
                circle(d = hole_dia);
                
                translate([b_hole_dist,0])
                circle(d = hole_dia);
            }
            translate(wireholder_position)
            circle(d = wireholder_outer_dia);
        }
        
        
        translate(wireholder_position)
        rotate([0,0,30])
        rotate_extrude(angle = 300)
        translate([wireholder_inner_dia/2,0])
        square([t, my+t]);
                
    }

}

echo(bltouch_h = bltouch_h, mount_h = mount_h, h_dist = mount_h - bltouch_h);



//translate([0,0,58 - t - my/2])
bltouch_mount();

*translate([mx/2,bl/2 + t + off,bltouch_h])
rotate([180,0,180])
import("bltouch.stl");






    
