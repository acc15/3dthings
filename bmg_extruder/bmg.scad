
union() {
import("Part1.STL");



union() {



#translate([-21,21,0])
cylinder(d = 14, h = 21, $fn = 32);

#translate([-13.5,5.5,0])
cylinder(d = 5, h = 21, $fn = 32);

#translate([-13.5,5.5,0])
cylinder(d = 8, h = 2.8, $fn = 32);

#translate([-36.5,0,0.86])
cube([23, 13.5, 20.14]);

#translate([-30.5,13,1])
cube([11, 7, 20]);
    
}

}

translate([-42,0,0])
cube([42, 10, 10]);

/*
#translate([-25,0,10.5])
rotate([-90,0,0])
cylinder(d = 4.2, h = 80, $fn = 64);*/