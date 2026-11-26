use <bendlib/bendlib.scad>;


dim = [55, 40];

space = 0.4;
outer_space = 1;

lines = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1];
squares = [0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3];

module draw_lines(width, i = 0) {
    if (i < len(lines)) {
        
        square([width, lines[i]]);
        
        translate([0,lines[i] + space])
        draw_lines(width, i+1);
        
    }
}

module draw_squares(i = 0) {
    if (i < len(squares)) {
        
        difference() {
            square([squares[i], squares[i]]);
            offset(-space)
            square([squares[i], squares[i]]);
        }
        
        translate([squares[i] + space,0])
        draw_squares(i+1);
    }
    
}


difference() {
    square(dim);
    
    translate([outer_space,outer_space]) {
        draw_lines(dim[0] - outer_space*2);
        
        translate([0,bl_sum(lines) + len(lines)*space])
        draw_squares();
    }
    
}
