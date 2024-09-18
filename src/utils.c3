module utils;

import libc;
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

fn usz occurrences(String haystack, String needle) {
    String tmp = haystack;
    usz occ = 0;
    while (true) {
        usz! index = tmp.index_of(needle);
        if (catch index) break;
        occ++;
        tmp = tmp[(index + needle.len)..];
    }

    return occ;
}

fn void crash(String msg, String note = "", int code = 1) {
    io::eprintfn("[ FATAL ]: %s", msg);
    if (note.len > 0) io::eprintfn("[ NOTE  ]: %s", note); 
    libc::exit(code);
} 

fn void todo(String fmt, args...) {
    io::eprintfn("[ TODO  ]: %s", string::new_format(fmt, args));
    libc::exit(1);
}

fn void log(String fmt, args...) {
    io::printfn("[ LOG   ]: %s", string::new_format(fmt, args));
}
