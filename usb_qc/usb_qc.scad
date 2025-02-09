board_dim = [ 50, 33, 1.58 ];
wall = [0.48*2, 0.48*2, 0.3*3];
tol = 0.2;

board_spacing = 3;


usb_out_dim = [10,13.2,8.1-board_dim[2]];
usb_out_pos= [board_dim[0] - 10, board_dim[1]/2-13.2/2, board_dim[2]];
usb_in_dim = [18.8, 12, 4.8];
usb_in_pos = [-15.6, 2.6, 0];
display_dim = [15.2, 8.2, 5.8 - board_dim[2]];
display_pos = [board_dim[0]/2-15.2/2,board_dim[1]-8.2, board_dim[2]];
usbc_in_dim = [7.3, 9, 4.86 - board_dim[2]];
usbc_in_pos = [0, board_dim[1] - usbc_in_dim[1] - 1.4, board_dim[2]];

btn_dim = [6,3.6,4.1-board_dim[2]]; // 3.9 pushed
btn_push_dim = [2.6, 1.25, 1];

plus_btn_pos = [14,1.9,board_dim[2]];
minus_btn_pos = [board_dim[0]-btn_dim[0]-14,1.9,board_dim[2]];

$fa=0.2;
$fs=0.2;


module button_model() {
    translate([(btn_dim[0]-btn_push_dim[0])/2,(btn_dim[1]-btn_push_dim[1])/2,btn_dim[2]-btn_push_dim[2]])
    color("red") 
    cube(btn_push_dim);
    
    color("green") 
    cube([btn_dim[0],btn_dim[1],btn_dim[2]-btn_push_dim[2]]);
}

// 2.6, 1.25
module board_model() {
    *color("darkblue") cube(board_dim);
    color("green") translate(usb_in_pos) cube(usb_in_dim);
    color("yellow") translate(usbc_in_pos) cube(usbc_in_dim);
    color("purple") translate(display_pos) cube(display_dim);
    color("blue") translate(usb_out_pos) cube(usb_out_dim);
    translate(plus_btn_pos) button_model();
    translate(minus_btn_pos) button_model();
    
}



module box_bottom() {

    difference() {
        cube([board_dim[0] + tol * 2 + wall[0] * 2, board_dim[1] + tol * 2 + wall[1] * 2, wall[2] + board_spacing + board_dim[2]]);
            
        translate([wall[0], wall[1], wall[2]])
        union() {
            translate([0,0,board_spacing])
            cube([board_dim[0] + tol*2, board_dim[1] + tol*2, board_dim[2]+tol]);
            
            translate([0,1,0])
            cube([board_dim[0] + tol*2, board_dim[1] + tol*2 - 2, board_spacing+tol]);
            
            translate([usb_in_pos[0], usb_in_pos[1], board_spacing-tol])
            cube([usb_in_dim[0],usb_in_dim[1]+tol*2,usb_in_dim[2]+tol*2]);
            
        }

    }
    
}

module ring(d1, d2, h) {
    linear_extrude(h)
    difference() {
        circle(d=max(d1,d2));
        circle(d=min(d2,d1));
    }
    
}

module box_top() {
    difference() {
        cube([board_dim[0] + tol * 2 + wall[0] * 2, board_dim[1] + tol * 2 + wall[1] * 2, wall[2] + tol + usb_out_dim[2]]);
    
        translate([wall[0], wall[1], -tol]) {
        
            cube([board_dim[0] + tol * 2, board_dim[1] + tol * 2, tol+usb_out_dim[2]+tol]);

            translate([tol,tol,0]) {
                
                translate([usb_in_pos[0],usb_in_pos[1]-tol,0])
                cube([usb_in_dim[0],usb_in_dim[1]+tol*2,usb_in_dim[2] - board_dim[2] + tol*2]);
                
                translate([usbc_in_pos[0] - wall[0] - tol*2,usbc_in_pos[1]-tol,0])
                cube([usbc_in_dim[0],usbc_in_dim[1]+tol*2,usbc_in_dim[2] + tol*2]);
                
                translate([usb_out_pos[0]+wall[0]+tol*2,usb_out_pos[1]-tol,0])
                cube([usb_out_dim[0],usb_out_dim[1] + tol*2, usb_out_dim[2] + tol*2]);
                
                translate([display_pos[0]-tol,display_pos[1]-tol,0])
                cube([display_dim[0]+tol*2, display_dim[1]+tol, wall[2] + tol*3 + usb_out_dim[2]]);
                
                translate([plus_btn_pos[0]+btn_dim[0]/2, plus_btn_pos[1]+btn_dim[1]/2,0])
                cylinder(d=btn_dim[1], h=wall[2] + tol*3 + usb_out_dim[2]);
                
                translate([minus_btn_pos[0]+btn_dim[0]/2, minus_btn_pos[1]+btn_dim[1]/2,0])
                cylinder(d=btn_dim[1], h=wall[2] + tol*3 + usb_out_dim[2]);
            }

            
        }
    }
   
    
    translate([wall[0]+tol, wall[1]+tol,0]) {
    
        translate([plus_btn_pos[0]+btn_dim[0]/2, plus_btn_pos[1]+btn_dim[1]/2, btn_dim[2]+tol+wall[2]])
        ring(btn_dim[0], btn_dim[0]+wall[0]*2, usb_out_dim[2]-btn_dim[2]);

        translate([minus_btn_pos[0]+btn_dim[0]/2, minus_btn_pos[1]+btn_dim[1]/2, btn_dim[2]+tol+wall[2]])
        ring(btn_dim[0], btn_dim[0]+wall[0]*2, usb_out_dim[2]-btn_dim[2]);
                
    }
    
    
}

module box_button() {
    cylinder(d=btn_dim[0]-tol*2,h=usb_out_dim[2]-btn_dim[2]-tol);
    translate([0,0,usb_out_dim[2]-btn_dim[2]-tol*2])
    cylinder(d=btn_dim[1]-tol*2,h=tol+wall[2]+2);
}

translate([wall[0]+tol, wall[1]+tol, wall[2]+board_spacing]) {
    
translate([plus_btn_pos[0]+btn_dim[0]/2,plus_btn_pos[1]+btn_dim[1]/2,plus_btn_pos[2] + btn_dim[2] + tol])
box_button();

translate([minus_btn_pos[0]+btn_dim[0]/2,minus_btn_pos[1]+btn_dim[1]/2,minus_btn_pos[2] + btn_dim[2] + tol])
box_button();
    
}

#translate([0,0,wall[2] + board_spacing + board_dim[2]])
box_top();
box_bottom();

translate([wall[0]+tol, wall[1]+tol, wall[2]+board_spacing])
board_model();

//cube([board_dim[0]+tol*2+wall[0]*2, 

18650_dim_flat = 66;
18650_dim_full = 67.35;