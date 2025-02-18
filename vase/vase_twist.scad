



linear_extrude(100, twist = 180, $fn = 200, slices = 200)
circle(d = 80, $fn = 8);

linear_extrude(100, twist = -180, $fn = 200, slices = 200)
circle(d = 80, $fn = 8);
   