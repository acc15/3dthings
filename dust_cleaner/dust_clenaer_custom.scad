
difference() {
    import("FilamentDustCleanerFilter_Blank.stl");

    translate([20-47.5,12.5,8.5-3])
    cylinder(d = 5.01 + 0.1, h = 3.1, $fn = 64);

    translate([20,12.5,8.5-3])
    cylinder(d = 5.01 + 0.1, h = 3.1, $fn = 64);
    
}