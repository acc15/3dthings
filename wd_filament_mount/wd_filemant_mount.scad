
$fa = 1;
$fs = 1;

ext_d = 51.2;
t = 2.88;

tol = 0.2;

bearing_ext_dia = 12.5;
bearing_dia = 6.3;
bearing_height = 4.75;
bearing_pad_dia = 7.75;
bearing_pad_height = 1;

bearing_offset = ext_d/2 - t - tol - bearing_ext_dia / 2;

nut_inner_dia = 36.75;
nut_ext_dia = 36.75 * 2 / sqrt(3);
nut_fillet = 8;
nut_thickness = 0.2 * 10;

inner_d = ext_d - t*2 - tol*4 - bearing_ext_dia * 2;

mount_ext_dia = 32; // 33 - tol * 2;

function arc(start, end, steps, closed = true) = [ for (i = [0:closed?steps-1:steps]) let(a = start + (end - start)/steps * i) [ cos(a), sin(a) ] ];

function m_scale(points, amount) = let(s = concat(amount)) [ for (p = points) [ for (i = [0:len(p)-1]) p[i] * (i >= len(s) ? s[len(s)-1] : s[i]) ] ];


module sq_donut(d, dh, t, h) {
    difference() {
        cylinder(d = d, h = h);
        translate([0,0,-h])
        cylinder(d = dh == undef ? d - t*2 : dh, h = 3*h);
    }
}


module bearing() {
    sq_donut(d = bearing_ext_dia, dh = bearing_dia, h = bearing_height);
}

module ext_tube() {
    sq_donut(d = ext_d, t = t, h = 80);
}


module mount_nut() {
    
    linear_extrude(nut_thickness)
    offset(nut_fillet)
    polygon(m_scale(arc(0,360,6,false), (nut_ext_dia / 2 - nut_fillet*2/sqrt(3))));
    
    translate([0,0,nut_thickness])
    sq_donut(d = mount_ext_dia, t = t, h = 20);
    
    
}


module bearing_pad() {
    cylinder(d = bearing_pad_dia, h = bearing_pad_height);
    translate([0,0,bearing_pad_height])
        cylinder(d = bearing_dia - tol*2, h = bearing_height + tol*2);
}

module bearing_holder() {
    
    bd = bearing_pad_dia;
    
    linear_extrude(t)
    difference() {
        circle(r = bearing_offset + bd / 2);
        circle(r = bearing_offset - bd / 2);
    }
    
    for (i = [0:2]) {
        rotate([0,0,i*(360 / 3)])
        translate([bearing_offset,0,t])
        bearing_pad();
    }
        
    
    #for (i = [0:2]) {
        rotate([0,0,i*(360 / 3)])
        translate([bearing_offset,0,t + bearing_pad_height + tol])
        bearing();
    }
    
}


module carve(r, cr, params) { 
    carve_single(0, r, cr, params, [0,0]);
}

module carve_single(i, r, cr, params, pos) {
    if (i >= 0 && i < len(params)) {
        p = params[i];
        echo(i, " p = ", p, "; pos", pos);
        if (i % 2 == 0) {
            
            rotate([0,0,pos[0]])
            translate([r,0,pos[1]])
            if (p != 0) {
                hull() {
                    sphere(r = cr);
                    translate([0,0,p])
                        sphere(r = cr);
                }
            } else {
                sphere(r = cr);
            }
            
            carve_single(i + 1, r, cr, params, [pos[0], pos[1] + p]);
        } else {
            
            rotate([0,0,pos[0]])
            translate([0,0,pos[1]])
            rotate_extrude(angle = p)
            translate([r,0])
            circle(r = cr);
            
            carve_single(i + 1, r, cr, params, [pos[0] + p, pos[1]]);
        }
    } else {
        
        if (i % 2 == 0) {
            rotate([0,0,pos[0]])
            translate([r,0,pos[1]])
                sphere(r = cr);
        }
        
    }
    
}

/*difference() {
    cylinder(r = 20,h=50);
    carve(20, 2, [10, 90, 10, 90, 20, 30, -20, 30, -20, -30]);
}*/



translate([0,0,nut_thickness + 40])
rotate([180,0,0])
bearing_holder();

mount_nut();

*ext_tube();

cylinder(d = inner_d, h = 50);
