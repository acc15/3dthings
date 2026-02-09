guide_dia = 4;
guide_length = 10;
hole = [18.8, 6.4];
t = 1.5;
tol = 0.2;

filament_dia = 1.75;

$fa = 0.1;
$fs = 0.1;

frame_t = 3.5;

bolt_dia = 3;

holder_length = 40;

filament_in_dia = 8;
filament_out_dia = filament_dia + tol * 2;
filament_h = (filament_in_dia - filament_out_dia) / 2;

full_height = guide_length * 2 + t + filament_h;

tube_diff = (full_height - hole[0]);

fillet = 1;

module foot_base(l) {
    linear_extrude(l)
    offset(fillet)
    offset(-fillet)
    square(hole);
}

module mount() {

    linear_extrude(t)
    offset(5)
    square(hole);

    translate([0,0,t])
    foot_base(frame_t);

}

//mount();

function arc(a, n, r, d, l = true) = let(
    angle = len(a) == undef ? [0, a] : a,
    radius = d == undef 
        ? (r[0] == undef ? [r, r] : r) 
        : (d[0] == undef ? [d/2,d/2] : d / [2,2])
) [ for (i = [0:l ? n : n-1]) let(ca = angle[0] + i * (angle[1] - angle[0]) / n) [cos(ca) * radius[0], sin(ca) * radius[1]] ];

polygon(arc([0,180], 100, 5));


/*

module holder_foot() {

    difference() {

        translate([0,-hole[1]/2,hole[0]])
        rotate([0,90,0])
        foot_base(holder_length);

        translate([holder_length+tol,0,hole[0]/4 * 1])
        rotate([0,-90,0])
        cylinder(d = bolt_dia, h = 20 - frame_t);

        translate([holder_length+tol,0,hole[0]/4 * 3])
        rotate([0,-90,0])
        cylinder(d = bolt_dia, h = 20 - frame_t);
        
        
    }
    
}

module filament_guide_holder() {

    translate([0,0,hole[0]])
    rotate([180,0,0])
    difference() {

       union() {
            holder_foot();
            
            translate([0,0,1 - tube_diff])
            minkowski() {
                sphere(d = 2);
                cylinder(d = filament_in_dia + t * 2 - 2, h = full_height - 2);
            }

        }

        translate([0,0,-tube_diff])
        union() {

            cylinder(d1 = filament_in_dia, d2 = filament_out_dia, h = filament_h);
            translate([0,0,filament_h])
            cylinder(d1 = filament_out_dia, d2 = guide_dia, h = t);

            translate([0,0,filament_h + t])
            cylinder(d = guide_dia, h = guide_length);

            translate([0,0,filament_h + t + guide_length])
            cylinder(d1 = guide_dia, d2 = guide_dia + tol * 2, h = guide_length + tol*2);
        }
    }

}

//holder_foot();

translate([0,20,0])
filament_guide_holder();

mount();
*/






