const std = @import("std");
const pmx = @import("./pmx.zig");
const t = @import("./types.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // NOTE: not working, just hardcode the path for now

    // const path = std.mem.span(std.os.argv[0]);
    // std.debug.print("path: {s}\n", .{path});

    const path = "./test/test.pmx";
    _ = try pmx.loadModel(path, allocator);
}
