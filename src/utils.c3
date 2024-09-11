module utils;

import std::thread;
import std::io::file;

fn String! read_file(String path, String mode = "r") {
    File! f = file::open(path, mode);
    if (catch err = f) return err?;

    // ISSUE(#1): maybe handle possible errors with file.close()?
    defer (void) f.close();
    
    usz! len = file::get_size(path);
    if (catch err = len) return err?;

    char[]! buffer = mem::new_array(char, len);
    if (catch err = buffer) return err?;

    usz! read = f.read(buffer);
    if (catch err = read) return err?;

    return (String) buffer;
}

fn void crash(String msg, String note = "", int code = 1) {
    io::eprintfn("[ FATAL ]: %s", msg);
    if (note.len > 0) io::eprintfn("[ NOTE  ]: %s", note); 
    thread::exit(code);
} 

fn void todo(String msg) {
    io::eprintfn("TODO: %s", msg);
    thread::exit(1);
}
