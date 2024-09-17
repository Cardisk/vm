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

    // General purpose
    usz r1;
    usz r2;
    usz r3;
    usz r4;
    usz r5;
    usz r6;
    usz r7;
    usz r8;
    usz r9;
    usz r10;
    usz r11;
    usz r12;

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
    vm.bytecode = txt!!;

    eat_magic(&vm);
    if (vm.bytecode.len < 8) {
        utils::crash("Data pool: Too few bytes provided.",
                     string::new_format("Expected 8, got %d.", 
                                        vm.bytecode.len - MAGIC.len));
    }

    ulong data_size;
    int j = 0;
    for (int i = MAGIC.len; i < MAGIC.len + ulong.sizeof; i++) {
        data_size |= ((ulong)(vm.bytecode[i])) << (8 * j++);
    }


    vm.data = vm.bytecode[(MAGIC.len + ulong.sizeof) : data_size];
    vm.code = vm.bytecode[((MAGIC.len + ulong.sizeof) + data_size)..];

    utils::log(string::new_format("Bytecode  size: %d", vm.bytecode.len));
    utils::log(string::new_format("Data pool size: %d", vm.data.len));
    utils::log(string::new_format("Code pool size: %d", vm.code.len));

    return vm;
}
