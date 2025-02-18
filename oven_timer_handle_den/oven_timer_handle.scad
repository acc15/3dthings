

outer_d = 13;
inner_d = 4;
tolerance = 0.1;
inner_h = 7;
facet_h = 2;
outer_h = inner_h + facet_h;

handle_n = 8;
handle_d = 2;


m_l = 1;
m_t = 1;

$fa = 0.1;
$fs = 0.1;

module top() {
 
    cylinder(d1 = outer_d, d2 = outer_d - handle_d, h = facet_h);
    
}

module part() {
    translate([0,0,inner_h])
        top();

    linear_extrude(inner_h)
    difference() {
        circle(d = outer_d);

        difference() {
            
            id = inner_d + tolerance*2;
            
            circle(d = id);
            
            translate([-m_t/2,id/2 - m_l])
            square([m_t, m_l]);
        }
    }
}

rotate([180,0,0])
difference() {
    part();

for (i = [0:handle_n-1])
rotate([0,0,360/handle_n * i])
translate([outer_d/2,0,-tolerance])
cylinder(d = handle_d, h = outer_h+tolerance*2);
}

//cylinder(d = inner_d, h = inner_h, $fn = 32);