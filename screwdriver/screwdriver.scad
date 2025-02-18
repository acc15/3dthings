bit_small_d = 4;
bit_d = 4*2/sqrt(3);
bit_h = 10;

screwdriver_d = 15;
screwdriver_h = 50;
screwdriver_cut = 25.5;
screwdriver_handle_d = 5;
screwdriver_handle_off = 8.3;
screwdriver_handle_n = 6;

magnet_d = 5;
magnet_h = 2.8;

t = 2;
tol = 0.2;

$fa = 0.4;
$fs = 0.4;

translate([0,0,screwdriver_h])
linear_extrude(bit_h)
difference() {
    
circle(d = bit_d + t*3+tol*3);
circle(d = bit_d + tol*3, $fn = 6);
    
}

echo(bit_d + t*2+tol*3);

difference() {
    

    translate([0,0,screwdriver_h/2])
    scale([1,1,(screwdriver_h+screwdriver_cut)/screwdriver_d])
    sphere(d = screwdriver_d);


    translate([-screwdriver_d/2, -screwdriver_d/2, -screwdriver_cut - tol])
    cube([screwdriver_d, screwdriver_d, screwdriver_cut + tol]);
        
    translate([-screwdriver_d/2, -screwdriver_d/2, screwdriver_h])
    cube([screwdriver_d, screwdriver_d, screwdriver_cut + tol]);
                
    for (i = [0:screwdriver_handle_n-1])
        rotate([0,0,i*(360/screwdriver_handle_n)])
            translate([screwdriver_handle_off,0,0])
                cylinder(d = screwdriver_handle_d, h = screwdriver_h+tol*2);
    
    translate([0,0,screwdriver_h - magnet_h])
    cylinder(d = magnet_d + tol*3, h = magnet_h);
    
    
}