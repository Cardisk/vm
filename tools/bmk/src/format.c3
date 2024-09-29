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

    in.convert_ascii_to_upper();
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

    in.convert_ascii_to_upper();
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

enum MathOperation {
    ADD,
    SUB,
    MUL,
    DIV,
}

enum MathMode {
    VAR_IMM,
}

enum MathStore {
    INC,    
}

fn void math(Buffer(<char>) *b) {
    b.transaction();
    b.write((char) Code.MATH);

    String in;
    int base;

    in = utils::input("operation (string)");

    in.convert_ascii_to_upper();
    MathOperation! operation = enum_by_name(MathOperation, in);
    if (catch operation) {
        utils::warning("Inalid operation provided.");
        b.rollback();
        return;
    }

    b.write((char) operation);

    in = utils::input("mode (string)");

    in.convert_ascii_to_upper();
    MathMode! mode = enum_by_name(MathMode, in);
    if (catch mode) {
        utils::warning("Inalid mode provided.");
        b.rollback();
        return;
    }

    b.write((char) mode);

    in = utils::input("storing (string)");

    in.convert_ascii_to_upper();
    MathStore! store = enum_by_name(MathStore, in);
    if (catch store) {
        utils::warning("Inalid store provided.");
        b.rollback();
        return;
    }

    b.write((char) store);

    switch (mode) {
        case VAR_IMM:
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
            
            in = utils::input("var type (string)");

            in.convert_ascii_to_upper();
            VarType! type = enum_by_name(VarType, in);
            if (catch type) {
                utils::warning("Invalid type provided.");
                b.rollback();
                return;
            }

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
                    utils::warning("Invalid type provided.");
                    b.rollback();
                    return;
            }

        default:
            utils::warning("Unknown operation mode provided.");
            b.rollback();
            return;
    }
}

def Op = fn void(Buffer(<char>) *b);

enum Code {
    EXIT,
    PRINT,
    VARDECL,
    MATH,
}

const Op[*] CODES = {
    &exit,
    &print,
    &vardecl,
    &math
};

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


