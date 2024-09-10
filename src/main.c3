module vm;

import utils;
import std::io;

// 4b OPCODE - 4b MODE (Mem, Reg, Imm)
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

// Instruction pointer
usz ip = 0;

fn void eat_magic(String *data) {
    if ((*data).len < 2) utils::crash("Missing magic code: Too few bytes.");  

    if (!(*data).starts_with("vm")) {
        utils::crash("Missing magic code: Invalid magic code.");
    }

    (*data) = (*data).trim("vm");
}

fn void main(String[] args) {
    String! txt = utils::read_file("resources/bytecode");
    if (catch err = txt) {
        io::printf("Unable to read the file: %s", err);
        return;
    }

    eat_magic(&txt);

    while (ip < txt.len) {
        int opcode = txt[ip] >> 0x04;
        int mode = txt[ip] | 0x0F;

        switch (opcode) {
            default:
                utils::todo("Dispatching instructions.");
        }

        ip++;
    }
}
