

t = 0.8;
d = 80;
h = 30;

$fa = 1;
$fs = 1;



wd = 10;
rmin = 30;
rmax = 65;
hmin = 20;
hmax = 25;
n = 100;
a = 360 * 3;

difference() {
cylinder(d = rmax*2 + wd, h = hmax+wd/2-0.1);
translate([0,0,hmin-wd/2])
cylinder(d1 = rmin*2, d2 = rmax*2+wd, h = (hmax - hmin)+wd);


/*
for (i = [0:n-2]) {
    
    hull() {
    rotate([0,0,i * a/n])
    translate([i*(rmax-rmin)/n + rmin,0,i*(hmax-hmin)/n + hmin])
    sphere(d = wd);
    
    rotate([0,0,(i+1) * a/n])
    translate([(i+1)*(rmax-rmin)/n + rmin,0,(i+1)*(hmax-hmin)/n + hmin])
    sphere(d = wd);
    }
    
}*/

translate([0,0,rmin])
sphere(d = rmin*2+wd+t*2);

}

cylinder(d = rmax*2+wd, h = t);



