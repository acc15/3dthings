


hook_l = 10;
h = 20;
t = 4;

mount_d = 21;
mount_a = 35;

base_l = 60;
base_w = 8;

$fa = 0.4;
$fs = 0.4;

module hook(k) {

    rotate([90,0,-90])
    linear_extrude(k)
    difference() {
        union() {
            
            square([hook_l+t/2, h - t/2]);
            
            translate([hook_l+t/2,t/2])
            square([t/2, h-t]);
            
            translate([hook_l+t/2,t/2])
            circle(d = t);
            
            translate([hook_l+t/2,h-t/2])
            circle(d = t);
                
        }
        union() {
            translate([-t/2,t])
                square([hook_l, h - t]);
            
            translate([0,t*1.5])
                square([hook_l, h - t]);
            
            translate([hook_l-t/2, t*1.5])
            circle(d = t);
            
        }
    }
}

module base() {

    rotate([0,0,-90-mount_a])
    rotate_extrude(angle = 180 + mount_a*2)
    translate([mount_d/2, 0])
    square([t,h]);
    
    
    rotate([0,0,90-mount_a])
    translate([-mount_d/2-t/2,0,0])
    cylinder(d = t, h = h);
    
    rotate([0,0,-90+mount_a])
    translate([-mount_d/2-t/2,0,0])
    cylinder(d = t, h = h);

    module base_shape() {    
        union() {
            square([t,h-t/2]);
            translate([t/2, h-t/2])
                circle(d = t);
        }
    }
    
    
    translate([mount_d/2,-base_w/2,0])
    cube([base_l, base_w, t]);
    
    
    
    difference() {
    translate([mount_d/2,-t/2,0])
    cube([h*2-t*2, t, h-t/2]);
    
    translate([mount_d/2 + h*2 - t*2-0.2,t/2+0.1,h - t/2])
    scale([2.0,1,1])
    rotate([90,0,0])
    cylinder(r = h-t*1.5, h = t+0.2);
    }
    
}

base();


translate([mount_d/2 + base_l/2,0,0])
hook(t);

translate([mount_d/2 + base_l,0,0])
hook(t);


translate([mount_d/2 + base_l/2 - t,0,0])
rotate([0,0,180])
hook(t);

translate([mount_d/2 + base_l - t,0,0])
rotate([0,0,180])
hook(t);

translate([mount_d/2 + base_l,base_w/2,0])
rotate([0,0,90])
hook(base_w);