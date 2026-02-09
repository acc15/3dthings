l = 26;
d1 = 3;
d2 = 4;
h = 6;
w = 2;

$fa=0.2;
$fs=0.2;

module base_shape() {
    hull() {
        circle(d = d1);
        translate([(l-d1/2)/2,(d2-d1)/2])
        circle(d = d2);
        translate([l-d1/2,0])
        circle(d = d1);    
    }
}


module base() {
    linear_extrude(h)
    difference() {
        translate([d1/2+w,d1/2+w])
        difference() {
            offset(w)
            base_shape();
            base_shape();
        }

        translate([l+w,0])
        square([d1+w,d1+w*2]);
    }
}

module ear() {
    //translate([h/2,h/2])
    linear_extrude(w)
    difference() {
        union() {
            circle(d = h);
            translate([-h/2,-h/2])
            square([h/2,h]);
        }
        circle(d = 3.2);
    }    
}

module ears() { 

    translate([h/2+l+w,0,h/2])
    rotate([-90,0,0])
    union() {
        ear();
        
        translate([0,0,w+d1])
        ear();
    }

}

module wire_lock() {
    base();
    ears();
}

wire_lock();
