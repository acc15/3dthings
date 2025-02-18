
tol = 0.5;
card_d = [54, 85.5];
card_t = 0.75;
wall_t = 1.2;

card_d_t = card_d + [tol, tol] * 2;
card_t_t = card_t + tol * 2;

module card() {
    square(card_d_t);
}

module card_diff() {
    square(card_d_t + [0, wall_t + tol]);
}

module card_plate() {
    offset(wall_t, $fn = 32)
    card();
}


module ellipse(r1, r2) {
    
    scale([1, r2 / r1])
        circle(r = r1);
}

module ellipse_outline(r1, r2, t) {
    difference() {
        ellipse(r1, r2);
        offset(-t)
            ellipse(r1, r2);
    }
}


module react_logo() {
    $fn = 64;
    for (i = [0:2]) 
        rotate(i * 60) 
            ellipse_outline(10, 25, 2);
    circle(r = 4);
}



    

difference() {
    
    
    linear_extrude(wall_t + card_t_t + wall_t)
        card_plate();
    
    translate([0,0,wall_t])
        linear_extrude(card_t_t)
            card_diff();
    
    translate([card_d_t[0] / 2, card_d_t[1] / 2, wall_t * 1.5 + card_t_t])
        linear_extrude(wall_t)
            react_logo();
    
}
