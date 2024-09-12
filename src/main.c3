module entry;

import utils;
import vm;
import runtime;

import std::io;
import std::core::string;

fn void main(String[] args) {
    vm::Vm vm = vm::init("resources/bytecode");
    runtime::exec(&vm);
    
    io::printn("EXECUTION COMPLETED.");
}
