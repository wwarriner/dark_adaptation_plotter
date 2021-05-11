function v = floor_to_nearest(v, nearest)

v = v ./ nearest;
v = floor(v);
v = nearest .* v;

end

