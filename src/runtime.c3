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
    ADD,
    // MOV,
    // CMP,
    // JMP,
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
    int code = (int) vm.code[vm.ip++];
    
    // normally called from the main.
    vm::destroy(vm);
    
    libc::exit(code);
}

// <opcode> <8B index> <8B size>
fn void print(Vm *vm) {
    ulong! index = vm::read_code_long(vm);
    if (catch index) {
        utils::crash("Print instruction: Missing/uncomplete data pool index.");
        return;
    }

    ulong! size = vm::read_code_long(vm);
    if (catch size) {
        utils::crash("Print instruction: Missing/uncomplete string size.");
        return;
    }

    io::print(vm.data[index : size]);
}

// <opcode> <8B index> <8B size> <1B type> <?B operand>
fn void vardecl(Vm *vm) {
    ulong! name_index = vm::read_code_long(vm);
    if (catch name_index) {
        utils::crash("Var declaration: Missing/uncomplete var name index.");
        return;
    }

    ulong! name_size = vm::read_code_long(vm);
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
            int! value = vm::read_code_int(vm);
            if (catch value) {
                utils::crash("Var declaration: Missing/uncomplete var value");
                return;
            }

            ulong stack_index = vm.sp;
            if (catch vm::write_stack_int(vm, vm.sp, value)) {
                utils::crash("Var declaration: Unable to append to the stack.",
                             "Stack pointer has gone out of bounds.");
                return;
            }

            vm::Var v = {stack_index, int.sizeof};
            vm.vars.set(var_name, v);
        default:
            utils::crash("Var declaration: Unknown type provided.");
            break;
    }
}

// describes how to read the next byte[s]
enum OpMode {
    VAR_IMM,
}

// describes where to store the result of the operation
enum OpStoreMode {
    INC,
}

// <opcode> <1B mode> <1B storing mode> <?B operand[s]>
fn void add(Vm *vm) {
    if (vm.ip >= vm.code.len) {
        utils::crash("Add instruction: Missing operation mode.");
        return;
    }
    char mode = vm.code[vm.ip++];

    if (vm.ip >= vm.code.len) {
        utils::crash("Add instruction: Missing operation mode.");
        return;
    }
    char store = vm.code[vm.ip++]; 

    switch ((OpMode) mode) {
        case OpMode.VAR_IMM:
            ulong! name_index = vm::read_code_long(vm);
            if (catch name_index) {
                utils::crash("Add instruction: Missing/uncomplete var name index.");
                return;
            }

            ulong! name_size = vm::read_code_long(vm);
            if (catch name_size) {
                utils::crash("Add instruction: Missing/uncomplete var name size.");
                return;
            }

            String var_name = vm.data[name_index : name_size];
            Var! var_info = vm.vars[var_name];
            if (catch var_info) {
                utils::crash("Add instruction: Undecleared var provided.");
                return;
            }
            
            switch (var_info.byte_size) {
                case int.sizeof:
                    int! lhs = vm::read_stack_int(vm, var_info.stack_index);
                    if (catch lhs) {
                        utils::crash("Add instruction: Stack out of bound.");
                        return;
                    }
    
                    int! rhs = vm::read_code_int(vm);
                    if (catch rhs) {
                        utils::crash("Add instruction: Missing/uncomplete operand.");
                        return;
                    }

                    switch ((OpStoreMode) mode) {
                        case OpStoreMode.INC:
                            if (catch vm::write_stack_int(vm, var_info.stack_index, lhs + rhs)) {
                                utils::crash("Add instruction: Stack out of bound.");
                                return;
                            }
                        default:
                            utils::crash(string::new_format("Add instruction: Invalid storing mode '%d'", mode));
                    } 

                default:
                    utils::crash(string::new_format("Add instruction: '%s' is unsupported.", 
                                                    var_name));
            }

        default:
            utils::crash(string::new_format("Add instruction: Unknown mode '%s'", 
                                            (OpMode) mode));
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
            case Code.ADD:
                add(vm);
            default:
                utils::crash(string::new_format("Unknown opcode: %s", (Code) opcode));
        }
    }
}
