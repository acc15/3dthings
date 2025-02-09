//import("Wanhao_D6_Cable_Holder.stl");


difference() {

translate([-7.83,-9.28,0])
import("Wanhao_D6_Cable_Holder.stl");

translate([-50,0,0])
cube(50);

}


$fa = 0.5;
$fs = 0.1;


t = 2;
cable_width = 25;
cable_height = 20;

add_l = 10;
add_offset = 8;
add_all = add_l + add_offset;
old_t = 2.17;


translate([0,46/2 - (cable_width+t*2)/2,27.5])
rotate([0,-90,0])
union() {

translate([0,0,add_offset-old_t])
linear_extrude(add_l + old_t)
difference() {
    
    //offset(2)
    //offset(-2)
    square([t*3, cable_width+t*2]);
    
    union() {
    translate([t, t])
    square([t, cable_width]);
    translate([t, t*2])
    square([t*3, cable_width - t*2]);
    }
    
}


translate([0,0,add_all])
rotate([-90,0,0])
linear_extrude(cable_width+t*2)
difference() {
    polygon([[-add_all, add_all + old_t], [-add_all, add_all], [0, 0], [0, add_all+old_t]]);
    translate([-add_all,0])
    circle(r = add_all);
}
//polygon([[-add_all, add_all + old_t], [-add_all, add_all], [0, 0], [0, add_all+old_t]]);


}

/*

//translate([0,0,add_all])
//rotate([-90,0,0])
linear_extrude(cable_width+t*2)
difference() {
    polygon([[-add_all, add_all + old_t], [-add_all, add_all], [0, 0], [0, add_all+old_t]]);
    translate([-add_all,0])
    circle(r = add_all);
}*/
