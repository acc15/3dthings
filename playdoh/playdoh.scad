
t = 1.2;
h = 16;
off = 2;
off_dist = 0;
off_h = 2;

$fa = 1;
$fs = 1;

images = [
    [0.8, "fox-sitting.svg"],
    [2.5, "rabbit.svg"],
    [2.5, "deer.svg"],
    [2.5, "dolphin.svg"],
    [2.5, "bear.svg"],
    [3, "tiger.svg"],
    [3, "horse.svg"],
    [3, "kengooroo.svg"],
    [3, "biven.svg"]
];

num = 5;

module d() {

    //offset(-0.5)
    //offset(0.5)
    scale(images[num][0])
        import(images[num][1]);
        
}
/*
module d2() {
    
    
    import("tiger2.svg");
}
*/

//translate([0,0])
linear_extrude(h + off_h)
difference() {
    offset(t)
    d();
    offset(-0.2)
    d();
}

/*
translate([0,0,-1])
linear_extrude(off_h)
difference() {
    offset(t/2 + off)
    d();
    offset(0)
    d();
}*/


//linear_extrude(h)
//d2();