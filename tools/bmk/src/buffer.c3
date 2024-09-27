module buffer(<Type>);

import std::core::mem;

struct Buffer {
    Type[] data;
    usz len;
    usz ckpt;
    usz capacity;
}

fn void! Buffer.init(&buf, usz capacity = 10) {
    Type[]! data = mem::new_array(Type, capacity);
    if (catch e = data) return e?;

    buf.data = data;
    buf.len = 0;
    buf.capacity = capacity;
}

fn void Buffer.write(&buf, Type value) {
    if (buf.len >= buf.capacity - 1) {
        buf.capacity *= 2;
        Type *ptr = (Type *) mem::realloc(buf.data, buf.capacity);
        buf.data = ptr[: buf.capacity];
    }

    buf.data[buf.len++] = value;
}

fn void Buffer.transaction(&buf) {
    buf.ckpt = buf.len;
}

fn void Buffer.rollback(&buf) {
    buf.len = buf.ckpt;
}
