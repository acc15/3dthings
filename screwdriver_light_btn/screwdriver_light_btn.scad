
$fa = 0.2;
$fs = 0.2;




btn_d = 6.4;
btn_h = 5;
btn_pin_offset = 6;
btn_pin_d = 2;

sm_dim = [2.2, 2.7, 2.5];
se_dim = [3, 4, 2.5];

difference() { 
union() {
cylinder(d = btn_d, h = btn_h);
    linear_extrude(1)

difference() {
hull() {
translate([-btn_pin_offset,0,0])
circle(d = 4);

circle(d = btn_d);

translate([btn_pin_offset,0,0])
circle(d = 4);
}
    
    translate([-btn_pin_offset,0])
        circle(d = btn_pin_d);

    translate([btn_pin_offset,0])
        circle(d = btn_pin_d);
}
}

translate([0,0,-0.5]) {

union() {
translate([-sm_dim[0]/2, -sm_dim[1]/2,se_dim[2]])
cube(sm_dim);
translate([-se_dim[0]/2, -se_dim[1]/2,0])
cube(se_dim);
}
}

}

