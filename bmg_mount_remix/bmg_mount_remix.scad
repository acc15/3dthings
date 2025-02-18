
*difference() {

translate([-100,-100,0])
import("BMG_D6.stl");

translate([-15,10,8])
cube(20);

translate([-4.25,20.55,-1])
cylinder(d = 4.2, h = 20, $fn = 32);
  
}


//translate([-21,-29.966,55.49]) 

module bmg_mount() {

    w = 42;
    l = 28;
    h = 3;

    hw = 2;
    hl = 19;
    hh = 16;
    hr = 2;

    sd = 3;
    soff = 0.4;
    sy1 = 4;
    sy2 = 15;
    sh = 11;
    
    pd = 6;
    ph = 2;
    px1 = 7.67;
    px2 = 26.65;
    py = 13.8;
    pw = 2;
    
    hd = 2.8;

    dh = 7;

    tol = 0.2;


    
    translate([0,0,h])
    rotate([90,0,90])
    linear_extrude(hw)
    translate([0,-hr])
    difference() {
        offset(hr, $fn = 32)
        offset(-hr)
        square([hl, hh+hr]);
        translate([-tol, -tol])
        square([hl+tol*2, hr+tol]);
    }
    
    translate([w-hw,0,h])
    rotate([90,0,90])
    linear_extrude(hw)
    translate([0,-hr])
    difference() {
        offset(hr, $fn = 32)
        offset(-hr)
        square([hl, hh+hr]);
        translate([-tol, -tol])
        square([hl+tol*2, hr+tol]);
    }
    
    color("green")
    translate([soff,sy1,h + sh])
    sphere(d = sd, $fn = 32);
    
    color("green")
    translate([soff,sy2,h + sh])
    sphere(d = sd, $fn = 32);
    
    color("green")
    translate([w - soff,4,h + sh])
    sphere(d = sd, $fn = 32);
    
    color("green")
    translate([w - soff,15,h + sh])
    sphere(d = sd, $fn = 32);

    
    difference() {
        union() {
            cube([w,l,h]);
            
            translate([px1,py,h])
            cylinder(d = pd, h = ph, $fn = 64);
            
            translate([px2,py,h])
            cylinder(d = pd, h = ph, $fn = 64);
            

            
        }
        
        translate([px1,py,-tol])
        cylinder(d = hd, h = ph + h + tol*2, $fn = 64);
        
        translate([px2,py,-tol])
        cylinder(d = hd, h = ph + h + tol*2, $fn = 64);
        
        translate([0,0,-tol])
        linear_extrude(h + tol*2)
        translate([0,-hr])
        offset(hr, $fn = 32)
        offset(-hr)
        translate([12,0])
        square([18,10+hr]);
        
    }

    translate([0,l-pw,h])
    cube([w,pw,ph]);


    translate([h,l,h])
    rotate([0,90,180])
    linear_extrude(h)
    polygon([[0,0], [h+dh,0], [h+dh,h], [h,l], [0,l]]);

    translate([w,l,h])
    rotate([0,90,180])
    linear_extrude(h)
    polygon([[0,0], [h+dh,0], [h+dh,h], [h,l], [0,l]]);

    difference() {
    translate([0,l-h,-dh])
    cube([w, h, dh]);
    
    translate([8.5, l+tol, (h+1)-7.5])
    rotate([90,0,0])
    cylinder(d = hd, h = h + tol*2, $fn = 64);
    
    translate([w-8.5, l+tol, (h+1)-7.5])
    rotate([90,0,0])
    cylinder(d = hd, h = h + tol*2, $fn = 64);
    }
    

    /*translate([w-8.5, l+tol, (h+1)-7.5])
    rotate([90,0,0])
    cylinder(d = 5.5, h = 10, $fn = 32);*/

    bt = 2;
    bw = 2.8;    
    bl = 13;
    bh = 20;
    
    ww = 1.5;
    wh = 15;

    
    module wc(xe = 0) {
        polygon([[-xe,0], [wh+bh+xe,0], [wh+bh+xe,bw], [wh, bw], [wh - (bh-wh), ww], [-xe, ww]]);    
    }
    
    module extwc(xe = 0) {
        difference() {
            offset(bt, $fn = 64)
                wc(tol);
            
            translate([-bt-tol*2, -bt-tol])
            square([bt+tol*2, ww+bt*2+tol*2]);
            
            translate([wh+bh,-bt-tol])
            square([bt+tol*2, bw+bt*2+tol*2]);
        }
    }


    translate([0,l-bl-bt,0])
    rotate([-90,90,0])
    translate([0,bt,0])
    union() {
    
        translate([0,0,bl])
        linear_extrude(bt)
        extwc();
        
        //translate([0,0,bt])
        linear_extrude(bl)
        difference() {
            extwc();
            wc(tol);
        }
        
    }
    

    /*
    translate([-bw-bt*2, l-bl-bt*2, -bh]) 
    difference() {
        cube([bw + bt*2, bl + bt*2, bh]);

        translate([bt,-tol,-tol])
        cube([bw, bl+bt+tol, bh+tol*2]);
    }
    */
    
}



bmg_mount();

//translate(
//bltouch_holder();

/*
translate([-2,l-6.5-2,h])
cube([10, 6.50,1.6]);*/