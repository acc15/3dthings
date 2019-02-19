

tolerance = 1;

wire_dia = 3;
cut_dia = 6;
pad_height = 4;
hole_count = 6;
hold_dia = 7.1;


ext_dia = 20;
inner_dia = 12;

ext_height = 10;
inner_height = 10;
hold_height = 10;
hole_height = pad_height + ext_height + inner_height;
hole_offset = wire_dia;//(ext_dia / 2 - wire_dia / 2) / 2; 


module hold(h,f=1) {
    linear_extrude(h, $fn = 64)
        offset(f)
            offset(-f)
                circle(d = hold_dia, $fn = 6);
}

module inner() {
    hull() {

        translate([0,0,inner_height - 0.1])
            hold(0.1);

        cylinder(d = inner_dia, h = 0.1, $fn = 128);
        
    }
}

module pad() {
    cylinder(d = ext_dia, h = pad_height, $fn = 128);
}

difference() {

    union() {
        
        pad();
        
        translate([0,0,pad_height])
            linear_extrude(ext_height, scale = inner_dia/ext_dia)
                circle(d = ext_dia, $fn = 128);
        translate([0,0,pad_height+ext_height])
            inner();
        translate([0,0,pad_height+ext_height+inner_height])
            hold(h = hold_height);

        
    }
    
    for (i = [0:hole_count-1]) 
        let(a = i * 360 / hole_count, r = ext_dia / 2 - hole_offset, r2 = r + (cut_dia - wire_dia) / 2) {
            translate([cos(a) * r2, sin(a) * r2,pad_height])
                cylinder(d = cut_dia, h = hole_height - pad_height, $fn = 128);
            translate([cos(a) * r, sin(a) * r,-tolerance])
                cylinder(d = wire_dia, h = hole_height, $fn = 128);        
        }        
            
                
            


}



