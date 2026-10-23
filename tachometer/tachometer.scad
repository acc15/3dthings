$fa = 0.5;
$fs = 0.5;

motor_d = 20;
motor_w = 15;
motor_l = 25;

axis_d = 2;
axis_l = 4;

led_d = 5;
thickness = 2;
height = axis_l + thickness;

d = motor_w + led_d * 2 + thickness*2;

linear_extrude(thickness)
difference() {
    circle(d = d + thickness*2);
    translate([motor_w/2 + led_d/2,0])
    circle(d = led_d);
}


linear_extrude(height)
union() {
    difference() {
        circle(d = d+thickness*2);
        circle(d = d);
    }

    difference() {
        circle(d = axis_d + thickness*2);
        circle(d = axis_d);    
    }
}