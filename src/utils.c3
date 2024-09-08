module utils;

import std::io::file;

fn String! read_file(String path) {
    File! f = file::open(path, "r");
    if (catch err = f) return err?;

    // TODO: maybe handle possible errors with file.close()?
    defer (void) f.close();
    
    usz! len = file::get_size(path);
    if (catch err = len) return err?;

    char[]! buffer = mem::new_array(char, len);
    if (catch err = buffer) return err?;

    usz! read = f.read(buffer);
    if (catch err = read) return err?;

    return (String) buffer;
}
