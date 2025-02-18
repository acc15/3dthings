
// Minimum count of circles
circles_min = 6;

// Maximum count of circles
circles_max = 12;

// Minimum radius of circle
radius_min = 2;

// Maximum radius of circle
radius_max = 5;

// Minimum circle offset
offset_min = 0;

// Maximum circle offset
offset_max = 0;

// Random Seed
seed = 1;

// Vase radius
radius = 20;

$fa = 1;
$fs = 1;


function arc(a, r, n, p = [0,0], l = true) = 
    let (a = concat(a),
         r = concat(r, r))
    [ for (i = [0:l ? n : n-1]) 
        let(y = a[0] + i * (a[1] - a[0]) / n) [ cos(y) * r[0], sin(y) * r[1] ] + p
    ];


/*
circle_count = floor(rands(circles_min, circles_max, 1, seed)[0]);
circle_radiuses = rands(radius_min, radius_max, circle_count, seed + 1);
circle_offsets = rands(offset_min, offset_max, circle_count, seed + 2);

echo(str("Circle count is ", circle_count));



for (i = [0:circle_count-1]) {
    rotate(i * 360 / circle_count)
    translate([circle_offsets[i] + radius, 0])
    circle(r = circle_radiuses[i]);   
}

#circle(r = radius);*/



d = 20;
c = 50;
a = 2 + $t * 30;
b = 2 + $t * 5;



//r = (cs*r1 + cs*r2 + sqrt(pow(c,6) + 4*cs*cs*ds - 2*cs*cs*r1s + 4*cs*cs*r1*r2 - 2*cs*cs*r2s - 4*cs*ds*r1s + 8*cs*ds*r1*r2 - 4*cs*ds*r2s + cs*r1s*r1s - 4*cs*r1s*r1*r2 + 6*cs*r1s*r2s - 4*cs*r1*r2s*r2 + cs*r2s*r2s) - r1s*r1 + r1s*r2 + r1*r2s - r2s*r2)/(2*(cs - r1s + 2*r1*r2 - r2s));
//r = (bb*b - a*bb - aa*b - b*cc + aa*a - a*cc - c*sqrt(aa*aa - 4*aa*a*b + 6*aa*bb - 4*aa*dd - 2*aa*cc + 8*a*dd*b + 4*a*b*cc - 4*a*bb*b + 4*dd*cc + bb*bb + cc*cc - 4*dd*bb - 2*bb*cc)) / (2*(aa-2*a*b + bb - cc));
//r = (a*a*a - a*a*b - sqrt(a*a*a*a*c*c - 4*a*a*a*b*c*c + 6*a*a*b*b*c*c - 2*a*a*c*c*c*c - 4*a*a*c*c*d*d - 4*a*b*b*b*c*c + 4*a*b*c*c*c*c + 8*a*b*c*c*d*d + b*b*b*b*c*c - 2*b*b*c*c*c*c - 4*b*b*c*c*d*d + c*c*c*c*c*c + 4*c*c*c*c*d*d) - a*b*b - a*c*c + b*b*b - b*c*c)/(2*(a*a - 2*a*b + b*b - c*c));
//r = 19.862;//4409480463058;//19.44;//5/2 + 20*sqrt(1999/1599);
//r = -b+sqrt(2*sqrt((d*d+(5*(8*sqrt(3196401)-1599))/3198;

//r = (-a*a*a + a*a*b - sqrt(a*a*a*a*c*c - 4*a*a*a*b*c*c + 6*a*a*b*b*c*c - 2*a*a*c*c*c*c - 4*a*a*c*c*d*d - 4*a*b*b*b*c*c + 4*a*b*c*c*c*c + 8*a*b*c*c*d*d + b*b*b*b*c*c - 2*b*b*c*c*c*c - 4*b*b*c*c*d*d + c*c*c*c*c*c + 4*c*c*c*c*d*d) + a*b*b + a*c*c - b*b*b + b*c*c)/(2*(a*a - 2*a*b + b*b - c*c));


aa = a*a;
bb = b*b;
cc = c*c;
dd = d*d;
r = (-aa*a + aa*b - 
    sqrt(aa*aa*cc - 4*aa*a*b*cc + 6*aa*bb*cc 
        - 2*aa*cc*cc - 4*aa*cc*dd 
        - 4*a*bb*b*cc + 4*a*b*cc*cc 
        + 8*a*b*cc*dd + bb*bb*cc 
        - 2*bb*cc*cc - 4*bb*cc*dd 
        + cc*cc*cc + 4*cc*cc*dd) + a*bb + a*cc - bb*b + b*cc)
    /(2*(aa - 2*a*b + bb - cc));

x1 = sqrt((r+a)*(r+a) - d*d);
x2 = sqrt((r+b)*(r+b) - d*d);

echo(r,x1,x2,x1+x2);

circle(r = a);

translate([c,0])
circle(r = b);

#translate([x1, d])
circle(r = r);

/*

r1 = 5 + $t * 20;
r2 = 15;
d = 10;

ad1 = (r1*r1 + d*d - r2*r2) / (2*r1*d);
a1 = acos(ad1);
echo(ad1, a1);

ad2 = (r2*r2 + d*d - r1*r1) / (2*r2*d);
a2 = acos(ad2);
echo(ad2, a2);

*union() {
circle(r = r1);
translate([d,0])
circle(r = r2);
}

polygon(concat(
    arc([0, 180-a2], r2, n = 10, p = [d,0], l = false)
    ,arc([a1,180], r1, n = 10)
    ));
    

translate([d, -0.5])
rotate(180-a2)
translate([0, -0.5])
square([100, 1]);
    */