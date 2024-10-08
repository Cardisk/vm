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
    char! code = vm::read_code_byte(vm);
    if (catch code) {
        utils::crash("Exit instruction: Missing exit code.");
        return;
    }

    // normally called from the main.
    vm::destroy(vm);
    
    libc::exit((int) code);
}

enum PrintMode : uint {
    DATASTR,
    CODEINT,
    CODELNG,
    VAR,
}

// <opcode> <1B mode> <?B operand[s]>
fn void print(Vm *vm) {
    char! mode = vm::read_code_byte(vm);
    if (catch mode) {
        utils::crash("Print instruction: Missing print mode.");
        return;
    }

    
    switch ((PrintMode) mode) {
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

        case PrintMode.CODEINT:
            int! value = vm::read_code_int(vm);
            if (catch value) {
                utils::crash("Print instruction: Missing/uncomplete int operand.");
                return;
            }

            io::print(value);

        case PrintMode.CODELNG:
            ulong! value = vm::read_code_long(vm);
            if (catch value) {
                utils::crash("Print instruction: Missing/uncomplete long operand.");
                return;
            }

            io::print((long) value);
        
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
    
    char! type = vm.code[vm.ip++];
    if (catch type) {
        utils::crash("Var declaration: Missing type info.");
        return;
    }

    switch ((VarType) type) {
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

enum MathMode : uint {
    VAR_IMM,
}

enum MathStore : uint {
    INC,
}

// <opcode> <1B operation> <1B mode> <1B storing mode> <?B operand[s]>
fn void math(Vm *vm) {
    char! operation = vm.code[vm.ip++];
    if (catch operation) {
        utils::crash("Math instruction: Missing operation specifier.");
        return;
    }

    char! mode = vm.code[vm.ip++];
    if (catch mode) {
        utils::crash("Math instruction: Missing operation mode.");
        return;
    }

    char! store = vm.code[vm.ip++]; 
    if (catch store) {
        utils::crash("Math instruction: Missing operation mode.");
        return;
    }

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
            utils::crash(string::new_format("Math instruction: Unknown mode '%s'", (MathMode) mode));
    }
}

fn void exec(Vm *vm) {
    while (vm.ip < vm.code.len) {
        char! opcode = vm::read_code_byte(vm);
        if (catch opcode) {
            utils::crash("Execution: Instruction ptr out of bound.");
            return;
        }

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
