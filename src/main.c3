module vm;

import utils;
import std::io;

fn void main(String[] args) {
    String! txt = utils::read_file("README.md");
    if (catch err = txt) {
        io::printf("Unable to read the file: %s", err);
        return;
    }

    io::printn(txt);
}
