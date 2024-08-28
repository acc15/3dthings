
t=0.6*4;
a=10;
af=70;
h=20;
s=10;
w=12;


module simple_squares() {
    linear_extrude(100)
    intersection() {

        translate([-50, 0])
        square([100, 100]);

        rotate(-a) {
            translate([-w-t*2,-50])
            square([t,s+t+50]);

            translate([-w-t*2,0])
            square([w+t*2, t]);

            translate([-t,0])
            square([t, t+h]);

            translate([0,t+h])
            rotate(a+af)
            translate([-t,-100])
            square([t, 100]);
        }
        
    }
}

function v(l, a) = [l*cos(a),l*sin(a)];

ab=h+t+t*tan(a);
ed=t/cos(af);
fe=ab*(sin(a)+cos(a)*tan(af))-t/cos(a)-ed;

f=[w+2*t,0];
g=f+[0,fe*cos(af)/sin(a+af)];
e=g+v(fe*cos(a)/sin(a+af), 270+a+af);
d=e+v(ed, a);

linear_extrude(30)
rotate(-a)
translate([0,(2*t+w)*tan(a)])
polygon([
    [w+t, h+t],
    [w+t, t],
    [t, t],
    [t, s],
    [0,s],
    [0,-(2*t+w)*tan(a)],
    [t,-(t+w)*tan(a)],
    [t,0],
    f,
    g,
    e,
    d
]);