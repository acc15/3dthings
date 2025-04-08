$fa = 0.2;
$fs = 0.2;

fan_center_dia = 31;
fan_dia = 47;
fan_thickness = 15;
fan_bolt_dia = 4.5;
fan_bolt_offsets = [ [-18, -20], [ 20, 23 ] ];
fan_out_distance = 25.4;
fan_out_ext_height = 20;


module fan() {
    
    //translate([-2,0])
    //circle(d = fan_dia);
        
    for (off = fan_bolt_offsets) {
        translate(off)
            circle(d = fan_bolt_dia);        
    }
    
    translate([-fan_out_distance,0])
    square([fan_out_distance, fan_out_ext_height]);
    

}

fan();

