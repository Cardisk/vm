import vm;
import utils;
import std::io;
import std::core::string;

// 8b OPCODE - 4b UNUSED - 4b MODE (Mem, Reg, Imm)
enum Code : uint {
    MOV,
    CMP,
    JMP,
    ADD,
    SUB,
    MUL,
    DIV,
    PUSH,
    POP,
    LOAD,
    STORE,
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

fn void main(String[] args) {
    vm::Vm vm = vm::init("resources/bytecode");

    while (vm.ip < vm.code.len) {
        int opcode = vm.code[vm.ip];

        switch ((Code) opcode) {
            case Code.MOV:
                utils::todo("MOV");
            case Code.CMP:
                utils::todo("CMP");
            case Code.JMP:
                utils::todo("JMP");
            case Code.ADD:
                utils::todo("ADD");
            case Code.SUB:
                utils::todo("SUB");
            case Code.MUL:
                utils::todo("MUL");
            case Code.DIV:
                utils::todo("DIV");
            case Code.PUSH:
                utils::todo("PUSH");
            case Code.POP:
                utils::todo("POP");
            case Code.LOAD:
                utils::todo("LOAD");
            case Code.STORE:
                utils::todo("STORE");
            default:
                utils::crash(string::new_format("Unknown opcode: %d", opcode));
        }

        vm.ip++;
    }

    io::printn("EXECUTION COMPLETED.");
}
