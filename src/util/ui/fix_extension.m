function ext = fix_extension(ext)
    ext = string(ext);
    ext = strip(ext, "left", ".");
    ext = "." + ext;
end

