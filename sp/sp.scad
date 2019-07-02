

function at_or_value(array, i, def) = len(array) == undef ? def == undef ? array : def : array[i];

function arc(r, a, n, p = [0,0], l = true) = 
    let(
        r_start = at_or_value(r, 0), r_end = at_or_value(r, 1),
        a_start = at_or_value(a, 0, 0), a_end = at_or_value(a, 1),
        r_step = (r_end - r_start) / n, a_step = (a_end - a_start) / n
    )
    [ 
        for (i = [0 : l ? n : n - 1]) 
            let(cr = r_step * i + r_start, ca = a_step * i + a_start)
                [ cos(ca) * cr, sin(ca) * cr ]
    ];
               
function line_offset(line, off) = 
        let(v = line[1] - line[0], l = norm(v), n = [v[1], -v[0]] * off / l) 
        [line[0] + n, line[1] + n];
        
function line_intersection(l1, l2, eps = 0.0001) = let(
        x1 = l1[0][0], y1 = l1[0][1],
        x2 = l1[1][0], y2 = l1[1][1],
        x3 = l2[0][0], y3 = l2[0][1],
        x4 = l2[1][0], y4 = l2[1][1],
        d = (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)
) 
    abs(d) < eps ? undef : let(c1 = x1*y2 - y1*x2, c2 = x3*y4 - y3*x4) [c1 * (x3 - x4) - (x1 - x2) * c2, c1 * (y3 - y4) - (y1 - y2) * c2] / d;
      
line = [[5, 0], [5, 10]];
        
v = line[1] - line[0];
l = norm(v);
n = [v[1], -v[0]] * 3 / l;
echo(line, v, l, n, [line[0] + n, line[1] + n]);
        
echo(line_offset([[5, 0], [5, 10]], 3)); // ^
echo(line_offset([[0, 0], [-10, 0]], 3)); // <
echo(line_offset([[0, 10], [0, 0]], 3)); // v
echo(line_offset([[0, 10], [10, 10]], 3)); // >


echo(line_intersection([[5, 0], [5, 10]], [[0, 5], [-10, 5]]));