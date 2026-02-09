$fa = 0.2;
$fs = 0.2;

function closest_dim(dim, full_dim) = dim*floor(full_dim / dim);

// print extrusion width
extrusion_width = 0.48;

/*
// battery length (including tolerance)
battery_length = 66 + 0.4;

// battery diameter (including tolerance)
battery_dia = 18.5 + 0.4;

// battery plus length
battery_plus_length = 1.25;

// battery plus diameter
battery_plus_dia = 6;

// battery minus diameter
battery_minus_dia = 12;
*/

/* 18650 */
battery_length = 66 + 0.4;
battery_dia = 18.5 + 0.4;
battery_plus_length = 1.25;
battery_plus_dia = 6;
battery_minus_dia = 12;


/* AAA 
battery_length = 43 + 0.4;
battery_dia = 10.2 + 0.4;
battery_plus_length = 1.5;
battery_plus_dia = 3.7;
battery_minus_dia = battery_dia;
*/

/* AA 
battery_length = 49.2 + 0.4;
battery_dia = 14.35 + 0.4;
battery_plus_length = 1.3;
battery_plus_dia = 5.3;
battery_minus_dia = 11;
*/

// wire thickness (including tolerance)
wire_thickness = 1.2;

// wire winding width
wire_winding_width = wire_thickness*3;

// wire winding height
wire_winding_height = 4;

// wall thickness
wall_thickness = extrusion_width*4;

// amount of snakes in springs
spring_snakes = 4;

// total spring length
spring_length = 8;

// spring thickness
spring_thickness = extrusion_width * 2;

// distance between springs and walls
spring_base_space = 1;

// width of single spring
spring_width = battery_dia / 2 - spring_base_space*2;

// distance between spring and positive pole
spring_pole_space = 2;

// offset to fine tune spring and battery
pressure_offset = 3;

// base holder length
holder_length = battery_length + battery_plus_length + spring_length + spring_pole_space + wall_thickness * 3 - pressure_offset;

// base holder height
holder_height = wire_winding_height + wire_thickness * 2;

module battery() {
    color("yellow") difference() {
        cylinder(d=battery_dia,h=battery_length);
        translate([0,0,-1])
        cylinder(d = battery_minus_dia, h=2);
    }
    color("gray") cylinder(d=battery_minus_dia,h=1);
    color("gray") translate([0,0,battery_length-1]) cylinder(d=battery_plus_dia,h=battery_plus_length+1);
}


function arc(radius, start, angle = 0, end = 0, center = [0,0], last = true) = let(
    diff = angle != 0 ? angle : end - start,
    n = $fn > 0 ? max($fn, 3) : max(ceil(min(abs(diff) / $fa, 2*PI*radius / $fs)), 5)
) [ for (i=[0:last  ? n : n -1]) let(a = start+i*diff/n) [ cos(a), sin(a) ] * radius + center ];


module spring(thickness, n_snakes, length, width, l_first=true) {
    
    snake_length = length / n_snakes;
    radius_big = (snake_length+thickness)/2;
    radius_small = radius_big - thickness;
    
    lr=l_first ? 0 : 1;
    left = radius_big;
    right = width-radius_big;
    
    points = concat([
        for (i=[0:n_snakes-1]) let(last = (i == n_snakes-1)) each (i + lr) % 2 == 0 
            ? concat(arc(radius_big, 180, -90, center=[left, i*snake_length]), arc(radius_small, 270, +90, center=[right, (i+1)*snake_length], last=last))
            : concat(arc(radius_small, 0, +90, center=[right, i*snake_length]), arc(radius_big, 270, -90, center=[left, (i+1)*snake_length], last=last)),
        for (i=[n_snakes-1:-1:0]) let(last = (i == 0)) each (i + lr) % 2 == 0 
            ? concat(arc(radius_big, 360, -90, center=[right, (i+1)*snake_length]), arc(radius_small, 90, +90, center=[left, i*snake_length], last=last))
            : concat(arc(radius_small, 180, +90, center=[left, (i+1)*snake_length]), arc(radius_big, 90, -90, center=[right, i*snake_length], last=last))
    ]);
        
    polygon(points);
}

module holder() {

    translate([-spring_pole_space-wall_thickness,0,0]) {

        // left
        translate([-wall_thickness - spring_length, battery_dia/2,0])
        cube([holder_length, wall_thickness, holder_height]);

        // right
        translate([-wall_thickness - spring_length, -battery_dia/2-wall_thickness,0])
        cube([holder_length, wall_thickness, holder_height]);

        // negative pole wall
        translate([-wall_thickness - spring_length, -battery_dia/2-wall_thickness,0])
        cube([wall_thickness, battery_dia + wall_thickness * 2, holder_height]);

        // left spring spacer
        translate([0, battery_dia/2-spring_base_space-spring_thickness,0])
        cube([spring_pole_space, spring_thickness, holder_height]);

        // right spring spacer
        translate([0, -battery_dia/2+spring_base_space,0])
        cube([spring_pole_space , spring_thickness, holder_height]);

        // left spring
        translate([0, spring_base_space*0.5, 0])
        linear_extrude(holder_height)
        rotate(90)
        spring(spring_thickness, spring_snakes, spring_length, battery_dia/2 - spring_base_space*1.5, false);

        // right spring
        translate([0, -battery_dia/2 + spring_base_space,0])
        linear_extrude(holder_height)
        rotate(90)
        spring(spring_thickness, spring_snakes, spring_length, battery_dia/2 - spring_base_space*1.5, true);
        
    }
        
    // negative pole
    translate([-wall_thickness, -battery_dia/2 + spring_base_space,0])
    difference() {
        cube([wall_thickness, battery_dia - spring_base_space*2, holder_height]);
        translate([-1,(battery_dia - spring_base_space*2 - wire_winding_width)/2, 0]) {
            translate([0,0,holder_height - wire_thickness])
            cube([wall_thickness + 2, wire_winding_width, wire_thickness + 1]);
            translate([0,0,-1])
            cube([wall_thickness + 2, wire_winding_width, wire_thickness + 1]);
            translate([0,0,holder_height/2])
            rotate([0,90,0]) {
                cylinder(d = wire_thickness, h = wall_thickness + 2);
                translate([0,wire_winding_width,0])
                cylinder(d = wire_thickness, h = wall_thickness + 2);
            }
        }
        
    }

    // positive pole
    translate([battery_length + battery_plus_length - pressure_offset, -battery_dia/2-wall_thickness,0])
    difference() {
        cube([wall_thickness, battery_dia + wall_thickness * 2, holder_height]);
        translate([-1, (battery_dia - wire_winding_width)/2 + wall_thickness, 0]) {
            translate([0,0,holder_height - wire_thickness])
            cube([wall_thickness + 2, wire_winding_width, wire_thickness + 1]);
            translate([0,0,-1])
            cube([wall_thickness + 2, wire_winding_width, wire_thickness + 1]);
            translate([0,0,holder_height/2])
            rotate([0,90,0]) {
                cylinder(d = wire_thickness, h = wall_thickness + 2);
                translate([0,wire_winding_width,0])
                cylinder(d = wire_thickness, h = wall_thickness + 2);
            }
        }
    }
        
}

*translate([0,0,0])
rotate([0,90,0])
battery();

translate([0,0,-holder_height/2])
holder();

