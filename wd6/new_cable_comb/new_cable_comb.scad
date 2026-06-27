
$fa = 0.2;
$fs = 0.2;

layers = [
    [0,[[-90,5]]],
    [
        6,[
            [80,4],
            [130,4],
            [220,4],
            [270,4],
            [320,4],
        ]
    ],
    [
        5, [
            [0,2.5],
            [40,2.5],
            [180,2.5],
            
        ]
    ]
];

linear_extrude(4)
difference() {
    circle(d = 22);

    for (i = [0:len(layers)-1]) {
        layer = layers[i];
        distance = layer[0];
        circles = layer[1];
        l = len(circles);
        for (j = [0:l-1]) {
            c = circles[j];
            angle = c[0];
            dia = c[1];
            
            rotate(angle) {
                translate([distance,0]) {
                    circle(d = dia);
            
                    dm = dia-0.5;
                    #translate([0,-dm/2])
                    square([20, dm]);
                }
            }
        }
    }
}