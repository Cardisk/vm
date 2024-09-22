module vm;

import utils;
import std::io;
import std::core::string;
import std::collections::map;

const String MAGIC = "vm";
// 32KB
const usz STACK_SIZE = 1024 * 32;

fault VmError {
    EOF,
    FEW_BYTES,
    OUT_OF_BOUND,
}

struct Var {
    ulong stack_index;
    ulong byte_size;
}

struct Vm {
    // Instruction pointer
    ulong ip;
    // Base stack pointer
    ulong bp;
    // Stack pointer
    ulong sp;

    // Hashmap containing vars info
    map::HashMap(<String, Var>) vars;

    // 32KB
    char[STACK_SIZE] stack;
    // heap is forwarded to the vm one,
    // so no custom allocators are needed.

    // Bytecode
    String bytecode; 
    // Data pool
    String data;
    // Code pool
    String code;
}

fn void magic(Vm *vm) @private {
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

fn Vm init(String data, bool debug = true) {
    String! txt = utils::read_file(data);
    if (catch err = txt) {
        utils::crash(string::new_format("Unable to read the file: %s", err));
    }

    Vm vm;
    vm.bytecode = txt!!;

    magic(&vm);
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

    if (debug) {
        utils::log("--- VM tearup");
        utils::log(string::new_format("Bytecode  size: %d", vm.bytecode.len));
        utils::log(string::new_format("Data pool size: %d", vm.data.len));
        utils::log(string::new_format("Code pool size: %d", vm.code.len));
    }

    return vm;
}

fn void destroy(Vm *vm, bool debug = true) {
    if (debug) {
        utils::log("--- VM teardown");
        utils::log(string::new_format("Instruction pointer: %d", vm.ip));
        utils::log(string::new_format("Base stack pointer: %d", vm.bp));
        utils::log(string::new_format("Stack pointer: %d", vm.sp));

        utils::log("Stack:");
        String stack = "\t";
        for (usz i = 0; i < vm.sp; i++) {
            stack = stack.concat(string::new_format("%b ", vm.stack[i]));
        }
        utils::log(stack);
        utils::log("");

        utils::log(string::new_format("Variables registered: %d", 
                    vm.vars.count));
        utils::log("Variables: ");
        foreach (e : vm.vars.table) {
            if (e != null) {
                utils::log(
                    string::new_format("\t%s = { .stack_index = %d, .byte_size = %d }",
                                       e.key, e.value.stack_index, e.value.byte_size
                ));
            }
        }
    }

    vm.bytecode.free();
    // no need to free code and data,
    // both are pointing inside the bytecode.
    vm.vars.free();
}

fn ulong! read_code_long(Vm *vm) {
    if (vm.ip > vm.code.len - 8) return VmError.FEW_BYTES?;

    ulong value = 0;
    int j = 0;
    
    usz i = vm.ip;
    while (i < vm.ip + ulong.sizeof) {
        value |= ((ulong)(vm.code[i])) << (8 * j++);
        i++;
    }
    vm.ip = i;

    return value;
}

fn int! read_code_int(Vm *vm) {
    if (vm.ip > vm.code.len - 4) return VmError.FEW_BYTES?;

    int value = 0;
    int j = 0;
    
    usz i = vm.ip;
    while (i < vm.ip + int.sizeof) {
        value |= ((int)(vm.code[i])) << (8 * j++);
        i++;
    }
    vm.ip = i;

    return value;
}

fn int! read_stack_int(Vm *vm, ulong index) {
    if (index > STACK_SIZE - int.sizeof) return VmError.OUT_OF_BOUND?;

    int value = 0;
    int j = 0;

    usz i = index;
    while (i < index + int.sizeof) {
        value |= ((int)(vm.stack[i])) << (8 * j++);
        i++;
    }

    return value;
}

fn void! write_stack_int(Vm *vm, ulong index, int value) {
    if (vm.sp > STACK_SIZE - int.sizeof) return VmError.OUT_OF_BOUND?;

    for (int i = 0; i < int.sizeof; i++) {
        vm.stack[index++] = (char)(value >> 8 * i);
    }

    // TODO: find a better way to handle this case
    if (index - int.sizeof == vm.sp) vm.sp = index;
}
