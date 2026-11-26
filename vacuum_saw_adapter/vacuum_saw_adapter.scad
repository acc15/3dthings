vacuum_ext_d = 35;
saw_inner_d = 27;

t = 1.2;
l = 10;

$fa = 0.2;
$fs = 0.2;

rotate_extrude()
polygon([
    [saw_inner_d/2 + t, 0],
    [saw_inner_d/2 + t, t],
    [saw_inner_d/2, t*2],
    [saw_inner_d/2, t*3],
    [saw_inner_d/2+t, t*4],
    [saw_inner_d/2+t, l],
    [vacuum_ext_d/2+t, l*2],
    [vacuum_ext_d/2+t, l*3],
    [vacuum_ext_d/2+t, l*3],
    [vacuum_ext_d/2,l*3],
    [vacuum_ext_d/2,l*2],
    [saw_inner_d/2-t,l],
    [saw_inner_d/2-t,0]
]);

