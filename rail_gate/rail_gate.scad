use <bendlib/bendlib.scad>;

$fa = 0.5;
$fs = 0.5;

rail_dim = [
    55,
    40,
    12
];

rail_offset = 4;
rail_width = 6;
rail_depth = 3;

hole_d = 12;
hole_offset = hole_d;
hole_connector_width = hole_d/2;

gate_width = 10;
gate_thickness = 2;
gate_height = 40;
gate_tolerance = 0.2;
gate_base_width = gate_width + gate_tolerance + gate_thickness;
gate_length = rail_dim[1] + gate_base_width;


bolt_d = 3.2;

module gate() {
    linear_extrude(gate_thickness)
    difference() {
        hull() {
            circle(d = gate_width);
            translate([gate_length,0])
            circle(d = gate_width);
        }
        circle(d = bolt_d);
    }
}


module connector() {
    translate([-1,-hole_connector_width/2])
    square([hole_offset+1, hole_connector_width]);
    translate([hole_offset,0])
    circle(d = hole_d);
}

module limiter() {
    gate_limiter_width = (gate_base_width-gate_width)/2;
                
    h = gate_thickness + gate_tolerance + gate_width;

    translate([gate_base_width,gate_base_width,0])
    rotate([90,0,-90])
    difference() {

        translate([gate_base_width,0,0])
        rotate([0,-90,0])
        linear_extrude(gate_base_width)
        polygon([
            [0, 0],
            [gate_base_width, 0],
            [gate_base_width+gate_thickness, gate_thickness],
            [gate_base_width+gate_thickness, h],
            [0, h],
        ]);
        
        translate([gate_thickness, gate_thickness, -1])
        linear_extrude(gate_base_width+gate_thickness+2)
        bl_square([gate_base_width,gate_base_width], [0, 0,gate_width/2+gate_tolerance,,0]);
        
    }
}

module gate_mount() {
    difference() {
        union() {
            cube([gate_base_width, gate_base_width, gate_height+gate_width/2]);
            
            translate([0,0,gate_height - gate_width/2 - gate_thickness - gate_tolerance])
            limiter();
        }
        translate([-1,gate_width/2,gate_height])
        rotate([0,90,0])
        cylinder(d = bolt_d, h = gate_base_width + 2);
    }
}

module base() {

    difference() {
        union() {
            translate([0,0,rail_dim[2]])
            rotate([0,90,0])
            linear_extrude(rail_dim[0])
            polygon([
                [0,0],
                [rail_dim[2],0],
                [rail_dim[2],rail_dim[1]],
                [0,rail_dim[1]],
                [0,rail_dim[1]-rail_offset],
                [rail_depth,rail_dim[1]-rail_offset],
                [rail_depth,rail_dim[1]-rail_offset-rail_width],
                [0,rail_dim[1]-rail_offset-rail_width],
                [0,rail_offset+rail_width],
                [rail_depth,rail_offset+rail_width],
                [rail_depth,rail_offset],
                [0,rail_offset]
            ]);
            linear_extrude(rail_dim[2])
            translate([rail_dim[0]-1,rail_dim[1]/2])
            offset(delta=-0.25)
            connector();
        }
        translate([0,0,-1])
        linear_extrude(rail_dim[2]+2)
        translate([0,rail_dim[1]/2])
        offset(delta=0.25)
        connector();
    }

    translate([(rail_dim[0]-gate_base_width)/2,0,0]) {
        cube([gate_base_width, gate_base_width*2+rail_dim[1], gate_thickness*2]);
        translate([0,rail_dim[1]+gate_base_width,0])
        gate_mount();
    }

}

module demo() {
    base();
    
    translate([(rail_dim[0]-gate_base_width)/2,rail_dim[1]+gate_base_width+gate_width/2,gate_height])
    rotate([90,0,-90])
    color("red")
    gate();
}

demo();

//gate_mount();

//limiter();

//base();
//gate();