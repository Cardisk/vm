module bmk;

import format;
import buffer;
import utils;

import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::core::string;

String output;

fn void quit(Buffer(<char>) *b) {
    io::printn("Quitting...");
    libc::exit(0);
}

fn void done(Buffer(<char>) *b) {
    io::printn("----------");
    io::printn("Buffer:");
    io::printfn("> len: %d", b.len);
    io::printfn("> capacity: %d", b.capacity);
    io::printn();
    io::printfn("Writing to '%s'...", output);

    File! out = file::open(output, "wb");
    if (catch out) utils::panic("Unable to open the file provided.");

    libc::fwrite(b.data, char.sizeof, b.len, out.file);

    io::printn("Done.");
    io::printn("----------");

    libc::exit(0);
}

fn void help(Buffer(<char>) *b) {
    io::printn("----------");
    io::printn("--- VM Commands");
    foreach (op : format::Code.names) {
        io::printn(string::new_format("> %s", op));
    }

    io::printn("--- Raw Commands");
    foreach (op : Cmd.names) {
        io::printn(string::new_format("> %s", op));
    }
    io::printn("----------");
}

fn void wb(Buffer(<char>) *b) {
    b.transaction();
    String in = utils::input("byte");

    int base = 10;
    if (in.starts_with("b")) {
        in = in[1..];
        base = 2;
    }

    char! c = in.to_uchar(base);
    if (catch c) {
        utils::warning("Unable to convert input into byte");
        b.rollback();
        return;
    }
    
    b.write(c);
}

fn void wc(Buffer(<char>) *b) {
    b.transaction();
    String in = utils::input("char");

    if (in.len < 1) {
        utils::warning("Input needs to contain at least one char.");
        b.rollback();
        return;
    }

    b.write(in[0]);
}

fn void wl(Buffer(<char>) *b) {
    b.transaction();
    String in = utils::input("long");

    int base = 10;
    if (in.starts_with("b")) {
        in = in[1..];
        base = 2;
    }
    
    long! value = in.to_long(base);
    if (catch value) {
        utils::warning("Unable to convert input into long.");
        b.rollback();
        return;
    }

    utils::wlong(b, value);
}

fn void wi(Buffer(<char>) *b) {
    b.transaction();
    String in = utils::input("int");

    int base = 10;
    if (in.starts_with("b")) {
        in = in[1..];
        base = 2;
    }
    
    int! value = in.to_int(base);
    if (catch value) {
        utils::warning("Unable to convert input into int.");
        b.rollback();
        return;
    }

    utils::wint(b, value);
}

fn void ws(Buffer(<char>) *b) {
    b.transaction();
    String in = utils::input("string");

    if (in.len < 1) {
        utils::warning("Input needs to contain at least one char.");
        b.rollback();
        return;
    }

    foreach(c : in) {
        b.write(c);
    }
}

fn void wdp(Buffer(<char>) *b) {
    b.transaction();

    Buffer(<String>) strs;
    if (catch b.init()) utils::panic("Unable to allocate buffer memory.");

    String in;

    in = utils::input("strings (number)");

    int! val = in.to_int();
    if (catch val) {
        utils::warning("Unable to convert input into int.");
        b.rollback();
        return;
    }

    ulong size;
    for (int i = 0; i < val; i++) {
        in = utils::input(string::new_format("string %d", i + 1));
        strs.write(in);
        size += in.len;
    }

    utils::wlong(b, size);

    for (int i = 0; i < strs.len; i++) {
        foreach (c : strs.data[i]) {
            b.write(c);
        }
    }
}

enum Cmd {
    QUIT,
    DONE,
    HELP,
    WB,
    WC,
    WI,
    WL,
    WS,
    WDP,
}


const Op[*] CMDS = {
    &quit,
    &done,
    &help,
    &wb,
    &wc,
    &wi,
    &wl,
    &ws,
    &wdp,
};

fn void main(String[] args) {
    if (args.len != 2) utils::usage();

    output = args[1];

    Buffer(<char>) b;
    if (catch b.init()) utils::panic("Unable to allocate buffer memory.");

    while (true) {
        String in = utils::input();
        in.convert_ascii_to_upper();

        Cmd! cmd = enum_by_name(Cmd, in);
        if (try cmd) CMDS[cmd](&b);

        format::Code! code = enum_by_name(format::Code, in);
        if (try code) format::CODES[code](&b);
    }
}
