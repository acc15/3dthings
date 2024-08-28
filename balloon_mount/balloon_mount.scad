
d_pipe = 16.4;
d_balloon = 5.6;
t = 0.6*2;
tol = 0.2;

$fa=0.2;
$fs=0.2;

d_pipe_inner = d_pipe + tol*2;
d_pipe_outer = d_pipe_inner + t*2;
d_balloon_inner = d_balloon + tol*2;
d_balloon_outer = d_balloon_inner + t*2;

difference() {

union() {

cylinder(d=d_pipe_outer, h = 20);

count = 8;
    
for (i=[0:1:count-1]) {

    rotate([0,0,i*360/count])
    translate([d_pipe_outer/2 - d_balloon_outer/2,0,3])
    rotate([0,30,0])
    linear_extrude(25)
    difference() {
        circle(d=d_balloon_outer);
        circle(d=d_balloon_inner);
    }
}

}

translate([0,0,-1])
cylinder(d=d_pipe_inner,h=100);

}