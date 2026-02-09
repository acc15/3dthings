$fa = 0.2;
$fs = 0.2;

t = [0.4*5, 0.4*5, 0.2*10];
d1 = 40;
d2 = 80;
h = 20;
tolerance=0.2;
w = 1.6 + tolerance*2;

module ring(d_ext, d_int) {
    difference() {
        circle(d = d_ext);
        circle(d = d_int);
    }
}

module spool_part(d1, d2, h) {
    linear_extrude(t[2])
    ring(d2, d1 - t[0]*2);

    linear_extrude(h + t[2])
    ring(d1, d1 - t[0]*2);
}

module part1() {
    difference() {
        spool_part(d1, d2, h);
        translate([0,0,t[2]+h-w/2])
        rotate([0,90,0])
        union() {
            cylinder(d = w,h=d2/2);
            translate([-w/2-1,-w/2,0])
            cube([w/2+1,w,d2/2]);
        }
    }
}

module part2() {
    d_ext = d1-t[0]*2-tolerance*2;

    difference() {
        spool_part(d_ext, d2, h+t[2]);

        translate([0,0,t[2]+w/2])
        rotate([0,90,0])
        cylinder(d = w,h=d2/2);
    }
    
    rotate([0,0,30])
    rotate_extrude(angle=60)
    translate([d_ext/2,0])
    rotate(90)
    clip_shape();
    
    for (i=[0:2]) {
        rotate([0,0,i*120+45])
        rotate_extrude(angle=30)
        translate([d2/2-t[0]*2-w,0])
        clip_shape();
    }
}

module clip_shape() {
    difference() {
        union() {
            translate([w/2+t[0],w/2+t[1]])
            circle(d = w + t[0]*2);
            
            square([w + t[0]*2, w/2+t[1]]);
        }
        translate([w/2+t[0],w/2+t[1]])
        circle(d=w);
    }
}

part1();

/*translate([0,0,t[2]*2+h])
mirror([0,0,1])*/

translate([d2+tolerance*2,0,0])
part2();

