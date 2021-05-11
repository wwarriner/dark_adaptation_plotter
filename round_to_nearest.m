function v = round_to_nearest(v, nearest)

v = v ./ nearest;
v = round(v, 0);
v = nearest .* v;

end

