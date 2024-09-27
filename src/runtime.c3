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
    MATH,
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

enum PrintMode : uint {
    DATASTR,
    CODEINT,
    CODELNG,
    VAR,
}

// <opcode> <1B mode> <?B operand[s]>
fn void print(Vm *vm) {
    if (vm.ip >= vm.code.len) {
        utils::crash("Print instruction: Missing print mode.");
    }

    char mode = vm.code[vm.ip++];
    
    switch ((PrintMode) mode) {
        // data pool string
        case PrintMode.DATASTR:
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
        // int immediate
        case PrintMode.CODEINT:
            int! value = vm::read_code_int(vm);
            if (catch value) {
                utils::crash("Print instruction: Missing/uncomplete int operand.");
                return;
            }

            io::print(value);
        // long immediate
        case PrintMode.CODELNG:
            ulong! value = vm::read_code_long(vm);
            if (catch value) {
                utils::crash("Print instruction: Missing/uncomplete long operand.");
                return;
            }

            io::print((long) value);
        // variable
        case PrintMode.VAR:
            ulong! name_index = vm::read_code_long(vm);
            if (catch name_index) {
                utils::crash("Print instruction: Missing/uncomplete var name index.");
                return;
            }

            ulong! name_size = vm::read_code_long(vm);
            if (catch name_size) {
                utils::crash("Print instruction: Missing/uncomplete var name size.");
                return;
            }

            String var_name = vm.data[name_index : name_size];
            
            Var! var_info = vm.vars[var_name];
            if (catch var_info) {
                utils::crash("Math instruction: Undecleared var provided.");
                return;
            }

            switch (var_info.byte_size) {
                case int.sizeof:
                    int! value = vm::read_stack_int(vm, var_info.stack_index);
                    if (catch value) {
                        utils::crash("Print instruction: Stack out of bound.");
                        return;
                    }

                    io::print(value);
                case long.sizeof:
                    ulong! value = vm::read_stack_long(vm, var_info.stack_index);
                    if (catch value) {
                        utils::crash("Print instruction: Stack out of bound.");
                        return;
                    }

                    io::print((long) value);
                default:
                    utils::crash("Print instruction: Unknown type provided.");
            }
            
        default:
            utils::crash("Print instruction: Unknown print mode.");
    }
}

enum VarType : uint {
    INT,
    LONG,
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
    switch ((VarType) type) {
        // integer
        case VarType.INT:
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
        // long
        case VarType.LONG:
            ulong! value = vm::read_code_long(vm);
            if (catch value) {
                utils::crash("Var declaration: Missing/uncomplete var value");
                return;
            }

            ulong stack_index = vm.sp;
            if (catch vm::write_stack_long(vm, vm.sp, value)) {
                utils::crash("Var declaration: Unable to append to the stack.",
                             "Stack pointer has gone out of bounds.");
                return;
            }

            vm::Var v = {stack_index, long.sizeof};
            vm.vars.set(var_name, v);
        default:
            utils::crash("Var declaration: Unknown type provided.");
            break;
    }
}

enum MathOperation : uint {
    ADD,
    SUB,
    MUL,
    DIV,
}

// describes how to read the next byte[s]
enum MathMode : uint {
    VAR_IMM,
}

// describes where to store the result of the operation
enum MathStore : uint {
    INC,
}

// <opcode> <1B operation> <1B mode> <1B storing mode> <?B operand[s]>
fn void math(Vm *vm) {
    if (vm.ip >= vm.code.len) {
        utils::crash("Math instruction: Missing operation specifier.");
        return;
    }
    char operation = vm.code[vm.ip++];

    if (vm.ip >= vm.code.len) {
        utils::crash("Math instruction: Missing operation mode.");
        return;
    }
    char mode = vm.code[vm.ip++];

    if (vm.ip >= vm.code.len) {
        utils::crash("Math instruction: Missing operation mode.");
        return;
    }
    char store = vm.code[vm.ip++]; 

    switch ((MathMode) mode) {
        case MathMode.VAR_IMM:
            ulong! name_index = vm::read_code_long(vm);
            if (catch name_index) {
                utils::crash("Math instruction: Missing/uncomplete var name index.");
                return;
            }

            ulong! name_size = vm::read_code_long(vm);
            if (catch name_size) {
                utils::crash("Math instruction: Missing/uncomplete var name size.");
                return;
            }

            String var_name = vm.data[name_index : name_size];
            Var! var_info = vm.vars[var_name];
            if (catch var_info) {
                utils::crash("Math instruction: Undecleared var provided.");
                return;
            }
            
            switch (var_info.byte_size) {
                case int.sizeof:
                    int! lhs = vm::read_stack_int(vm, var_info.stack_index);
                    if (catch lhs) {
                        utils::crash("Math instruction: Stack out of bound.");
                        return;
                    }
    
                    int! rhs = vm::read_code_int(vm);
                    if (catch rhs) {
                        utils::crash("Math instruction: Missing/uncomplete operand.");
                        return;
                    }

                    int result;

                    switch ((MathOperation) operation) {
                        case MathOperation.ADD:
                            result = lhs + rhs;
                        case MathOperation.SUB:
                            result = lhs - rhs;
                        case MathOperation.MUL:
                            result = lhs * rhs;
                        case MathOperation.DIV:
                            result = lhs / rhs;
                        default:
                            utils::crash("Math instruction: Unknown operation provided.");
                    }

                    switch ((MathStore) mode) {
                        case MathStore.INC:
                            if (catch vm::write_stack_int(vm, var_info.stack_index, result)) {
                                utils::crash("Math instruction: Stack out of bound.");
                                return;
                            }
                        default:
                            utils::crash(string::new_format("Math instruction: Invalid storing mode '%d'", mode));
                    } 
                case long.sizeof:
                    ulong! lhs = vm::read_stack_long(vm, var_info.stack_index);
                    if (catch lhs) {
                        utils::crash("Math instruction: Stack out of bound.");
                        return;
                    }
    
                    ulong! rhs = vm::read_code_long(vm);
                    if (catch rhs) {
                        utils::crash("Math instruction: Missing/uncomplete operand.");
                        return;
                    }
                    
                    long result;

                    switch ((MathOperation) operation) {
                        case MathOperation.ADD:
                            result = lhs + rhs;
                        case MathOperation.SUB:
                            result = lhs - rhs;
                        case MathOperation.MUL:
                            result = lhs * rhs;
                        case MathOperation.DIV:
                            result = lhs / rhs;
                        default:
                            utils::crash("Math instruction: Unknown operation provided.");
                    }

                    switch ((MathStore) mode) {
                        case MathStore.INC:
                            if (catch vm::write_stack_long(vm, var_info.stack_index, result)) {
                                utils::crash("Math instruction: Stack out of bound.");
                                return;
                            }
                        default:
                            utils::crash(string::new_format("Math instruction: Invalid storing mode '%d'", mode));
                    } 
                    
                default:
                    utils::crash(string::new_format("Math instruction: '%s' is unsupported.", 
                                                    var_name));
            }

        default:
            utils::crash(string::new_format("Math instruction: Unknown mode '%s'", 
                                            (MathMode) mode));
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
            case Code.MATH:
                math(vm);
            default:
                utils::crash(string::new_format("Unknown opcode: %s", (Code) opcode));
        }
    }
}
