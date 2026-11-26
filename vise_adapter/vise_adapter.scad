use <bendlib/bendlib.scad>;

vise_dim = [ 74.6, 11.5, 13.5 ];
vise_ear = 6;

rubber_thickness = 3;
rubber_mount_dim = [ 82, 5, 2.5 ];

rubber_dim = [
    rubber_mount_dim[0] + rubber_thickness*2, 
    22.5,
    21.5
];

thickness = (rubber_mount_dim[0] - vise_dim[0]) / 2;
height = thickness + rubber_mount_dim[2];//rubber_thickness; - rubber_mount_dim[2] - vise_dim[2];

module vise_lip() {
    cube(vise_dim);
}

module adapter_80() {

    module ear_mount() {
        translate([thickness + rubber_thickness,0,0]) {
            cube([thickness, vise_dim[1] + thickness, height + vise_dim[2]]);
        
            translate([0,vise_dim[1],0])
            cube([thickness + vise_ear, thickness, height + vise_dim[2]]);        
            cube([thickness + vise_ear, vise_dim[1]+thickness, height]);
        }
        cube([thickness*2 + rubber_thickness, vise_dim[1]+thickness, thickness]);
        cube([thickness, vise_dim[1]+thickness, height + vise_dim[2] + rubber_mount_dim[2]]);
    }


    translate([thickness+rubber_thickness,0,height + vise_dim[2]]) {
        cube(rubber_mount_dim);
        
        translate([0,rubber_mount_dim[1] + rubber_thickness,0])
        cube([rubber_mount_dim[0], vise_dim[1] + thickness - rubber_mount_dim[1] - rubber_thickness, rubber_mount_dim[2]]);
    }

    ear_mount();

    translate([vise_dim[0] + thickness*4+rubber_thickness*2,0,0])
    mirror([1,0,0])
    ear_mount();
    
}

module rubber() {
    
    translate([thickness,-rubber_thickness,thickness])
    rotate([90,0,90]) {
        
        linear_extrude(rubber_dim[0])
        polygon([
            [0,0], 
            [rubber_thickness,0],
            [rubber_thickness,rubber_dim[2] - rubber_thickness],
            [rubber_thickness+rubber_mount_dim[1], rubber_dim[2] - rubber_thickness],
            [rubber_thickness+rubber_mount_dim[1], rubber_dim[2] - rubber_thickness - rubber_mount_dim[2]],
            [rubber_thickness*2+rubber_mount_dim[1], rubber_dim[2] - rubber_thickness - rubber_mount_dim[2]],
            [rubber_thickness*2+rubber_mount_dim[1], rubber_dim[2]],
            [0, rubber_dim[2]],
        ]);
        
        cube([rubber_dim[1], rubber_dim[2], rubber_thickness]);
        
        translate([0,0,rubber_dim[0] - rubber_thickness])
        cube([rubber_dim[1], rubber_dim[2], rubber_thickness]);
    }
}

module adapter_80_demo() {
    #rubber();

    color("yellow")
    translate([thickness*2 + rubber_thickness,0,height])
    vise_lip();

    adapter_80();
}

rubber_tpu_thickness = 1.5;
rubber_tpu_contact = 4;
rubber_tpu_bottom_wall = 0;

module rubber_tpu() {
    
    
    
    module rubber_square() {
        square([rubber_tpu_thickness + vise_dim[1] + rubber_tpu_contact, rubber_tpu_bottom_wall+rubber_tpu_thickness + vise_dim[2]]);
    }
    
    module rubber_shape(inner=false) {
        difference() { 
            rubber_square();
            translate([inner?-1:rubber_tpu_thickness,rubber_tpu_bottom_wall])
            square([vise_dim[1]+(inner?1+rubber_tpu_thickness:0), vise_dim[2]]);
        }
    }
    
    translate([rubber_tpu_thickness*2+vise_dim[0],vise_dim[1]+rubber_tpu_thickness+rubber_tpu_contact,0])
    rotate([90,0,-90]) {
        bl_extrude_tower([rubber_tpu_thickness,vise_ear,vise_dim[0]-vise_ear*2,vise_ear,rubber_tpu_thickness]) {
            rubber_square();
            rubber_shape(false);
            rubber_shape(true);
            rubber_shape(false);
            rubber_square();
        }
    }
    
}

module rubber_tpu_demo() {
    #rubber_tpu();
    translate([rubber_tpu_thickness,rubber_tpu_contact,rubber_tpu_thickness])
    vise_lip();
}

translate([0,rubber_tpu_contact+vise_dim[1]+rubber_tpu_thickness,vise_dim[2]+rubber_tpu_thickness])
rotate([180,0,0])
rubber_tpu();


*rubber_tpu_demo();
//adapter_80_demo();



