use <bendlib/bendlib.scad>;

$fa = 0.2;
$fs = 0.2;

ring_inner_d = 14;
ring_outer_d = 18;
ring_d = (ring_outer_d - ring_inner_d) / 2;

adapter_inner_d = 3.2;
adapter_outer_d = ring_inner_d + ring_d;
adapter_height = 6;
adapter_thickness = (adapter_height - ring_d) / 2;

adapter_spring_d = 13.7;
adapter_spring_h = 1.2;

echo(d=adapter_outer_d, h=adapter_height);


rotate_extrude()
polygon(concat(
    [
        [adapter_inner_d/2, 0],
        [adapter_outer_d/2, 0]
    ],
    bl_arc(ring_d/2, angle=[90, 270], position=[adapter_outer_d/2, adapter_thickness+ring_d/2]),
    [
        [adapter_outer_d/2, adapter_height],
        [adapter_spring_d/2, adapter_height],
        [adapter_spring_d/2, adapter_height+adapter_spring_h],
        [adapter_inner_d/2, adapter_height+adapter_spring_h]
    ]
));

