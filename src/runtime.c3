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
    VARDECL,
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

// <opcode> <1B code>
fn void exit(Vm *vm) {
    if (vm.ip >= vm.code.len) {
        utils::crash("Exit instruction: Missing exit code.");
    }

    // libc::exit accepts an integer
    int code = (int) vm.code[vm.ip];
    
    // normally called from the main.
    vm::destroy(vm);
    
    libc::exit(code);
}

// <opcode> <8B index> <8B size>
fn void print(Vm *vm) {
    ulong! index = vm::read_long(vm);
    if (catch index) {
        utils::crash("Print instruction: Missing/uncomplete data pool index.");
        return;
    }

    ulong! size = vm::read_long(vm);
    if (catch size) {
        utils::crash("Print instruction: Missing/uncomplete string size.");
        return;
    }

    io::print(vm.data[index : size]);
}

// <opcode> <8B index> <8B size> <1B type> <?B operand>
fn void vardecl(Vm *vm) {
    ulong! name_index = vm::read_long(vm);
    if (catch name_index) {
        utils::crash("Var declaration: Missing/uncomplete var name index.");
        return;
    }

    ulong! name_size = vm::read_long(vm);
    if (catch name_size) {
        utils::crash("Var declaration: Missing/uncomplete var name size.");
        return;
    }

    String var_name = vm.data[name_index : name_size];
    
    if (vm.ip >= vm.code.len) {
        utils::crash("Var declaration: Missing type info.");
        return;
    }

    // only 1B needed
    char type = vm.code[vm.ip++];
    switch (type) {
        // integer
        case 0x0:
            int! value = vm::read_int(vm);
            if (catch value) {
                utils::crash("Var declaration: Missing/uncomplete var value");
                return;
            }

            ulong stack_index = vm.sp;
            for (int i = 0; i < int.sizeof; i++) {
                vm.stack[vm.sp++] = (char)(value >> 8 * i);
            }

            vm::Var v = {stack_index, int.sizeof};
            vm.vars.set(var_name, v);
        default:
            utils::crash("Var declaration: Unknown type provided.");
            break;
    }
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
            case Code.VARDECL:
                vardecl(vm);
            default:
                utils::crash(string::new_format("Unknown opcode: %s", (Code) opcode));
        }
    }
}
