module runtime;

import vm;
import utils;
import std::io;
import std::core::string;
import libc;

// 1B opcode
enum Code : uint {
    INVALID,
    EXIT,
    PRINT,
    // MOV,
    // CMP,
    // JMP,
    // ADD,
    // SUB,
    // MUL,
    // DIV,
    // PUSH,
    // POP,
    // LOAD,
    // STORE,
}

// 0x01 <1B code>
fn void exit(Vm *vm) {
    if (vm.ip >= vm.code.len) {
        utils::crash("Exit instruction: Missing exit code.");
    }

    int code = (int) vm.code[vm.ip];
    libc::exit(code);
}

// 0x02 <8B index> <8B size>
fn void print(Vm *vm) {
    if (vm.ip >= vm.code.len) {
        utils::crash("Print instruction: Missing data pool index.");
    }

    ulong index = vm::read_long(vm);
    ulong size  = vm::read_long(vm);

    io::print(vm.data[index : size]);
}

fn void exec(Vm *vm) {
    while (vm.ip < vm.code.len) {
        int opcode = vm.code[vm.ip];
        vm.ip++;

        switch ((Code) opcode) {
            case Code.EXIT:
                exit(vm);
            case Code.PRINT:
                print(vm);
            default:
                utils::crash(string::new_format("Unknown opcode: %s", (Code) opcode));
        }
    }
}
