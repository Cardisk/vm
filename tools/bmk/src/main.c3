module bmk;

import format;
import buffer;
import utils;

import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::core::string;

fn void append_byte(Buffer(<char>) *buf) {
    io::print("byte > ");
    String! num = io::readline();
    if (catch e = num) {
        utils::fatal(e);
        return;
    }

    int base = 10;
    if (num.starts_with("b")) {
        num = num[1..];
        base = 2;
    }

    char! c = num.to_uchar(base);
    if (catch e = c) {
        utils::fatal(e);
        return;
    }
    
    buf.write(c);
}

fn void append_char(Buffer(<char>) *buf) {
    io::print("char > ");
    String! num = io::readline();
    if (catch e = num) {
        utils::fatal(e);
        return;
    }

    buf.write(num[0]);
}

fn void append_long(Buffer(<char>) *buf) {
    io::print("long > ");
    String! num = io::readline();
    if (catch e = num) {
        utils::fatal(e);
        return;
    }

    int base = 10;
    if (num.starts_with("b")) {
        num = num[1..];
        base = 2;
    }

    long! l = num.to_long(base);
    if (catch e = l) {
        utils::fatal(e);
        return;
    }
    
    for (int i = 0; i < long.sizeof; i++) {
        buf.write((char)(l >> 8 * i));
    }
}

fn void append_int(Buffer(<char>) *buf) {
    io::print("int > ");
    String! num = io::readline();
    if (catch e = num) {
        utils::fatal(e);
        return;
    }

    int base = 10;
    if (num.starts_with("b")) {
        num = num[1..];
        base = 2;
    }

    int! val = num.to_int(base);
    if (catch e = val) {
        utils::fatal(e);
        return;
    }
    
    for (int i = 0; i < int.sizeof; i++) {
        buf.write((char)(val >> 8 * i));
    }
}

fn void append_str(Buffer(<char>) *buf) {
    io::print("str > ");
    String! str = io::readline();
    if (catch e = str) {
        utils::fatal(e);
        return;
    }

    foreach(c : str) {
        buf.write(c);
    }
}

fn void append_data(Buffer(<char>) *buf) {
    Buffer(<String>) strs;
    if (catch e = strs.init()) {
        utils::fatal(e);
        return;
    }

    io::print("strs num > ");
    String! in = io::readline();
    if (catch e = in) {
        utils::fatal(e);
        return;
    }

    int! val = in.to_int();
    if (catch e = val) {
        utils::fatal(e);
        return;
    }

    for (int i = 0; i < val; i++) {
        io::print(string::new_format("str %d > ", i + 1));
        String! str = io::readline();
        if (catch e = str) {
            utils::fatal(e);
            return;
        }
            
        strs.write(str);
    }

    ulong size;
    for (int i = 0; i < strs.len; i++) {
        size += strs.data[i].len;
    }


    for (int i = 0; i < long.sizeof; i++) {
        buf.write((char)(size >> 8 * i));
    }

    for (int i = 0; i < strs.len; i++) {
        foreach (c : strs.data[i]) {
            buf.write(c);
        }
    }
}

fn void main(String[] args) {
    if (args.len < 2) {
        io::eprintn("[ USAGE ]: bmk <output>");
        return;
    }

    Buffer(<char>) buf;
    if (catch e = buf.init()) {
        utils::fatal(e);
        return;
    }

    while (true) {
        io::print("> ");
        String! in = io::readline();
        if (catch e = in) {
            utils::fatal(e);
            return;
        }

        in.convert_ascii_to_lower();
        
        if (in == "exit") {
            io::printn("Quitting...");
            return;
        }

        if (in == "done") break;

        switch (in) {
            case "wb":
                append_byte(&buf);
            case "wc":
                append_char(&buf);
            case "wl":
                append_long(&buf);
            case "wi":
                append_int(&buf);
            case "ws":
                append_str(&buf);
            case "wdp":
                append_data(&buf);
            default:
                utils::warning(string::new_format("invalid command '%s'", in));
                continue;
        }
    }

    io::printn("----------");
    io::printn("Buffer:");
    io::printfn("> len: %d", buf.len);
    io::printfn("> capacity: %d", buf.capacity);
    io::printn();
    io::printfn("Writing to '%s'...", args[1]);

    File! out = file::open(args[1], "wb");
    if (catch e = out) {
        utils::fatal(e);
        return;
    }

    libc::fwrite(buf.data, char.sizeof, buf.len, out.file);

    io::printn("Done.");
    io::printn("----------");
}
