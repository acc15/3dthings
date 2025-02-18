use <bendlib.scad>

r = 21;
h = 120;

c = 3;
d = 2;

tc = c * 2;

tt = 0.1;
t = 1.2;

ht = 2;
hoff = 10;
hh = 10;
hn = 6;


function e_dup(e, n) = [for (i = [0:n-1]) e];
function a_dup(a, n) = [for (e = a) for (k = e_dup(e, n)) k];
function a_rev(a) = [for (i = [0:len(a)-1]) a[len(a) - 1 - i] ];

pp = concat([ for (i = [0:tc]) for (p = e_dup([r + (i == 0 ? 0 : (i % 2 == 0 ? d : -d)), i / tc * 0.6 * h], i == tc ? 4 : 8)) p ], [[r,h]]);

bl_bezier(pp, $fn = 512);

/*pp2 = concat([ for (i = [0:tc]) 
    for (p = e_dup([r + (i == 0 ? 0 : (i % 2 == 0 ? d : -d)) - t, i / tc * 0.6 * h], 
        i == tc ? 4 : 8)) p ], [[r-t,h-t],[0,h - t]]);*/



/*
difference() {
rotate_extrude($fn = $preview ? 64 : 128)
polygon(concat( 
   bl_bezier(pp, $fn = 512),
   bl_bezier(a_rev(pp2), $fn = 512) 
));

for (i = [0:hn])
    rotate([0,0,i * 360/hn])
    translate([0,-ht/2, h - hh - hoff])
    cube([r + d, ht, hh]);

}

translate([0,0,-t])
rotate_extrude($fn = 128)
translate([r,0])
hull() {
    circle(r = t*2, $fn = 32);
    
    translate([t*2,0])
    circle(r = t*2, $fn = 32);
}

*/
/*
translate([0,0,-3])
minkowski() {
    
    linear_extrude(2)
    scale([1,2,1])
    circle(r = r, $fn = 64);
    
    sphere(r=3, $fn = 64);

}*/
    

/*
minkowski() {
linear_extrude(1)
    
    
polygon([[-15,-10],[-15,10],[0,30],[15,5],[15,-5],[0,-30]]);
    
    sphere(r=5, $fn = 64);
}
    */
/*
    translate([-r*3, -r*2.5, -0.1])
    cube([r*2, r * 5, 20]);
            
    translate([r, -r*2.5, -0.1])
    cube([r*2, r * 5, 20]);
            
}*/