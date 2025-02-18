hole_dim = [18.6, 6.4];

frame_t = 3;
tol = 0.2;

bolt_dia = 3;
bolt_head_dia = bolt_dia + 2;

guide_dia = 4.0;
foot_length = 50;

t = 2;

foot_dim = [hole_dim[1] + tol * 2 + t * 3, foot_length];

$fa = 0.1;
$fs = 0.1;

module mount_bolt_holes() {

    translate([-hole_dim[1]/2 - tol*2 - t*1.5,bolt_head_dia*2,hole_dim[0] / 4 * 1])
    rotate([0,90,0])
    cylinder(d = bolt_dia, h = hole_dim[1] + tol * 4 + t * 3);

    translate([-hole_dim[1]/2 - tol*2 - t*1.5,bolt_head_dia*2,hole_dim[0] / 4 * 3])
    rotate([0,90,0])
    cylinder(d = bolt_dia, h = hole_dim[1] + tol * 4 + t * 3);

}

module mount() {
    
    rotate([-90,0,0]) {

        translate([-hole_dim[1]/2,-hole_dim[0],-t-frame_t])
        linear_extrude(t)
        offset(5)
        square([hole_dim[1], hole_dim[0]]);

        translate([-hole_dim[1]/2,-hole_dim[0],-frame_t])
        linear_extrude(frame_t)
        square([hole_dim[1], hole_dim[0]]);
    }

    render()
    difference() {
        linear_extrude(hole_dim[0])
            mount_shape();
        mount_bolt_holes();
    }

}

module mount_shape() {
    translate([-hole_dim[1]/2,0])
    square([hole_dim[1], hole_dim[0]]);
}



module foot() {
    render()
    difference() {    
        linear_extrude(hole_dim[0])
        difference() {
            
            union() {
                translate([-hole_dim[1]/2 - tol - t*1.5,0])
                    square(foot_dim);
                
                translate([0,foot_dim[1]])
                circle(d = foot_dim[0]);
            }
            
            translate([0,foot_dim[1]])
            circle(d = guide_dia + tol*2);
            
            offset(tol)
                mount_shape();
        }
        mount_bolt_holes();
    }
}

*rotate([90,0,0])
mount();

rotate([0,180,0])
foot();

echo(foot_dim[0]);

