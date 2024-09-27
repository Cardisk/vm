module format;

import utils;
import buffer;

import libc;
import std::io;

fn void exit(Buffer(<char>) *b) {
    b.write((char) Code.EXIT);
    
    String in = utils::input("byte");

    if (in.starts_with("b")) {
        in = in[1..];
        b.write(in.to_uchar(2));
        return;
    }

    b.write(in[0]);
}

fn void print(Buffer(<char>) *b) {

}


fn void vardecl(Buffer(<char>) *b) {

}

fn void math(Buffer(<char>) *b) {

}

def Op = fn void(Buffer(<char>) *b);

enum Code : uint (String desc, Op func) {
    EXIT    = { "exit",    exit    },
    PRINT   = { "print",   print   },
    VARDECL = { "vardecl", vardecl },
    MATH    = { "math",    math    },
}

fn String Code.format(&self) {
    switch (*self) {
        case Code.EXIT:
            return "<1B code>";

        case Code.PRINT:
            return "<1B mode> <?B operand[s]>";

        case Code.VARDECL:
            return "<8B name_index> <8B name_size> <1B type> <?B operand[s]>";

        case Code.MATH:
            return "<1B operation> <1B operands_mode> <1B storing mode> <?B operand[s]>";

        default:
            io::eprintfn("[ FATAL ]: Unknwon opcode %s.", *self);
            libc::exit(1);
    }

    return "";
}


