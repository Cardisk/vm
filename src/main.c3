module entry;

import utils;
import vm;
import runtime;

import std::io;
import std::core::string;
import libc;

fn void usage(String pname) {
    io::printn(string::new_format("[ USAGE ]: %s <file>", pname));
    libc::exit(1);
}

fn void main(String[] args) {
    assert(args.len != 0, "No command line args, ouch your os sucks!");
    if (args.len < 2) usage(args[0]);

    vm::Vm vm = vm::init(args[1]);
    runtime::exec(&vm);

    io::printn("EXECUTION COMPLETED.");
}
