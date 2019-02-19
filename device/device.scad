include <MCAD/involute_gears.scad>

mode = "mount";

q = 0.4;

// motor speed: 110 rotations per second (12V)

t = 1.6;
d = 6;
h = 5;
l = 70;

wd = 60;

gh = 20;

motor_dia = 35.5;
motor_h = 50;
motor_sdia = 13;


module motor() {
    
    $fn = 64;
    
    translate([0,0,-56])
    color("blue") {
    
    translate([0,0,55])
    cylinder(d = 3.75, h = 14);
    
    translate([0,0,50])
    cylinder(d = motor_sdia, h = 5);
    
    cylinder(d = motor_dia, h = motor_h);
    }
    
}

module simple_gear(z, h, t, c = 0) {
    
        gear(z, 
        circular_pitch = 180,
        bore_diameter = h,
        hub_diameter = 10,   
        rim_width = 0,
        hub_thickness = t,
        gear_thickness = t,
        rim_thickness = t,
        circles = c);
}

module r_gears(m, c = 0, a = 0) {    
    rotate([0,0,a]) {
    
        translate([0,0,gh - 5])
        simple_gear(12*m, 6.4, 5, c);
        
        simple_gear(12, 6.4, gh - 5);
        
    }
}

module lead_gear() {
    color("green") 
        r_gears(6, 6, 2.5);
}

module small_gear() {
    r_gears(3, 0, 2.5);
}

module motor_gear() {
    color("red")
        simple_gear(8, 3.3, 12);
}

module wall(f = true, b = true) {
       
    w = 35;
    h = 40;
    bd = 12;
    sd = 8;
    hd = 6.4;
    
    difference() {
        union() {
            linear_extrude(t)
                polygon([[-w/2,0],[w/2,0],[bd/2,h],[-bd/2,h]]);

            translate([0,h])
                hull() {
                cylinder(d = bd, h = t);
            
                translate([0,0,f ? -t : 0])
                    cylinder(d = sd, h = t * ((f ? 1 : 0) + (b ? 1 : 0) + 1));
                }
            
        }
        
        translate([0, h, -t*2])
            cylinder(d = hd, h = t * 5);
    }
    
}



module gear_system() {
    
    translate([0,0,8]) {
        translate([-40,0,-gh]) lead_gear();
        translate([-40,0,-gh*2-t*3-q*2]) small_gear();
        translate([-64,0,-(gh*2)+5]) small_gear();
        translate([-64,0,-(gh*3)+5-t*3-q*2]) small_gear(); 
    }
    
}

module walls() {
    translate([-40,40,8+t+q])
    rotate([0,0,180]) {
    
        for (i = [0:2]) 
            translate([0,0,-i*(gh+t*3+q*2)])
                wall(i != 2, i != 0);

        for (i = [0:2]) 
            translate([24,0,-i*(gh+t*3+q*2) -15 ])
                wall(i != 2, i != 0);
        
    }
    
}

module mount() {


    translate([-90,40,-63])
    difference() {
        cube([120, t, 80]);
        
        translate([5,t*2,5])
        rotate([90,0,0])
        cylinder(d = 5, h = t*4);
        
        translate([5,t*2,80-5])
        rotate([90,0,0])
        cylinder(d = 5, h = t*4);
        
        translate([120-5,t*2,80-5])
        rotate([90,0,0])
        cylinder(d = 5, h = t*4);
        
        translate([120-5,t*2,5])
        rotate([90,0,0])
        cylinder(d = 5, h = t*4);
        
    }
    
    w = motor_dia + t * 2 + q * 2;
    translate([0, 40, -56])
    difference() {
        hull() {

            translate([0,-40, 0])
                cylinder(d = w, h = motor_h + 4);
        
            translate([-w/2,0,0])
                cube([w, t, motor_h + 4]);
            
            md = motor_dia + t * 4;
            

        }

        translate([0,-40-25/2,motor_h+t]) {
            cylinder(d = 4, h = t * 2);
            translate([0,25,0])
            cylinder(d = 4, h = t * 2);
        }


        translate([-w/2,-80,-q])
        cube([w + q * 2, w + q, motor_h * 6 / 7]);        

        translate([0,-40,-t])
        cylinder(d = motor_dia + q * 2, h = motor_h + 4);
        
        translate([0,-40,motor_h+t])
        cylinder(d = motor_sdia + q * 2, h = t * 2);
    
    }
    
    //translate([0,0,8-t+q])
    walls();
    
}


$fn = mode != "demo" ? 128 : $fn;

if (mode == "lead_gear") {

    translate([0,0,gh])
        rotate([180,0,0])
            lead_gear();
    
} else if (mode == "small_gear") {

    translate([0,0,gh])
        rotate([180,0,0])
            small_gear();
    
} else if (mode == "motor_gear") {
    
    motor_gear();
    
} else if (mode == "mount") {
    
    
    translate([0,0,40+t])
    rotate([-90,0,0])
    mount();
    
} else if (mode == "demo") {
    
    mount();
    gear_system();
    motor();
    motor_gear();
    
}
   
a = $t * 360;
//a = 0;

module disk() {
    
    color("green")
    union() {
        $fn = 64;
        translate([wd/2, 0, 3])
        cylinder(d = d - q*2, h = h);

        cylinder(d = wd + (d - q*2), h = 3);
            
    }
    
}

module rod(dim, d1 = d, d2 = d + t*2 + q*2) {
    linear_extrude(dim[2], $fn = 64) {
        difference() {
            union() {
                circle(d = d2);
                translate([-dim[0],0])
                    circle(d = d2);

                translate([-dim[0],-dim[1]/2])
                    square([dim[0], dim[1]]);
            }
            circle(d = d1);
            translate([-dim[0],0])
                circle(d = d1);
        }
    }
}

module throttle(a) {
    
    pos = [cos(a) * wd/2,sin(a) * wd/2,3];
    
    rotate([0,0,a])
    disk();

    translate(pos)
    rotate([0,0,asin(pos[1]/l)])
    rod([l, h, h]);

    translate([pos[0] - sqrt(l*l - pos[1]*pos[1]) - l,-t,0])
    square([l, t *2]);
    
}



