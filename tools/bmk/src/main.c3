module bmk;

import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::core::string;

// TODO: collapse this two structs into a single one
struct Buffer {
    char[] data;
    usz len;
    usz capacity;
}

struct Strings {
    String[] data;
    usz len;
    usz capacity;
}

fn void! Buffer.init(&buf, usz capacity = 10) {
    char[]! data = mem::new_array(char, capacity);
    if (catch e = data) return e?;

    buf.data = data;
    buf.len = 0;
    buf.capacity = capacity;
}

fn void Buffer.write(&buf, char c) {
    if (buf.len >= buf.capacity - 1) {
        buf.capacity *= 2;
        char *ptr = (char *) mem::realloc(buf.data, buf.capacity);
        buf.data = ptr[: buf.capacity];
    }

    buf.data[buf.len++] = c;
}

fn void! Strings.init(&strs, usz capacity = 10) {
    String[]! data = mem::new_array(String, capacity);
    if (catch e = data) return e?;

    strs.data = data;
    strs.len = 0;
    strs.capacity = capacity;
}

fn void Strings.write(&strs, String str) {
    if (strs.len >= strs.capacity - 1) {
        strs.capacity *= 2;
        String *ptr = (String *) mem::realloc(strs.data, strs.capacity);
        strs.data = ptr[: strs.capacity];
    }

    strs.data[strs.len++] = str;
}

fn void fatal(anyfault msg) {
    io::eprintfn("[ FATAL ]: %s", msg);
}

fn void warning(String msg) {
    io::eprintfn("[ WARNING ]: %s", msg);
}

fn bool is_num(char c) {
    switch (c) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return true;
        default:
            return false;
    }
}

fn void append_byte(Buffer *buf) {
    io::print("byte > ");
    String! num = io::readline();
    if (catch e = num) {
        fatal(e);
        return;
    }

    int base = 10;
    if (num.starts_with("b")) {
        num = num[1..];
        base = 2;
    }

    char! c = num.to_uchar(base);
    if (catch e = c) {
        fatal(e);
        return;
    }
    
    buf.write(c);
}

fn void append_char(Buffer *buf) {
    io::print("char > ");
    String! num = io::readline();
    if (catch e = num) {
        fatal(e);
        return;
    }

    buf.write(num[0]);
}

fn void append_long(Buffer *buf) {
    io::print("long > ");
    String! num = io::readline();
    if (catch e = num) {
        fatal(e);
        return;
    }

    int base = 10;
    if (num.starts_with("b")) {
        num = num[1..];
        base = 2;
    }

    long! l = num.to_long(base);
    if (catch e = l) {
        fatal(e);
        return;
    }
    
    for (int i = 0; i < long.sizeof; i++) {
        buf.write((char)(l >> 8 * i));
    }
}

fn void append_int(Buffer *buf) {
    io::print("int > ");
    String! num = io::readline();
    if (catch e = num) {
        fatal(e);
        return;
    }

    int base = 10;
    if (num.starts_with("b")) {
        num = num[1..];
        base = 2;
    }

    int! val = num.to_int(base);
    if (catch e = val) {
        fatal(e);
        return;
    }
    
    for (int i = 0; i < int.sizeof; i++) {
        buf.write((char)(val >> 8 * i));
    }
}

fn void append_str(Buffer *buf) {
    io::print("str > ");
    String! str = io::readline();
    if (catch e = str) {
        fatal(e);
        return;
    }

    foreach(c : str) {
        buf.write(c);
    }
}

fn void append_data(Buffer *buf) {
    Strings strs;
    if (catch e = strs.init()) {
        fatal(e);
        return;
    }

    io::print("strs num > ");
    String! in = io::readline();
    if (catch e = in) {
        fatal(e);
        return;
    }

    int! val = in.to_int();
    if (catch e = val) {
        fatal(e);
        return;
    }

    for (int i = 0; i < val; i++) {
        io::print(string::new_format("str %d > ", i + 1));
        String! str = io::readline();
        if (catch e = str) {
            fatal(e);
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

    Buffer buf;
    if (catch e = buf.init()) {
        fatal(e);
        return;
    }

    while (true) {
        io::print("> ");
        String! in = io::readline();
        if (catch e = in) {
            fatal(e);
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
                warning(string::new_format("invalid command '%s'", in));
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
        fatal(e);
        return;
    }

    libc::fwrite(buf.data, char.sizeof, buf.len, out.file);

    io::printn("Done.");
    io::printn("----------");
}
