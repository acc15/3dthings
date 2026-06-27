door_thickness = 40;
length = 30;
thickness = 3;
tie_thickness = 1.5;
tie_width = 8;

linear_extrude(10)
difference() {
    union() {
        square([thickness*2+door_thickness, length]);
        #translate([thickness+door_thickness+tie_thickness,0])
        square([thickness, tie_width+thickness*2]);
    }
    translate([thickness,thickness])
    square([door_thickness, length]);
    
    translate([thickness+door_thickness,thickness])
    square([tie_thickness, tie_width]);
}
