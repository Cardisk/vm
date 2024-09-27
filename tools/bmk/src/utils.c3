module utils;

import std::io;

fn void fatal(anyfault msg) {
    io::eprintfn("[ FATAL ]: %s", msg);
}

fn void warning(String msg) {
    io::eprintfn("[ WARNING ]: %s", msg);
}

fn String input(String msg = "") {
    io::printf("%s> ", msg);
    
    String! in = io::readline();
    if (catch e = num) {
        utils::fatal(e);
    }

    return in!!;
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
