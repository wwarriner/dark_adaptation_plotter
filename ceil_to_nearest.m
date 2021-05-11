function v = ceil_to_nearest(v, nearest)

v = v ./ nearest;
v = ceil(v);
v = nearest .* v;

end

