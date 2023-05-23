const std = @import("std");
const t = @import("./types.zig");

const PMX_SIGNATURE = 0x50_4D_58_20;

const ModelLoadError = error{
    InvalidSignature,
};

pub fn loadModel(absolute_path: []const u8, allocator: std.mem.Allocator) !t.Model {
    const file = try std.fs.openFileAbsolute(absolute_path, .{});
    defer file.close();
    const reader = file.reader();

    // TODO: handle "locked" files, where the last byte might not be 0x20
    const sig = try reader.readInt(u32, .Big);
    if (sig != PMX_SIGNATURE) return ModelLoadError.InvalidSignature;

    const ver = try readFloat(reader);
    _ = ver;

    const globals_count = try reader.readByte();
    const globals = try allocator.alloc(u8, globals_count);
    defer allocator.free(globals);
    var bytes_read = try reader.read(globals);
    if (bytes_read < globals_count) return error.EarlyEof;

    const name_en = try readText(reader, allocator);
    const name_jp = try readText(reader, allocator);
    const comment_en = try readText(reader, allocator);
    const comment_jp = try readText(reader, allocator);
    defer allocator.free(name_en);
    defer allocator.free(name_jp);
    defer allocator.free(comment_en);
    defer allocator.free(comment_jp);

    std.debug.print("name_en: {s}\n", .{name_en});

    const vertex_count = @intCast(usize, try reader.readInt(i32, .Little));
    std.debug.print("vertex_count: {d}\n", .{vertex_count});
    var vert: u32 = 0;
    while (vert < vertex_count) : (vert += 1) {
        const position = try readVector3(reader);
        const normal = try readVector3(reader);
        const uv = try readVector2(reader);
        std.debug.print("position: {any}\n", .{position});
        std.debug.print("normal: {any}\n", .{normal});
        std.debug.print("uv: {any}\n", .{uv});

        std.debug.print("extra vec4 count: {d}\n", .{globals[1]});
        for (globals[1]) |_| {
            try reader.skipBytes(16, .{});
        }

        const deform_type = try reader.readByte();
        try reader.skipBytes(deform_type, .{});
        // std.debug.print("deform_type: {d}\nfile idx: {d}\n", .{ deform_type, try file.getPos() });
        // switch (deform_type) {
        //     0 => {
        //         const ind = try readIndex(reader, globals[2], true);
        //         std.debug.print("ind: {d}\n", .{ind});
        //     },
        //     1 => {
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readFloat(reader);
        //     },
        //     2 => {
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readFloat(reader);
        //         _ = try readFloat(reader);
        //         _ = try readFloat(reader);
        //         _ = try readFloat(reader);
        //     },
        //     3 => {
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readFloat(reader);
        //         _ = try readVector3(reader);
        //         _ = try readVector3(reader);
        //         _ = try readVector3(reader);
        //     },
        //     4 => {
        //         if (ver != 2.1) return error.InvalidFeatureSetForVersion;
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readIndex(reader, globals[2], true);
        //         _ = try readFloat(reader);
        //         _ = try readFloat(reader);
        //         _ = try readFloat(reader);
        //         _ = try readFloat(reader);
        //     },
        //     else => return error.InvalidDeformType,
        // }
        // std.debug.print("after deform file idx: {d}\n", .{try file.getPos()});

        const edge_scale = try readFloat(reader);
        std.debug.print("edge_scale: {any}\n", .{edge_scale});
    }

    return t.Model{
        .name = "",
        .mesh = t.Mesh{},
    };
}

fn readText(reader: anytype, allocator: std.mem.Allocator) ![]const u8 {
    const len = @intCast(usize, try reader.readInt(i32, .Little));
    const text = try allocator.alloc(u8, len);
    const bytes_read = try reader.read(text);
    if (bytes_read < len) return error.EarlyEof;
    return text;
}

fn readVector2(reader: anytype) !t.Vector2 {
    return t.Vector2{
        .x = try readFloat(reader),
        .y = try readFloat(reader),
    };
}

fn readVector3(reader: anytype) !t.Vector3 {
    return t.Vector3{
        .x = try readFloat(reader),
        .y = try readFloat(reader),
        .z = try readFloat(reader),
    };
}

fn readFloat(reader: anytype) !f32 {
    const buf = try reader.readBytesNoEof(4);
    return @bitCast(f32, buf);
}

fn readIndex(reader: anytype, size: u8, is_vertex: bool) !usize {
    std.debug.print("index size: {d}\n", .{size});
    if (is_vertex) {
        const index = switch (size) {
            1 => try reader.readInt(u8, .Little),
            2 => try reader.readInt(u16, .Little),
            4 => try reader.readInt(i32, .Little),
            else => return error.InvalidIndexSize,
        };
        return @intCast(usize, index);
    } else {
        const index = switch (size) {
            1 => try reader.readInt(i8, .Little),
            2 => try reader.readInt(i16, .Little),
            4 => try reader.readInt(i32, .Little),
            else => return error.InvalidIndexSize,
        };
        return @intCast(usize, index);
    }
}
