module format;

import utils;
import buffer;

import libc;
import std::io;

fn void exit(Buffer(<char>) *b) {
    b.transaction();
    b.write((char) Code.EXIT);
    
    String in = utils::input("code (byte)");

    int base = 10;
    if (in.starts_with("b")) {
        in = in[1..];
        base = 2;
    }

    char! res = in.to_uchar(base);
    if (catch res) {
        utils::warning("Unable to convert input into byte.");
        b.rollback();
        return;
    }

    b.write(res);
}

enum PrintMode {
    DATASTR,
    CODEINT,
    CODELNG,
    VAR,
}

fn void print(Buffer(<char>) *b) {
    b.transaction();
    b.write((char) Code.PRINT);

    String in;
    int base;

    in = utils::input("mode (string)");

    PrintMode! mode = enum_by_name(PrintMode, in);
    if (catch mode) {
        utils::warning("Inalid mode provided.");
        b.rollback();
        return;
    }

    b.write((char) mode);

    switch (mode) {
        case DATASTR:
            in = utils::input("str index (long)");

            base = 10;
            if (in.starts_with("b")) {
                in = in[1..];
                base = 2;
            }
            
            long! index = in.to_long(base);
            if (catch index) {
                utils::warning("Unable to convert input into long.");
                b.rollback();
                return;
            }

            utils::wlong(b, index);
            
            in = utils::input("str size  (long)");
            
            base = 10;
            if (in.starts_with("b")) {
                in = in[1..];
                base = 2;
            }
            
            long! size = in.to_long(base);
            if (catch size) {
                utils::warning("Unable to convert input into long.");
                b.rollback();
                return;
            }

            utils::wlong(b, size);
        
        case CODEINT:
            in = utils::input("value (int)");

            base = 10;
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
        
        case CODELNG:
            in = utils::input("value (long)");

            base = 10;
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
        
        case VAR: 
            in = utils::input("var name index (long)");

            base = 10;
            if (in.starts_with("b")) {
                in = in[1..];
                base = 2;
            }
            
            long! index = in.to_long(base);
            if (catch index) {
                utils::warning("Unable to convert input into long.");
                b.rollback();
                return;
            }

            utils::wlong(b, index);
            
            in = utils::input("var name size  (long)");
            
            base = 10;
            if (in.starts_with("b")) {
                in = in[1..];
                base = 2;
            }
            
            long! size = in.to_long(base);
            if (catch size) {
                utils::warning("Unable to convert input into long.");
                b.rollback();
                return;
            }

            utils::wlong(b, size);
        
        default:
            utils::warning("Unknown mode provided.");
            b.rollback();
    }
}

enum VarType {
    INT,
    LONG,
}

fn void vardecl(Buffer(<char>) *b) {
    b.transaction();
    b.write((char) Code.VARDECL);

    String in;
    int base;

    in = utils::input("var name index (long)");

    base = 10;
    if (in.starts_with("b")) {
        in = in[1..];
        base = 2;
    }
    
    long! index = in.to_long(base);
    if (catch index) {
        utils::warning("Unable to convert input into long.");
        b.rollback();
        return;
    }

    utils::wlong(b, index);
    
    in = utils::input("var name size  (long)");
    
    base = 10;
    if (in.starts_with("b")) {
        in = in[1..];
        base = 2;
    }
    
    long! size = in.to_long(base);
    if (catch size) {
        utils::warning("Unable to convert input into long.");
        b.rollback();
        return;
    }

    utils::wlong(b, size);


    VarType! type = enum_by_name(VarType, in);
    if (catch type) {
        utils::warning("Inalid type provided.");
        b.rollback();
        return;
    }

    b.write((char) type);

    switch (type) {
        case INT:
            in = utils::input("value (int)");

            base = 10;
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

        case LONG:
            in = utils::input("value (long)");

            base = 10;
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

        default:
            utils::warning("Unknown type provided.");
            b.rollback();
    }
}

fn void math(Buffer(<char>) *b) {
    b.transaction();
    b.write((char) Code.MATH);

}

def Op = fn void(Buffer(<char>) *b);

enum Code : uint (String desc, Op func) {
    EXIT     =  { "exit",    &exit    },
    PRINT    =  { "print",   &print   },
    VARDECL  =  { "vardecl", &vardecl },
    MATH     =  { "math",    &math    },
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
            io::eprintfn("[ FATAL ]: Unknown opcode %s.", *self);
            libc::exit(1);
    }

    return "";
}


