include <tinylib.scad>

dim = [22,15,15];
t = 1.2;
hole_s = 9;
hole_b = 8;
sep = 14;

tol = 0.2;
wall = 6;
inset = 10;

diff_tol = 1;

function profile_rect(r = 0,inset = 0) = p_translate([-inset,-inset], rect([dim[0] + inset * 2, dim[1] + inset * 2], r));

profile_internal = [
    [dim[0],dim[1] / 2 - hole_s / 2],
    [dim[0] - t, dim[1] / 2 - hole_s / 2],
    [dim[0] - t, t],
    [sep, t],
    [sep, dim[1] - t],
    [dim[0] - t, dim[1] - t],
    [dim[0] - t, dim[1] / 2 + hole_s / 2],
    [dim[0], dim[1] / 2 + hole_s / 2]
];

function profile(internal = true) = concat([
    [0,0],[dim[0],0], 
    ], internal ? profile_internal : [], [
    [dim[0], dim[1]],
    [0, dim[1]],
    [0, dim[1] / 2 + hole_b / 2],
    [t, dim[1] / 2 + hole_b / 2],
    [t, dim[1] - t],
    [sep - t, dim[1] - t],
    [sep - t, t],
    [t, t],
    [t, dim[1] / 2 - hole_b / 2],
    [0, dim[1] / 2 - hole_b / 2]
]);

module profile3d() {
    linear_extrude(dim[2]) 
        polygon(profile);
}

module profile_base() {
    
    linear_extrude(dim[2])
        offset(delta = tol + wall + inset)
            polygon(profile_rect(0));
}

module profile_cutter() {
    
    w = max(dim[0],dim[1]) + (tol + inset + wall) * 3.5;
    
    translate([0,0,0]) {
        translate([0,0,inset + wall])
            rotate([0,90,0]) 
                cylinder(r = inset, h = w, $fn = 64);
        translate([0,-inset,-diff_tol]) cube([w, inset, inset + wall + diff_tol]);
        translate([0,-inset,inset+wall])
            cube([w, inset * 2, dim[2] - (inset + wall) + diff_tol]);
    }
    
}


module mount_direct() {
    path = profile_rect(inset/2, tol + wall + inset, $fn = 16);
    difference() {
        profile_base();
        
        clone_by_2d_path(path)
            profile_cutter();
        
        translate([0,0,wall])
            linear_extrude(dim[2])
                offset(tol, $fn = 32)
                    polygon(profile());
        
        td = (tol + wall + 3.5);
        
        translate([-td,-td,0])
            bolt($fn = 32);
        translate([dim[0]+td,-td,0])
            bolt($fn = 32);
        translate([-td,dim[1]+td,0])
            bolt($fn = 32);
            translate([dim[0]+td,dim[1]+td,0])
            bolt($fn = 32);
        
        translate([sep / 2 - (5 + tol * 2) / 2,dim[1]/2,10])
            nut_diff();
            
        translate([-5, dim[1]/2,10])
        rotate([0,90,0])
            cylinder(d = 5, h = 18, $fn = 32);
    }
}

module nut() {
    translate([0,0,-tol])
    linear_extrude(5 + tol * 2)
        ngon(6, 4.5 + tol);
}

module nut_diff() {
    rotate([0,90,0]) {
        hull() {
            translate([-20,0,0]) nut();
            nut();
        }
        translate([0,0,-10])
        cylinder(d = 5, h = wall + tol + sep + diff_tol * 2, $fn = 32);
    }
}

module bolt() {
    $fn = 64;
    translate([0,0,wall/2+2.75-0.01])
        cylinder(r = 5, h = dim[2]);
    translate([0,0,wall/2])
        cylinder(r1 = 2, r2 = 5, h = 2.75);
    translate([0,0,-diff_tol])
        cylinder(r = 2, h = wall + diff_tol * 2);
}

module mount_angle(a) {

    add = tol + wall;
    brick_dim = [dim[0] + add * 2, dim[1] + add * 2, dim[2]];
        
    h_add = brick_dim[1] * tan(a);
    width = norm([brick_dim[1], h_add]);
    
    inset_dim = [brick_dim[0] + inset * 2, width + inset * 2, wall];
    
    w_add = wall * tan(a);
    
    
    union() {

        difference() {
            translate([-inset, -inset, -wall])
                linear_extrude(wall)
                    polygon(rect(inset_dim, 5));
            translate([-inset / 2, -inset/2, -3])
                bolt();
            translate([brick_dim[0] + inset / 2, -inset/2, -3])
                bolt();
            translate([-inset / 2, width + inset / 2, -3])
                bolt();
            translate([brick_dim[0] + inset / 2, width + inset / 2, -3])
                bolt();
        }
            
        difference() {
            rotate([a,0,0]) {
                difference() {
                    translate([0,0,-h_add])
                        cube([brick_dim[0],brick_dim[1],brick_dim[2] + h_add]);
                    
                    translate([add, add, -w_add])
                        linear_extrude(brick_dim[2] + diff_tol + w_add)
                            offset(tol)
                                polygon(profile());
                    translate([wall + tol + sep / 2 - 2.5 - tol, brick_dim[1] / 2, dim[2] - (4.5+tol * 3)])
                        nut_diff();
                }            
            }
            translate([-diff_tol, -diff_tol, -100 - diff_tol])
                cube([brick_dim[0] + diff_tol * 2, width + diff_tol * 2, 100]);
            
        }
        
    }
                

    
}

//rotate([90,-90,180])

//mount_angle(30);
//polygon(profile_internal);

module curved_profile(internal = true) {
    
    r = 70;
    a = 60;
    spacing = 20;
    
    mount_length = 20;

    module profile_mount(l) {
        union() {
            translate([0,0,spacing - diff_tol])
                curved_profile_mount(mount_length + diff_tol);  
            linear_extrude(spacing)
                polygon(profile(internal));
            
            if (l) 
                wall_mount();
            else
                translate([0,dim[1],spacing])
                rotate([180,0,0])
                    wall_mount();
        }
    }

    module wall_mount() {
        translate([dim[0] - wall, dim[1],0])
            cube([wall, 125 - dim[1], spacing]);
        
        translate([dim[0] - 66,125 - wall,0])
        difference() {
            cube([66, wall, spacing]);
          
            translate([12,wall,spacing/2])
                rotate([90,0,0])
                    bolt();
            translate([36,wall,spacing/2])
                rotate([90,0,0])
                    bolt();
        }
        
        translate([0,dim[1],spacing / 2 - wall / 2])
        cube([dim[0],125 - dim[1],wall]);
        
    }
    
    
    //wall_mount();
    
    //profile_mount();

    
    union() {
        translate([r,0,0])
            rotate([0,-90,-90]) 
                profile_mount(true);

        rotate([0,0,-a])
            translate([r + dim[1],0,0])
                rotate([0,-90,90]) 
                    profile_mount(false);

        rotate_extrude(angle = -a, $fn = 256)
            translate([r + dim[1],0,0])
                rotate([0,0,90])
                    polygon(profile(internal));
    }
    
}

module curved_profile_mount(l) {
    
    dia = 5.2;
       
    difference() {
        linear_extrude(l)
            polygon(profile_internal);
            
        translate([sep-diff_tol,dim[1]/2,l - dim[1]/2])
            rotate([0,90,0])
                cylinder(d = dia, h = sep, $fn = 64);
        
        translate([sep+t,dim[1]/2,l - dim[1]/2])
            nut_diff();
    }
       
}



//curved_profile_mount(20);

curved_profile(false);

