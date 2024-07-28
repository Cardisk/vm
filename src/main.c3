module vm;

import std::io;

const int BUF_LEN = 100;

fn void main(String[] args) {
    File! f = io::file::open(args[1], "r");
    if (catch err = f) {
        io::printfn("fatal: Failed to open %s: %s.", args[1], err);
        return;
    }

    // TODO: maybe is better to handle the possible error here
    defer (void) f.close();

    usz! len = f.seek(0, END);
    if (catch err = len) {
        io::printfn("fatal: Failed to seek %s: %s.", args[1], err);
        return;
    }

    if (len > BUF_LEN) {
        io::printfn("fatal: length of %s is greater than BUF_LEN(%d).", args[1], BUF_LEN);
        return;
    }

    char[BUF_LEN] buf;
    usz! read = f.read(&buf);
    if (catch err = read) {
        io::printfn("fatal: Failed to read %s: %s.", args[1], err);
        return;
    }

    if (read < len) {
        io::printfn("fatal: read only %d chars from %s instead of %d.", read, args[1], len);
        return;
    }

    io::printn(buf);
}
