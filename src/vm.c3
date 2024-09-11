module vm;

import utils;
import std::io;
import std::core::string;

const String MAGIC = "vm";

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
    if (self.bytecode.len < 2) {
        utils::crash("Magic code: Too few bytes provided.",
                     string::new_format("Expected %d, got %d.", 
                                        MAGIC.len, self.bytecode.len));
    }

    if (!self.bytecode.starts_with("vm")) {
        utils::crash("Magic code: Invalid combination provided.",
                     string::new_format("Expected '%s', got '%s'.", 
                                        MAGIC, self.bytecode[:2]));
    }
}

fn Vm init(String data) {
    String! txt = utils::read_file(data);
    if (catch err = txt) {
        utils::crash(string::new_format("Unable to read the file: %s", err));
    }

    Vm vm;
    // TODO: maybe trimming the bytecode is not a good idea
    // a better way could be crashing when encountering 
    // a malformed instruction.
    vm.bytecode = txt!!.trim();

    vm.eat_magic();
    if (vm.bytecode.len < 8) {
        utils::crash("Data pool: Too few bytes provided.",
                     string::new_format("Expected 8, got %d.", 
                                        vm.bytecode.len - MAGIC.len));
    }

    ulong data_size = vm.bytecode[0];

    // ISSUE(#2): need to initialize the slices correctly here
    vm.data = vm.bytecode[:data_size];
    vm.code = vm.bytecode[(MAGIC.len + vm.data.len)..];

    return vm;
}
