
$fa = 0.5;
$fs = 0.5;

d_spool = 80;
d_bolt = 8;
d_nut = 12.8 * 2/sqrt(3);
h_nut = 6.5;
h = 30;
t = 5;
rounding = 2;

echo(d_nut);

module circles() {
    for (i = [0:2]) {
        rotate([0,0,120*i])
        translate([d_spool, 0, -1])
        circle(d = d_spool*1.5);
    }
}

difference() {

    intersection() {
        rotate_extrude() {
            polygon([ 
                [d_bolt / 2, 0],
                [d_spool/2, 0],
                [d_spool/2, h/5],
                [d_bolt, h],
                [d_bolt/2, h]
            ]);
        }

        linear_extrude(h)
        offset(rounding)
        offset(-rounding)
        difference() {
            circle(d = d_spool);
            circles();
        }
    }
    
    #translate([0,0,-1])
    linear_extrude(h+2) {
    
        offset(rounding)
        offset(-t-rounding)
        difference() {
            circle(d = d_spool);
            circles();
            circle(d = d_nut);
        }
    
    }
    
    translate([0,0,-1])
    linear_extrude(h_nut+1)
    offset(rounding)
    offset(-rounding)
    rotate(30)
    circle(d = d_nut, $fn = 6);
}

