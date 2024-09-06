module vm;

import std::io;
import std::core::mem;

fn void main(String[] args) {
    String path = "README.md";
    File! f = file::open(path, "r");
    if (catch err = f) {
        io::printf("FATAL: Failed to open '%s': %s", path, err);
        return;
    }

    // TODO: maybe handle possible errors with file.close()?
    defer (void) f.close();
    
    usz! len = file::get_size(path);
    if (catch err = len) {
        io::printf("FATAL: Unable to get size of '%s': %s", path, err);
        return;
    }

    char[]! buffer = mem::new_array(char, len);
    if (catch err = buffer) {
        io::printf("FATAL: Unable to allocate %d bytes: %s", len, err);
        return;
    }

    usz! read = f.read(buffer);
    if (catch err = read) {
        io::printf("FATAL: Failed to read content of '%s': %s", path, err);
        return;
    }

    io::printf("Read %d bytes\n", read);
    io::printn(buffer);
}
