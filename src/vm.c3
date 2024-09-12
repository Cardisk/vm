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

fn void eat_magic(Vm *vm) @private {
    if (vm.bytecode.len < 2) {
        utils::crash("Magic code: Too few bytes provided.",
                     string::new_format("Expected %d, got %d.", 
                                        MAGIC.len, vm.bytecode.len));
    }

    if (!vm.bytecode.starts_with("vm")) {
        utils::crash("Magic code: Invalid combination provided.",
                     string::new_format("Expected '%s', got '%s'.", 
                                        MAGIC, vm.bytecode[:2]));
    }
}

fn Vm init(String data) {
    String! txt = utils::read_file(data);
    if (catch err = txt) {
        utils::crash(string::new_format("Unable to read the file: %s", err));
    }

    Vm vm;
    // ISSUE(#3): maybe trimming the bytecode is not a good idea
    // a better way could be crashing when encountering 
    // a malformed instruction.
    vm.bytecode = txt!!.trim();

    eat_magic(&vm);
    if (vm.bytecode.len < 8) {
        utils::crash("Data pool: Too few bytes provided.",
                     string::new_format("Expected 8, got %d.", 
                                        vm.bytecode.len - MAGIC.len));
    }

    ulong data_size;
    for (int i = MAGIC.len; i < MAGIC.len + ulong.sizeof; i++) {
        data_size |= (ulong) (vm.bytecode[i] << 8 * i);
    }

    vm.data = vm.bytecode[MAGIC.len : data_size];
    vm.code = vm.bytecode[(MAGIC.len + vm.data.len)..];

    return vm;
}
