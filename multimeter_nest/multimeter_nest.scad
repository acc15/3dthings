$fa = 0.2;
$fs = 0.2;

d = 11;
h = 19;

wing_l = 15;
wing_t = 1.5;
wing_h = 2;

isolation_d1 = 8.5 + 0.2; // 0.2 tolerance
isolation_h1 = 16;

isolation_d2 = 6.5 - 0.2; // 0.2 tolerance
isolation_h2 = 3;

inner_d = 4;

tube_d = 5.2;
tube_h = 13;

tube_soldered_d = 7;
tube_soldered_h = 2.5;

mount_d = 12;
mount_h = 4;
mount_off = isolation_h1 - mount_h;


module nest_shape() {
    polygon([
        [tube_soldered_d/2, 0],
        [d/2, 0],
        [d/2, mount_off - (mount_d - d)/2],
        [mount_d/2, mount_off],
        [mount_d/2, mount_off + mount_h],
        [d/2, mount_off + mount_h],
        [d/2, h],
        [isolation_d1/2, h],
        [isolation_d1/2, isolation_h2],
        [isolation_d2/2, isolation_h2],
        [isolation_d2/2, isolation_h1],
        [inner_d/2, isolation_h1],
        [inner_d/2, tube_h],
        [tube_d/2, tube_h - (tube_d - inner_d) / 2],
        [tube_d/2, tube_soldered_h],
        [tube_soldered_d/2, tube_soldered_h - (tube_soldered_d - tube_d)/2]
    ]);
}


module wing() {
    polygon([
        [isolation_d1/2, mount_off + (isolation_d1 - wing_l)/2], 
        [wing_l/2, mount_off],
        [wing_l/2, mount_off + mount_h], 
        [isolation_d1/2, mount_off + mount_h]
    ]);
}

module nest() {

    rotate_extrude()
    nest_shape();

    rotate([90,0,0])
    translate([0,0,-wing_t/2])
    linear_extrude(wing_t) {
        wing();
        mirror([1,0])
        wing();
    }

}

nest();

