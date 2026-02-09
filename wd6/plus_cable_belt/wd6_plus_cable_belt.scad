
length = 200;
inner_width = 26;
inner_height = 2.5;
line_t = 2.3;

t = 1.2;

outer_width = inner_width + t*2;
outer_height = inner_height + t*2;


v_line_count = ceil((outer_width / line_t) / 2);
v_line_width = line_t*2 * v_line_count - line_t;
v_line_offset = (v_line_width - outer_width)/2;

h_line_count = ceil(length / line_t / 2);
h_line_width = line_t*2 * h_line_count - line_t;
h_line_offset = (h_line_width - length)/2;

$fa = 0.1;
$fs = 0.1;

module v_line_grid() {

    linear_extrude(t/2)
    for (i = [0:v_line_count-1]) {
        
        translate([i * line_t*2 - v_line_offset, 0])
        square([line_t, length]);
        
    }

}

module h_line_grid() {

    linear_extrude(t/2)
    for (i = [0:h_line_count-1]) {
        
        translate([0, i * line_t*2 - h_line_offset])
        square([outer_width, line_t]);
        
    }

}

module side_wall() {
    
rotate([-90,0,0])
linear_extrude(length)
translate([0,-outer_height/2])
difference() {
    circle(d = outer_height);
    circle(d = inner_height);
    translate([0,-outer_height])
    square([outer_height*2, outer_height*2]);
}
}





//render()

difference() {
intersection() {

union() {

/*/
for (i = [0:h_line_count-1]) {
    translate([0, i * line_t*2 - h_line_offset,t]) {
        cube([t, line_t, inner_height]);
        translate([t+inner_width,0,0])
        cube([t, line_t, inner_height]);
    }
}*/
/*    
translate([0, 0,t]) {
cube([t, length, inner_height]);
translate([t+inner_width,0,0])
cube([t, length, inner_height]);
}*/


v_line_grid();
translate([0,0,t/2])
h_line_grid();

translate([0,0,t+inner_height])
h_line_grid();

translate([0,0,t+t/2+inner_height])
v_line_grid();

}

cube([outer_width, length, outer_height]);
}

translate([line_t - v_line_offset,-1,-1])
cube([line_t, length+2, t+2]);
}

side_wall();
    
translate([outer_width,0,0])
mirror([1,0,0])
    side_wall();

