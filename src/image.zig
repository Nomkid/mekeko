const std = @import("std");

height: u32,
width: u32,
data: []u8,

const Self = @This();

pub fn writeToFile(self: *Self, path: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    var header_buf = [_]u8{0} ** 32;
    const header = try std.fmt.bufPrint(&header_buf, "P6\n{d} {d}\n255\n", .{ self.height, self.width });
    _ = try file.write(header);
    _ = try file.write(self.data);
}

test "write raw ppm data" {
    var data = [_]u8{
        0,   0, 0,   255, 0,   0,   0, 255, 0,
        0,   0, 255, 255, 255, 0,   0, 255, 255,
        255, 0, 255, 255, 255, 255, 0, 255, 0,
    };

    var img = Self{ .height = 3, .width = 3, .data = &data };
    try img.writeToFile("./test/img.ppm");
}
