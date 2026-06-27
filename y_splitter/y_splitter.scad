$fa = 0.5;
$fs = 0.5;

bolt_head_d = 5.4;
bolt_head_h = 3;
bolt_d = 3;
bolt_nut_d = bolt_head_d * 2/sqrt(3);
bolt_nut_h = 2;

d1 = 5;
d2 = 2.5;

distance = 10;
length = 15;

thickness = 1.5;
add1 = 5;
add2 = 5;

dia = (distance*distance/4 + length*length) / distance;
angle = asin(length/dia);
cross_height = sqrt(dia/2*d2 + d2*d2/4);

bolt_lengths = [4,8,12,16,20,30];
function compute_thickness(min_thickness, i=0) = i >= len(bolt_lengths) ? min_thickness :
    min_thickness < (bolt_lengths[i] + bolt_head_h) 
        ? bolt_lengths[i] + bolt_head_h 
        : compute_thickness(min_thickness, i + 1);


dim = [
    distance + thickness*2 + d1,
    compute_thickness(d1+thickness*2),
    add1 + length + add2
];

module leaf() {
    
    rotate([90,0,0]) {
    
        translate([-dia/2,0])
        rotate_extrude(angle=angle+0.01)
        translate([dia/2,0])
        circle(d = d2);

        translate([dia/2-distance/2,length])
        rotate([0,0,180])
        rotate_extrude(angle=angle)
        translate([dia/2,0])
        circle(d = d2);
        
    }
    
}


module leafs() {

    leaf();
    mirror([1,0,0])
    leaf();
    
    hull() {
        translate([0,0,-1])
        cylinder(d = d1, h = 2);
        translate([0,0,cross_height - 1])
        hull() {
            translate([-d2/2,0,0])
            cylinder(d = d2, h = 1);
            translate([d2/2,0,0])
            cylinder(d = d2, h = 1);
        }
    }

    
    *hull() {
        translate([-dia/2,0])
        rotate_extrude(angle=d1_angle)
        translate([dia/2,0])
        circle(d = d1);

        translate([dia/2,0])
        rotate([0,0,180])
        rotate_extrude(angle=-d1_angle)
        translate([dia/2,0])
        circle(d = d1);
    }

    
    *rotate([90,0,0])
    hull()
    intersection() {

        union() {
            translate([-dia/2,0])
            rotate_extrude(angle=d1_angle)
            translate([dia/2,0])
            circle(d = d1);

            translate([dia/2,0])
            rotate([0,0,180])
            rotate_extrude(angle=-d1_angle)
            translate([dia/2,0])
            circle(d = d1);
        }
        
        translate([-distance/2-d1/2-thickness,0,-d1/2-thickness])
        cube([distance + thickness*2 + d1,sin(d1_angle)*(dia/2-d1/2), d1+thickness*2]);
    }
    
}

module chamfer_square(sz) {
    chamfer = min(sz[0], sz[1])/4;
    offset(delta=chamfer,chamfer=true)
    offset(-chamfer)
    square(sz, center=true);
}


module add_diff(d, h, v = thickness, z = undef, zh = 2) {
    z = z == undef ? 0.75 : z;
    rotate_extrude() 
    union() {
        difference() {
            square([d/2, h+0.1]);
            for (i=[1:floor(h/zh)]) {
                translate([d/2-z,i*zh]) {
                    polygon([[z,0],[z+1,0],[z+1,z],[0,z]]);
                }
            }
        }
        difference() {
            translate([0,-0.1])
            square([d/2 + v, v+0.1]);
            translate([d/2+v,v])
            circle(v, $fa = 0.2, $fs=0.2);
        }
    }
}

*add_diff(d2, add1);

module bolt_diff(l,tol) {
    rotate([0,0,30]) {
        translate([0,0,-tol])
        cylinder(d = bolt_head_d+tol*2, h = bolt_head_h+tol*2);
        cylinder(d = bolt_d+tol*2, h = l);
        translate([0,0,l-bolt_nut_h-tol])
        cylinder(d = bolt_nut_d+tol*2, h = bolt_nut_h+tol*2, $fn=6);
    }
}


module y_splitter() {
    difference() {
        linear_extrude(add1)
        chamfer_square([dim[1], dim[1]]);
        add_diff(d1, add1);
    }

    translate([0,0,add1])
    difference() {
        
        union() {
        
            hull() {
                linear_extrude(1)
                chamfer_square([dim[1], dim[1]]);

                translate([0,0,length])
                linear_extrude(1)
                chamfer_square([dim[0], dim[1]]);
            }

            translate([0,0,length])
            linear_extrude(add2)
            chamfer_square([dim[0], dim[1]]);
            
        }

        leafs();
        
        translate([0,0,length+add2]) {
            translate([-distance/2,0,0])
            mirror([0,0,1])
            add_diff(d2, add2);
            translate([distance/2,0,0])
            mirror([0,0,1])
            add_diff(d2, add2);
        }
        
        translate([0,dim[1]/2,cross_height+bolt_head_d])
        rotate([90,0,0])
        bolt_diff(dim[1],0.2);

        
    }
}

module y_splitter_part(top) {
    translate([0,0,dim[1]/2])
    rotate([top?90:-90,0,0])
    translate([0,0,1])
    intersection() {
        y_splitter();
        translate([-dim[0]/2,top?-dim[1]/2:0,0])
        cube([dim[0], dim[1]/2, dim[2]]);
    }
}

module y_splitter_parts() {
    y_splitter_part(false);
    y_splitter_part(true);
}

*y_splitter();
y_splitter_parts();

echo(bolt_length = dim[1] - bolt_head_h);



