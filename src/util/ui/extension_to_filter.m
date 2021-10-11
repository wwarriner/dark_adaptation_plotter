function f = extension_to_filter(ext)
    ext = string(ext);
    ext = fix_extension(ext);
    f = "*" + ext;
end

