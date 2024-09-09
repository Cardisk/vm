module vm;

import utils;
import std::io;

fn void eat_magic(String *data) {
    if ((*data).len < 2) utils::crash("Missing magic code: Too few bytes.");  

    if (!(*data).starts_with("vm")) {
        utils::crash("Missing magic code: Invalid magic code.");
    }

    (*data) = (*data).trim("vm");
}

fn void main(String[] args) {
    String! txt = utils::read_file("resources/bytecode");
    if (catch err = txt) {
        io::printf("Unable to read the file: %s", err);
        return;
    }

    eat_magic(&txt);
    io::printn("SUCCESS!");
}
