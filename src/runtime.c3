module runtime;

import vm;
import utils;
import std::io;
import std::core::string;

// 8b OPCODE - 4b UNUSED - 3b MODE (Mem, Reg, Imm)
enum Code : uint {
    INVALID,
    MOV,
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

// 4b REGISTER
enum Reg : uint {
    BP,         // Base stack pointer
    SP,         // Stack pointer
    IP,         // Instruction pointer
    EF,         // EFlags
    R1,         // General purpose
    R2,         // General purpose
    R3,         // General purpose
    R4,         // General purpose
    R5,         // General purpose
    R6,         // General purpose
    R7,         // General purpose
    R8,         // General purpose
    R9,         // General purpose
    R10,        // General purpose
    R11,        // General purpose
    R12,        // General purpose
}

enum Mode : uint {
    INVALID,
    RTOR,
    RTOM,
    MTOR,
    MTOM,
    ITOR,
    ITOM,
}

fn Mode decode_mode(char byte) {
    switch ((Mode) byte) {
        case Mode.RTOR:
            return Mode.RTOR;
        case Mode.RTOM:
            return Mode.RTOM;
        case Mode.MTOR:
            return Mode.MTOR;
        case Mode.MTOM:
            return Mode.MTOM;
        case Mode.ITOR:
            return Mode.ITOR;
        case Mode.ITOM:
            return Mode.ITOM;
        default:
            utils::crash("Something wrong occurred with decoding modes.",
                         "Maybe missing some cases inside the switch?");
    }

    return Mode.INVALID;
}

fn void mov(Vm *vm) {
    assert(vm.ip < vm.code.len, 
           "Instruction decoding: Missing instruction mode.");

    Mode mode = decode_mode(vm.code[vm.ip]);
    vm.ip++;

    utils::todo("mov not fully implemented.");
}

fn void exec(Vm *vm) {
    while (vm.ip < vm.code.len) {
        int opcode = vm.code[vm.ip];
        vm.ip++;

        switch ((Code) opcode) {
            case Code.MOV:
                mov(vm);
            default:
                utils::crash(string::new_format("Unknown opcode: %s", (Code) opcode));
        }
    }
}
