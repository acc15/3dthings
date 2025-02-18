
thickness = 0.48*8;

phone_thickness = 12;
mount_height = 50;
mount_angle = 15;
mount_width = 50;
shelf_height = 8;

function m_rot(angle) = let(c = cos(angle), s = sin(angle)) [ 
    [ c, s ],
    [ -s, c ]
];


function mount_poly() = 
    let( 
        fw = thickness + phone_thickness + thickness, 
        rot = m_rot(mount_angle),
        mp = [ thickness, thickness + mount_height ] * rot,
        mpn = [ mp[0] - mount_height * sin(mount_angle), thickness ]
    ) 
    concat(
        [
            [0,0], 
            [ fw / cos(mount_angle),0]
        ],
        [
            [ fw, thickness + shelf_height ],
            [ thickness + phone_thickness, thickness + shelf_height ],
            [ thickness + phone_thickness, thickness ],
            [ thickness, thickness ]
        ] * rot,
        [
            mp,
            mpn,
            [ mpn[0] - phone_thickness, mpn[1] ],
            [ mpn[0] - phone_thickness, mpn[1] + shelf_height ],
            [ mpn[0] - phone_thickness - thickness, mpn[1] + shelf_height ],
            [ mpn[0] - phone_thickness - thickness, 0 ],
            [ mp[0] * 2, 0 ],
            [ mp[0], -mp[0] * sin(90 - mount_angle) / sin(mount_angle) ]
        ]
    );



module mount_shape() {
    polygon(mount_poly());
}


module mount() {


    linear_extrude(mount_width)
    mount_shape();

}

module demo() {
    
    translate([mount_width/2,0,0])
    rotate([90,0,0])
    rotate([0,-90,0])
    mount();

}

mount();





