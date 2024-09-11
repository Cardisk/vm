module vm;

import utils;
import std::io;
import std::core::string;

struct Vm {
    // Instruction pointer
    usz ip;
    // Base stack pointer
    usz bp;
    // Stack pointer
    usz sp;

    // 32KB
    char[1024 * 32] stack;
    // heap is forwarded to the vm one,
    // so no custom allocators are needed.

    // Bytecode
    String bytecode; 
    // Data pool
    String data;
    // Code pool
    String code;
}

fn void Vm.eat_magic(&self) @private {
    if (self.bytecode.len < 2) utils::crash("Magic code: Too few bytes provided.");  

    if (!self.bytecode.starts_with("vm")) {
        utils::crash("Magic code: Invalid combination provided.");
    }

    self.bytecode = self.bytecode.trim("vm");
}

fn Vm init(String data) {
    String! txt = utils::read_file("resources/bytecode");
    if (catch err = txt) {
        utils::crash(string::new_format("Unable to read the file: %s", err));
    }

    Vm vm;
    vm.bytecode = txt!!.trim();

    vm.eat_magic();

    // ISSUE(#2): need to initialize the slices correctly here
    vm.data = vm.bytecode;
    vm.code = vm.bytecode;

    return vm;
}
