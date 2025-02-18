
difference() {
    import("Wanhao_D6_Z-axis_Motor_Spacer_-6mm.stl");
    
    translate([0,0,-10])
    cylinder(d = 32, h = 80, $fn =256);
    
    translate([-50,-50,14])
    cube(100);
}

