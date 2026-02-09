    
$fs = 0.5;
$fa = 3;

max_spool_thickness = 8;

bearing_dia = 12.75;
bearing_inner_dia = 6.30;
bearing_height = 4.75;
wheel_dia = 30;
wheel_t = 1.2;
wheel_height = wheel_t*2 + max_spool_thickness;
wheel_tolerance = 0.1;

base_wheel_distance = 140;
base_thickness = 0.48 * 6;
base_wheel_offset = 10;
base_wheel_spacing = 3;
base_wheel_hole = 6.3;
base_mount_hole = 6.3;
base_wheel_tolerance = 0.2;

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

module wheel() {

    r = bearing_dia/2 + wheel_tolerance;
    w = wheel_dia/2 - r;
    s = (wheel_height - bearing_height)/2;

    rotate_extrude()
    translate([r,0])        
    difference() {

        polygon([[0, s], [s, 0], [w, 0], [w,wheel_height], [s,wheel_height], [0, s + bearing_height]]);

        translate([w, wheel_height/2])
        circle(d = max_spool_thickness);
    }

}

module bearing() {

    difference() {
        cylinder(d = bearing_dia, h = bearing_height);
        translate([0,0,-0.1])
        cylinder(d = bearing_inner_dia, h = bearing_height + 0.1 * 2);
    }
    
}

module base_shape(dia, off, hole) {
    
    d = base_wheel_distance + wheel_dia - dia;
    w = d / 2;
    
    or = wheel_dia/2;
    wr = dia / 2;
    o = off;
    h = hole;
    r = (w*w + 2*wr*o + o*o) / (4*wr + 2*o);
    t = base_thickness;
    a = acos(w / (r + wr));
    
    difference() {
    
        polygon(concat(
            arc([0,180-a], r = wr, p = [d + wr,t + o + wr]), 
            arc([360-a,180+a], r = r, p = [w + wr,t + r]), 
            arc([a,180], r = wr, p =[wr,t + o + wr]),
            [[0,0], [d + dia,0]]
        ));

        translate([wr, o + t + wr])
        circle(d = h);
        
        translate([wr + d, o + t + wr])
        circle(d = h);
    }
       
}

module base_holder() {
    translate([0,base_thickness,0])
    rotate([90,0,0])
        linear_extrude(base_thickness)
            base_shape(wheel_dia, base_wheel_offset, base_wheel_hole);
}

module wheel_spacer() {
    
    w = (bearing_dia - base_wheel_hole)/2;
    s = (wheel_height - bearing_height)/2;

    rotate_extrude()
    translate([base_wheel_hole/2,0])
    polygon([[0,0], [w, 0], [w, base_wheel_spacing], [w - s, base_wheel_spacing + s], [0, base_wheel_spacing + s]]);
    
}

module spool(dia, width) {
    
    id = 52;
    t = 5;
    
    difference() {
        union() {
            cylinder(d = dia, h = t);
            
            translate([0,0,width - t])
            cylinder(d = dia, h = t);
            
            cylinder(d = id + t, h = width);
        }
        translate([0,0,-1])
        cylinder(d = id, h = width + 2);
    }
}

module wheel_with_spacers() {
    
    wheel();
    
    translate([0,0, -base_wheel_spacing - base_wheel_tolerance])
    wheel_spacer();
    
    translate([0,0,wheel_height + base_wheel_spacing + base_wheel_tolerance])
    rotate([180,0,0])
    wheel_spacer();
    
    translate([0,0,(wheel_height - bearing_height)/2])
    #bearing();
    
}

module base_mount() {
    base_shape(base_mount_hole + base_thickness*2, 0, base_mount_hole);
}

module base() {
    
    l = base_wheel_tolerance*4 + base_wheel_spacing*2 + wheel_height + base_thickness*2;
    wr = wheel_dia / 2;
    
    base_holder();
    
    translate([0,l - base_thickness,0])
    base_holder();

    linear_extrude(base_thickness) {

        translate([0, l - base_thickness])
            base_mount();
        
        translate([0, base_thickness])
            mirror([0, 1])
                base_mount();
        
        square([wheel_dia + base_wheel_distance, l]);
    }
    
}

module base_with_wheels() {
    
    wr = wheel_dia/2;
    wtol = base_wheel_tolerance;
    wo = base_wheel_offset;
    ws = base_wheel_spacing;
    wd = base_wheel_distance;
    t = base_thickness;
    
    translate([wr,wtol*2 + ws + t,wo + t + wr]) {
        
        rotate([-90,0,0])
        wheel_with_spacers();

        translate([wd,0,0])
        rotate([-90,0,0])
        wheel_with_spacers();

    }

    base();
    
}

module all(spool_dia, spool_width) {

    wr = wheel_dia/2;
    wd = base_wheel_distance;
    wo = base_wheel_offset;
    ws = base_wheel_spacing;
    wh = wheel_height;
    t = base_thickness;
    wtol = base_wheel_tolerance;
    
    base_with_wheels();

    translate([0, spool_width - 5, 0])
    base_with_wheels();

    translate([wr + wd/2,t+ws+wtol*2+(wh-5)/2,115])
    rotate([-90,0,0])
    spool(spool_dia, spool_width);

}

//wheel_spacer();
//wheel();

//all(188, 80);
//all(202, 56);

//base();
//wheel_with_spacers();

