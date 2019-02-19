
fnresolution = 1;
include <e3d_v6_all_metall_hotend.scad>;

xplate_t = 3.2;

/*
translate([0,xplate_t,0])
rotate([90,0,0])
translate([-111.75,0,0]) import("X_-_plate.stl");*/

//translate([0,0,65.6]) rotate([180,0,0]) e3d($fs = 1);
//import("E3D_V6_1.75mm_Universal_HotEnd_Mockup.stl");


module titan() {
    cube([44.5, 46.5, 24.5]);
    // chamfer 4.5 (left-bottom edge)
    
    // holes 
    //5.65, 7.65 
    
    // 15.5 45 degree line
    // 90 degree rot 3 hole
    
    // 1 bottom hole
    // 2.65, 1.65
    // dia 16.5
    // depth 1.4
    
    // 2 bottom hole
    // 12.5 dia
    // depth 6 mm
    
    // 3 bottom hole
    // dia same as 1
    // depth 5 mm
    
    // 15 mm offset from front
    // dia 34 third hole
    // depth 4mm
    
}

module emotor() {
    
    cube([42.3, 42.3, 22.75]);
    // hole 3mm offset [15.5, 15.5] mm from center
    // chamfer diagonal 54

    // front dia 22mm offset center depth 2mm
    
    
    // connector [16.25, 9, 6]
    
    // rotor dia 5mm offset center depth 20.75
    
    // rotor 2mm left offset depth 18.5
    
}

titan();