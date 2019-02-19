

/*

TODO

Done
- Wire hooks on roof
- Lid open/close mechanics
- USB wire hole in roof + USB join part in lid
- Fan holes
- Screen holes for control, speaker and reset button
- Foots
- SD card hole
- Power supply and power button holes
- Motherboard holes + pads

*/


// Fixed button hole diameter
// Increased fan grid spacing
// Fixed PSU holes position
// Increased all holes dia - 3mm bolt holes => 4mm, PSU bolts holes => 5mm
// Fixed box and lid hinges (requires 2 x m3x4 bolts and nuts)
// Increased foot height

// model, box or lid
mode = "model";

tolerance = 1;
thickness = 2.33;
//thickness = 3.4;
board_thickness = 1.75;

psu_dim = [110, 210, 50];
psu_holes = [50, 150];
psu_hole_dia = 5;

fan_dim = [120, 120, 20];
fan_holes = [105, 105];
fan_hole_dia = 4;
fan_pad = 0;

mosfet_dim = [88, 67, 30];
mosfet_holes = [80, 60];
mosfet_hole_dia = fan_hole_dia;
mosfet_spacing = tolerance + fan_dim[2] + 40;
mosfet_pad = 7;

motherboard_dim = [84, 143, 10];
motherboard_holes = [76, 135];
motherboard_spacing = 55;
motherboard_pad = mosfet_pad;
motherboard_hole_dia = fan_hole_dia;

ctrl_dim = [93, 87, 21];
ctrl_holes = [88, 65];
ctrl_spacing = 50;
ctrl_hole_dia = fan_hole_dia;
ctrl_h_offset = 2;
ctrl_pad = mosfet_pad;
screen_board_height = 70;
screen_board_offset = 6; 

smoother_dim = [30, 40, 12];
smoother_holes = [22, 32];
smoother_pad = mosfet_pad;
smoother_hole_dia = fan_hole_dia;

wire_thickness = 4;

pad_add = 2.45;


box_dim = [
    wire_thickness * 2 + fan_dim[0], 
    tolerance + fan_dim[2] + tolerance + 40 + tolerance + psu_dim[1] + tolerance,
    tolerance * 3 + fan_dim[0] + psu_dim[2]
];
box_angle = 20;

box_inner_height = tolerance + psu_dim[2] + tolerance;
box_inner_width = box_dim[1] - tan(box_angle) * (box_dim[2] - box_inner_height);

foot_r = 35;
foot_h = 15;

board_offset = tolerance + psu_dim[2] + tolerance + 10;
board_spacing = 8;

connector_dim = [20,8.5,8.5];

wire_holder_thickness = 5;
wire_holder_grid = [1,5];
wire_holder_cell = [connector_dim[0] + 2, connector_dim[2] + 2];
wire_holder_dim = [
    wire_holder_cell[0] * wire_holder_grid[0] + wire_holder_thickness * (wire_holder_grid[0] - 1), 
    wire_holder_cell[0] * wire_holder_grid[1] + wire_holder_thickness * (wire_holder_grid[1] - 1), 
    wire_holder_cell[1] + wire_holder_thickness
];

hinge_inner_d = 4;
hinge_inner_r = hinge_inner_d / 2;
hinge_length = 18;
hinge_offset = 50;



function arc_segments(radius, angle) = $fn > 0 ? $fn : ceil(max(min(angle / $fa, 2 * PI * radius / $fs), 5));
function arc(radius, start_angle, end_angle, last_point = false, segments = -1) = 
    let(n = segments < 0 ? arc_segments(radius, end_angle - start_angle) : segments) 
    [ for (i = [0:last_point ? n : n-1]) let(angle = start_angle + (end_angle - start_angle) / n * i) [ cos(angle) * radius, sin(angle) * radius ] ];

module ngon(n, r) {
    polygon(arc(radius = r, segments = n, start_angle = 0, end_angle = 360, last_point = false));
}

module arc_profile(radius, start_angle, end_angle, thickness, last_point = true) {
    polygon(concat(
        arc(radius - thickness, start_angle, end_angle, last_point), 
        arc(radius, end_angle, start_angle, last_point)
    ));
}


module wire_arc(w = 10, h = 5, l = 5) {
    
    shape = concat([[0,0], [w,0,]], [ for (i = [0:32]) [cos(i * 180 / 32) * w / 2 + w / 2, sin(i * 180 / 32) * h / 2 + h ] ]);
    
    linear_extrude(l)
    translate([-w/2,-tolerance])
    difference() {
        offset(r = thickness)
            polygon(shape);
        polygon(shape);
        translate([-thickness - tolerance, -h+tolerance])
            square([w + thickness * 2 + tolerance * 2,  h]);
    }
}

module terminal_connector() {
    d = 3.5;
    r = d / 2;
    
    h = [8, 4, 8];
    
    hull() {
    translate([0,0,h[0] + h[1]])
    hull($fn = 32) {
        
        translate([-r, 0, 0])
        cylinder(d = d, h = h[2]);
        
        translate([r, 0, 0])
        cylinder(d = d, h = h[2]);
        
    }
    
    translate([0,0,h[0]])
    cylinder(d = d, h = h[1], $fn = 32);
    }
    cylinder(d = d, h = h[0], $fn = 32);
    
    
}

module power_connector(mode = "model", h = thickness + tolerance * 2) {
    
    pd = [26.75, 18.5];
    t = 1.75;
    pr = 1.5;
    pa = [12.75, 15.75];
    ph = 13.8;
    
    ed = [30.75, 21.8];
    er = 2;
    eh = 2;
    
    so = 4.5;
    sr = 4.85;
    sh = 3.2;
    sr_h = 4;
    
    epo = [ed[0]/2 - pd[0]/2,ed[1]/2 - pd[1]/2];
    
    cpd = [5,10.65,2.5];
    cpo = [8.8, 0.65];
    
    //ih = 2.5
    
    module cpin() {
        pd = [1,5,7.5 + 15 + cpd[2]];
        translate([cpd[0]/2 - pd[0]/2,cpd[1]/2 - pd[1]/2,-15])
            cube(pd);
        cube(cpd);
        
        color("red")
        translate([cpd[0] / 2,cpd[1]/2,cpd[2] + 20 + tolerance])
        rotate([180,0,90])
        terminal_connector();
        
    }
    
            
    module p() {
        polygon([
            [0,0], 
            [pd[0],0], 
            [pd[0],pa[0]], 
            [pd[0] - (pd[0] - pa[0]) / 2, pd[1]], 
            [(pd[0] - pa[0]) / 2, pd[1]],
            [0,pa[0]]
        ]);
    }
    
    if (mode == "model") {
    
        difference() {
            union() {
                translate([epo[0], epo[1],eh+sh])
                linear_extrude(ph) {
                    offset(pr, $fn = 32)
                        offset(-pr)
                            p();
                }
                
                translate([0,0,2])
                linear_extrude(sh) {
                    difference() {
                        hull() {
                            translate([-so, ed[1]/2])
                                circle(r = sr, $fn = 32);
                         
                            translate([ed[0] + so, ed[1]/2])
                                circle(r = sr, $fn = 32);
                            
                            offset(er, $fn = 32)
                                offset(-er)
                                    square(ed);
                        }
                        
                        translate([-so, ed[1]/2])
                            circle(d = sr_h, $fn = 32);
                        
                        translate([ed[0] + so, ed[1]/2])
                            circle(d = sr_h, $fn = 32);
                    }
                }
                    
                linear_extrude(eh)
                offset(er, $fn = 32)
                    offset(-er)
                        square(ed);
            }
                
            translate([epo[0], epo[1],-1])
            linear_extrude(eh + sh + ph - t-1)
            offset(t/2, false, $fn = 32)
            offset(-t, false)
            p();
            
        }
        
        translate([epo[0], epo[1], eh+sh+ph]) {
            translate([cpo[0] - cpd[0],cpo[1],0])
            cpin();
            
            translate([pd[0] - cpo[0],cpo[1],0])
            cpin();
            
            translate([pd[0] / 2 - cpd[0]/2,pd[1] - cpd[1] - cpo[1],0])
            cpin();
        }
    
    } else {
        
        linear_extrude(h) {
            offset(tolerance/2, $fn = 16)
                translate([epo[0], epo[1]])
                p();
            
            translate([-so, ed[1]/2])
                circle(d = sr_h + tolerance, $fn = 32);
            
            translate([ed[0] + so, ed[1]/2])
                circle(d = sr_h + tolerance, $fn = 32);
            
        }
    
    }
}

module power_button(mode = "model", state = "off", h = thickness + 2) {
    sa = 10;
    cd = [0.8, 6.5, 10];
    bd = [28, 16, 20];
    poff = 1.5;
    hd = 12;
       
    module cpin() {
        cube(cd);
        
        color("red")
        translate([cd[0]/2,cd[1]/2,-10 - tolerance])
            rotate([0,0,90])
                terminal_connector();
    }
    
    if (mode == "model") {
    
        cube([28, 16, 20]);
        
        translate([-cd[2], 2, bd[2] - poff])
        rotate([0,90,0])
        cpin();
        
        translate([14, 8, 20])
            cylinder(d = hd, h = 13, $fn = 64);
        
        translate([14, 8, 27])
        rotate([0, state == "on" ? sa : -sa,0])
            cylinder(d = 7, h = 25, $fn = 64);

        translate([0, bd[1] / 2 - cd[1]/2, -cd[2]]) {        
            translate([poff, 0, 0])
                cpin();
            translate([bd[0] - poff, 0, 0])
                cpin();
        }
    } else {
        
        translate([14, 8, 0])
            cylinder(d = hd + tolerance, h = h, $fn = 64);
    }
}

module foot() {
    
    r = foot_r;
    h = foot_h;
    
    rotate([180,0,90])
    difference() {
        union() {
            linear_extrude(h, scale = (r - h) / r) 
                rotate([0,0,90 / 4]) 
                    ngon(8, r);
        }
        translate([-r - 1,-r - 1,-1]) cube([r + 1, (r + 1) * 2, h + 2]);
        translate([-0.5,-r - 1,-1]) cube([(r + 1), r + 1, h + 2]);
    }
}

module four_cyls(dim, hole_dist, dia) {
    dc = [dim[0]/2, dim[1]/2];
    hc = [hole_dist[0]/2, hole_dist[1]/2];
    
    for (x = [-1:2:1], y = [-1:2:1]) {
        //echo(x = x, y = y);
        translate([dc[0] + x * hc[0], dc[1] + y * hc[1]])
            cylinder(d = dia, h = dim[2], $fn = 32);
    }
}

module cube_4holes(dim, hole_dist, dia) {   
    center = [dim[0] / 2, dim[1] / 2];
    hole_center = [hole_dist[0] / 2, hole_dist[1] / 2];
    difference() {
        cube(dim);
        translate([0,0,-1]) four_cyls([dim[0],dim[1],dim[2]+2], hole_dist, dia);
    }
}

module psu() {
    cube_4holes(psu_dim, psu_holes, psu_hole_dia);
}
    
module mosfet() {
    
    union() {
        cube_4holes([mosfet_dim[0], mosfet_dim[1], board_thickness], mosfet_holes, mosfet_hole_dia);
        translate([0,0,board_thickness]) {
            
            translate([0, mosfet_dim[1]/2 - 20, 0])
            cube([10, 40, 10]);
            
            translate([mosfet_dim[0] - 10, mosfet_dim[1]/2 - 20,0])
            cube([10, 40, 10]);
            
            translate([mosfet_dim[0] / 2 - 30, mosfet_dim[1] / 2 - 25,0])
            cube([60, 50, 25]);            
        }
    }
    
}

module ctrl_screen(mode, add = 0) {
    screen_dim = [78.25 + add * 2,51 + add * 2,8.5 + add * 2];
    screen_offset = [7.5, 10];

    translate([
        ctrl_dim[0] - screen_dim[0] - screen_offset[0] + add, 
        screen_board_height - screen_dim[1] - screen_offset[1] + add, 
        0])
    {
        if (mode == "model") {
            color("darkblue") 
                cube(screen_dim);
        } else {
            translate([0,0,-1])
                cube([screen_dim[0], screen_dim[1], thickness + 2]);
        }
    }       
}

module ctrl_connector() {
    connector_offset = [10, 7];
    
    translate([0, screen_board_height - connector_dim[1] - connector_offset[1], -screen_board_offset-connector_dim[2]])
    color("green") {
        translate([ctrl_dim[0] / 2 - connector_dim[0] - connector_offset[0]/2, 0, 0])
            cube(connector_dim);
        
        translate([ctrl_dim[0] / 2 + connector_offset[0]/2,0,0]) 
            cube(connector_dim);
    }
}

module ctrl_sdslot(mode, add = 0) {
    sd_dim = [26.5 + add * 2, 25.5 + add * 2, 3 + add * 2];
    sd_offset = 22;
    
    if (mode == "model") {
        color("lightgreen") 
            translate([0,screen_board_height - sd_dim[1] - sd_offset,-screen_board_offset-sd_dim[2] - add]) 
                cube(sd_dim);
    } else {
        w = thickness + 2;
        translate([-w - ctrl_h_offset-tolerance + 1, screen_board_height - sd_dim[1] - sd_offset + add, -screen_board_offset-sd_dim[2]+add]) cube([w, sd_dim[1], sd_dim[2]]);
    }
}

module ctrl_controls(mode, add = 0) {
    
    $fa = 0.5;
    $fs = 0.5;
    
    det_dim = [13.8, 12, 6];
    det_offset = [2.5, 3.5];
        
    hand_d = 7 + add * 2;
    hand_h = 20;
    
    speaker_ctrl_offset = 31.5;
    speaker_d = 12 + add * 2;
    speaker_h = 9;
    
    stop_dim = [6 + add * 2, 6 + add * 2, 4 + add * 2];
    stop_offset = 43.5;
    
    stop_d = 4 + add * 2;
    stop_h = 1;

    translate([-det_dim[0] + ctrl_dim[0] - det_offset[0], screen_board_height - ctrl_dim[1] + det_offset[1],0])
    if (mode == "model") {

        translate([0,0, board_thickness-screen_board_offset]) {
            cube(det_dim);
            translate([det_dim[0] / 2, det_dim[1] / 2, det_dim[2]]) cylinder(d = hand_d, h = hand_h);
            
            translate([-speaker_ctrl_offset + speaker_d / 2 + det_dim[0], speaker_d / 2,0]) 
                cylinder(d = speaker_d, h = speaker_h);

            translate([-stop_offset + det_dim[0] - add / 2,det_dim[1] / 2 - stop_dim[1]/2,0]) {
                cube(stop_dim);  
                translate([stop_dim[0]/2,stop_dim[1]/2,stop_dim[2]]) 
                    cylinder(d = stop_d, h = stop_h);
            }
        }
        
    } else {
        

        translate([det_dim[0] / 2, det_dim[1] / 2, -1]) 
            cylinder(d = hand_d, h = thickness + 2);
        translate([-speaker_ctrl_offset + speaker_d / 2 + det_dim[0] - add, det_dim[1] / 2,-1]) 
            cylinder(d = speaker_d, h = thickness + 2);
        translate([-stop_offset + det_dim[0] + stop_dim[0]/2 - add,det_dim[1] / 2, -1])
            cylinder(d = stop_d, h = thickness + 2);
        
    }
}

module ctrl(mode = "model", add = 0) {
    if (mode == "model") {
        difference() {
            union() {
                translate([0,0, -board_thickness]) cube([ctrl_dim[0], screen_board_height, board_thickness]);
                translate([0,screen_board_height - ctrl_dim[1], -screen_board_offset]) cube([ctrl_dim[0], ctrl_dim[1], board_thickness]);
            }
            translate([0,0,-screen_board_offset-1]) four_cyls([ctrl_dim[0], screen_board_height, ctrl_dim[2] + 2], ctrl_holes, ctrl_hole_dia);
        }    
        ctrl_connector();
    }
    ctrl_screen(mode, add);
    ctrl_sdslot(mode, add);
    ctrl_controls(mode, add);
    
}

module smoother() {
    cube_4holes([smoother_dim[0], smoother_dim[1], board_thickness], smoother_holes);
    
    connector_dim = [12.5, 5.75, smoother_dim[2] - board_thickness];
    
    translate([smoother_dim[0] / 2 - connector_dim[0]/2,0,board_thickness]) cube(connector_dim);
    translate([smoother_dim[0] / 2 - connector_dim[0]/2,smoother_dim[1] - connector_dim[1],board_thickness]) cube(connector_dim);
}

module motherboard_usb(mode = "model", thick, off = 0, tol = 0, z_add = 0, z_off = 0) {
    dim = [17, 13, 10];
    y_offset = 20;
    
    if (mode == "model") {
        translate([motherboard_dim[0] - dim[0], y_offset, board_thickness]) 
            cube(dim);
    } else if (mode == "diff") {
        translate([motherboard_dim[0] + off, y_offset - tol, board_thickness - tol - z_add - z_off ]) 
            cube([thick, dim[1] + tol * 2,dim[2] + tol * 2 + z_add]);
    }
}

module motherboard() {
    union() {
        cube_4holes([motherboard_dim[0], motherboard_dim[1], board_thickness], motherboard_holes, 3.2);
        motherboard_usb("model");
    }
}

module fan() {
    cube_4holes(fan_dim, fan_holes, fan_hole_dia);
}

module button_hole(thickness) {
    translate([0,thickness,0]) rotate([90,0,0]) cylinder(d = button_hole_dia, h = thickness, $fn = 32);
}

module fan_hole(thickness) {
    v_dim = 4;
    y_center = fan_dim[1] / 2;
    intersection() {
        translate([fan_dim[0]/2, fan_dim[1]/2,0]) cylinder(d = fan_dim[0] - 20, h = thickness);
        
        union() {
            translate([0,y_center - v_dim / 2,0])
                cube([fan_dim[0], v_dim, thickness]);
            for (i = [v_dim*2:v_dim*2:(fan_dim[1] - 20)/2]) {
                translate([0,y_center - v_dim / 2 + i, 0])
                    cube([fan_dim[0], v_dim, thickness]);
                translate([0,y_center - v_dim / 2 - i, 0])
                    cube([fan_dim[0], v_dim, thickness]);
            }
        }
    }
    four_cyls([fan_dim[0], fan_dim[1], thickness], fan_holes, fan_hole_dia);
}

module inner_box_poly() {
    polygon([
        [0,0],
        [box_dim[1],0],
        [box_dim[1],box_inner_height],
        [box_inner_width, box_dim[2]],
        [0,box_dim[2]] 
    ]);
}

module ext_box_poly() {
    offset(delta = thickness, true)
        inner_box_poly();
}

module box_main_base() {
    difference() {
        translate([0,0,-thickness])
        linear_extrude(thickness + box_dim[0])
            ext_box_poly();
        linear_extrude(thickness + box_dim[0])
            inner_box_poly();
        
    }    
}

module box_lid_base() {
    translate([0,0, box_dim[0]])
        linear_extrude(thickness)
            ext_box_poly();
}


module pyramid(dim, angle = 45) {
    c = tan(angle) * dim[2];
    
    p = [
        [0,0,0],[dim[0],0,0],[dim[0],dim[1],0],[0,dim[1],0],
        [c,c,dim[2]],[dim[0]-c,c,dim[2]],[dim[0]-c,dim[1]-c,dim[2]],[c,dim[1]-c,dim[2]]
    ];
    
    f = [
        [0,1,2,3],
        [7,6,5,4],
        [4,5,1,0],
        [0,3,7,4],
        [5,6,2,1],
        [6,7,3,2]
    ];
    
    polyhedron(p, f);
}


module wire_holder() {

    difference() {
        pyramid(wire_holder_dim, -45);
        translate([0,0,wire_holder_thickness]) pyramid(wire_holder_dim, -45);
        for (x = [0:wire_holder_grid[0]-1])
            translate([x * (wire_holder_thickness + wire_holder_cell[0]), -20, wire_holder_thickness])
                cube([wire_holder_cell[0], wire_holder_dim[1] + 40, wire_holder_cell[1]+1]);
        for (y = [0:wire_holder_grid[1]-1])
            translate([-20, y * (wire_holder_thickness + wire_holder_cell[0]), wire_holder_thickness])
                cube([wire_holder_dim[0] + 40, wire_holder_cell[0], wire_holder_cell[1]+1]);
        for (x = [0:wire_holder_grid[0]-1], y = [0:wire_holder_grid[1]-1])
            translate([x * (wire_holder_thickness + wire_holder_cell[0]), 
                y * (wire_holder_thickness + wire_holder_cell[0]), -1])
                cube([wire_holder_cell[0], wire_holder_cell[0], wire_holder_dim[2] + 2]);
    }
}

module psu_layout(off = 0) {
    translate([box_dim[0] / 2 - psu_dim[0]/2,tolerance + fan_dim[2] + tolerance + 38 + tolerance, tolerance - off]) children();
}

module fan_layout(off = 0) {
    translate([wire_thickness, tolerance - off + fan_pad, tolerance + psu_dim[2] + fan_dim[0] + tolerance - 1]) 
        rotate([270,0,0]) 
            children();
}

module power_button_layout(off = 0) {
    translate([box_dim[0] - 70, -off, 20])
    rotate([90,-90,0])
    children();
}

module power_connector_layout(off = 0) {
    translate([box_dim[0] - 20,-off,24])
    rotate([90,0,180])
    children();
}

module mosfet_layout(off = 0) {
    translate([tolerance + mosfet_pad - off, 
        mosfet_spacing, 
        board_offset]) 
        rotate([90,0,90]) 
            children();
}

module smoother_layout(off = 0) {
    
    translate([tolerance + smoother_pad - off,mosfet_spacing, smoother_dim[0] + board_offset + mosfet_dim[1] + board_spacing]) rotate([0,90,0]) {
        for (i = [0:2]) 
            translate([0,i * (smoother_dim[1] + board_spacing),0]) 
                children();
        translate([smoother_dim[0] + board_spacing,2 * (smoother_dim[1] + board_spacing*2),0]) 
            children();
    }
}

module ctrl_layout(off = 0) {
    translate([box_dim[0] - ctrl_h_offset - tolerance,box_dim[1],tolerance + psu_dim[2] + tolerance]) 
        rotate([90-box_angle,0,180]) 
            translate([0,ctrl_spacing,-off])
                children();
    
}

module motherboard_layout(off = 0) {
    translate([box_dim[0] - tolerance - motherboard_pad + off, motherboard_spacing, box_dim[2] - tolerance - motherboard_dim[0] - thickness ]) 
        rotate([0,-90,0]) 
            children();
}

module wire_holder_layout() {
    translate([box_dim[0] / 2 - wire_holder_dim[0]/2,box_inner_width/2 - wire_holder_dim[1]/2,box_dim[2] - wire_holder_dim[2]])
    children();
}


tooth_width = 10;
tooth_offset = 10;
tooth_length = hinge_length;

module lid_tooth(mode = "model", add = 0) {
    if (mode == "model") {
        translate([-tooth_width, 0, tolerance]) cube([thickness + tooth_width, tooth_length, thickness]);
        translate([0,0,-tolerance]) cube([thickness, tooth_length, tolerance * 3]);
    }
    
    translate([0,tooth_length+add,tolerance])
    rotate([90,-90,0])
    linear_extrude(tooth_length+add*2) offset(delta = add, true) polygon([[0,tooth_width / 3],[-3,tooth_width * 2 / 3],[0,tooth_width]]);
}


module lid_tooth_layout() {
    translate([box_dim[0], 0, 0]) {
        translate([0,0, box_dim[2] + thickness]) {
            translate([0,tooth_offset,0]) 
                children();

            translate([0, box_inner_width - tooth_width - hinge_length, 0])
                children();
        }
        
        translate([0,box_dim[1],tolerance + psu_dim[2]])
        rotate([box_angle - 90,0,0])
            translate([0,-40,thickness+tolerance])
            children();       
    }
}


module spider_web() {
    
    steps = 8;
    
    $fn = 32;
    rotate([0,0,30])
    for (i = [0:steps-1]) 
        rotate([0,0,i * 360/steps]) {
            
            for (j = [1:5])
            linear_extrude(thickness)
                translate([j * 32,0,0]) arc_profile(j * 15, 140, 220, thickness);
            
            rotate([0,0,360/steps/2])
                translate([50,0,thickness/2]) 
                    cube([140, thickness, thickness],center=true);
            
        }
}

module box_main() {
    difference() {
        union() {
                
            rotate([90,0,90])        
                box_main_base();
        
            mosfet_layout(mosfet_pad + thickness / 2) 
                four_cyls([mosfet_dim[0], mosfet_dim[1], mosfet_pad + thickness / 2], mosfet_holes, mosfet_hole_dia + thickness + pad_add);
            
            smoother_layout(smoother_pad + thickness / 2)
                four_cyls([smoother_dim[0], smoother_dim[1], smoother_pad + thickness / 2], smoother_holes, smoother_hole_dia + thickness + pad_add);
            
            translate([0,0,-thickness]) {
                translate([-thickness,-thickness,0]) foot();
                translate([box_dim[0],-thickness,0]) rotate([0,0,90]) foot();
                translate([box_dim[0],box_dim[1]+thickness,0]) rotate([0,0,180]) foot();
                translate([-thickness,box_dim[1]+thickness,0]) rotate([0,0,270]) foot();
            }
            
            wire_holder_layout()
                wire_holder();
            
            box_hinge(hinge_offset + tolerance + hinge_length);
            box_hinge((box_dim[1] - hinge_length) - hinge_offset - tolerance - hinge_length);
            
            translate([-tolerance, motherboard_spacing - 15, 60])
            rotate([0,180,-90])
            wire_arc(l = 10);

        }
        
        psu_layout(thickness+tolerance+1) four_cyls([psu_dim[0],psu_dim[1],thickness + 2], psu_holes, psu_hole_dia);
        fan_layout(thickness + 2.5 + fan_pad) 
            fan_hole(thickness+2);
        
        mosfet_layout(mosfet_pad + thickness + 2)
            four_cyls([mosfet_dim[0], mosfet_dim[1], mosfet_pad + thickness + 3], mosfet_holes, mosfet_hole_dia);
        
        smoother_layout(smoother_pad + thickness + 2)
            four_cyls([smoother_dim[0], smoother_dim[1], smoother_pad + thickness + 3], smoother_holes, smoother_hole_dia);
        
        ctrl_layout(0) {
            translate([0,0,-1]) four_cyls([ctrl_dim[0], screen_board_height, ctrl_dim[2] + 2], ctrl_holes, ctrl_hole_dia);    
            ctrl_controls("diff", tolerance);
            ctrl_screen("diff", tolerance);
        }
        
        power_connector_layout(thickness + 1) power_connector("hole");
        power_button_layout(-1) power_button("hole");
        
        
        translate([box_dim[0]/2,box_dim[1]+thickness*2/3,10])rotate([90,0,180])
        linear_extrude(thickness) {
            translate([0,15,0]) text("TEVO", size=20, halign="center");
            text("Black widow", size=10, halign="center");
        }
        
        motherboard_layout() 
            motherboard_usb("diff", thickness + 5, tolerance - 1, tolerance, 10);
        
        lid_tooth_layout()
            lid_tooth("diff", tolerance);
        
        translate([box_dim[0]/2,box_dim[1]/2 - 20,box_dim[2] + thickness*2/3])
            spider_web();
    }
}

module box_lid() {
    difference() {
        union() {
            rotate([90,0,90])
                box_lid_base();
            motherboard_layout(motherboard_pad + thickness / 2)
                four_cyls([motherboard_dim[0],motherboard_dim[1],motherboard_pad + thickness / 2], motherboard_holes, motherboard_hole_dia + thickness + pad_add);
            translate([0,0,thickness])
            motherboard_layout(motherboard_pad + board_thickness + tolerance) 
                motherboard_usb("diff", thickness, tolerance, tolerance/2, -3, 3);
            lid_tooth_layout()
                lid_tooth();
            
            translate([box_dim[0] + tolerance, motherboard_spacing - 15, 90])
                rotate([0,180,90])
                    wire_arc(l = 10);
            
            lid_hinge(hinge_offset);
            lid_hinge(box_dim[1] - hinge_offset - hinge_length);
            
        }
        
        ctrl_layout(tolerance + ctrl_pad)
            ctrl_sdslot("diff", tolerance);

        motherboard_layout(motherboard_pad + thickness + 2) 
            four_cyls([motherboard_dim[0],motherboard_dim[1],motherboard_pad + thickness + 3], motherboard_holes, motherboard_hole_dia);
                
        translate([ box_dim[0] - tolerance, motherboard_spacing, box_dim[2] - tolerance - motherboard_dim[0] - 20 - 10 ])
            cube([thickness + tolerance * 2, motherboard_dim[1], 20]);
        
    }
}

module box() {
    box_main();
    box_lid();
}


module hinge_layout(off = 0) {
    translate([box_dim[0] - hinge_inner_r, off, -thickness * 2 - tolerance - hinge_inner_r ])
        children();
}

module hinge_cyl() {
    rotate([-90,0,0])
    cylinder(r = hinge_inner_r + thickness, h = hinge_length, $fn = 64);
}

module hinge_pin() {
    rotate([-90,0,0])
        translate([0,0,-1])
            cylinder(r = hinge_inner_r, h = hinge_length + 2, $fn = 64);
}

module box_hinge(off = 0) {
    hinge_layout(off) {
        difference() {
            hull() {
                hinge_cyl();
                
                l = (hinge_inner_r + thickness) * 2;
                
                translate([-l - thickness, 0, hinge_inner_r + thickness + tolerance])
                cube([l, hinge_length, thickness]);
            }
            hinge_pin();
        }
    }
}

module lid_hinge(off = 0) {
    hinge_layout(off) {
        difference() {
            hinge_cyl();
            hinge_pin();
        }
        translate([hinge_inner_r,0,0])
        cube([thickness, hinge_length, hinge_inner_r + thickness + tolerance*2]);
    }
}

if (mode == "model") {
    
    color("red") psu_layout() psu();
    color("yellow") mosfet_layout() mosfet();
    color("green") motherboard_layout() motherboard();
    
    color("blue") smoother_layout() smoother();
    color("orange") fan_layout() fan();
    ctrl_layout(tolerance + ctrl_pad) ctrl("model", 0);
    
    color("#444444")
    box_main();
   
    color("red")
    box_lid();
    
    color("green")
    power_button_layout(-21)
    power_button();
    
    color("darkred")
    power_connector_layout(8)
        power_connector();
}
if (mode == "power_connector_test") {
    
    #difference() {
        translate([-15, -5, 1])
            cube([60, 30, 5]);
        power_connector("hole",10);
    }
    
    translate([0,0,-4.5])
    power_connector();
}
if (mode == "box")
    rotate([0,-90,-90]) box_main();

if (mode == "lid") 
    translate([0,box_dim[2] + thickness,box_dim[0] + thickness])
    rotate([0,90,-90])     
        box_lid();
    
if (mode == "hinge") {
    
    translate([-10,-160,0,])
    intersection() {
        translate([0,box_dim[2] + thickness,box_dim[0] + thickness])
        rotate([0,90,-90])
            box_lid();
        
        translate([20,box_dim[2] - 5,0])
        cube([80, 20, 20]);
    }
    
    
    translate([0,0,10])
    rotate([0,-90,0])
    translate([-box_dim[0],-50,0])
    intersection() {
        box_main();
        
        translate([box_dim[0] - 10, 50, -10])
        cube(50);
    }
    
}

//power_hole(5);

// wires
/*
    motors:
    - x
    - y
    - z
    - e0
    
    extruder:
    - thermistor
    - heater
    - extruder fan
    - model fan
    
    limit switch:
    - x limit switch
    - y limit switch
    - z limit switch
    
    bltouch:
    - pwm
    - z-probe
    
    bed:
    - heater power (4 wires)
    - thermistor
    
    summary:
     - 4 stepper wires
     
    
*/


