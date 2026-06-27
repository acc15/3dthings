$fa = 0.2;
$fs = 0.2;
t = 0.48*4;
w = 10.2;

l = 20;
sw = 5;
bw = 10;
module shape() {
    polygon([
        [0,0],
        [bw,0],
        [sw,l],
        [0,l]
    ]);
}

module plier_softener() {
    translate([t,t,0]) {

        linear_extrude(t)
        offset(t)
        shape();

        translate([0,0,t])
        linear_extrude(w)
        difference() {
            offset(t)
            shape();
            shape();
            translate([0,-t])
            square([bw, t]);
        }

        translate([0,0,w+t])
        linear_extrude(t)
        offset(t)
        shape();
    }

}

translate([0,0,l+t*2])
rotate([-90,0,0])
plier_softener();

echo(sq = t*2+sw * t*2+w);