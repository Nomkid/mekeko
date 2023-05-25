const std = @import("std");

height: u32,
width: u32,
data: []u8,
allocator: ?std.mem.Allocator,

const Self = @This();

pub fn create(height: u32, width: u32, allocator: std.mem.Allocator) !Self {
    var data = try allocator.alloc(u8, 3 * height * width);
    for (data, 0..) |_, i| data[i] = 0;
    return Self{
        .height = height,
        .width = width,
        .data = data,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    if (self.allocator) |ally| ally.free(self.data);
}

pub fn writeToFile(self: *Self, path: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    var header_buf = [_]u8{0} ** 32;
    const header = try std.fmt.bufPrint(&header_buf, "P6\n{d} {d}\n255\n", .{ self.height, self.width });
    _ = try file.write(header);
    _ = try file.write(self.data);
}

test "write image to file" {
    var img = try create(3, 3, std.testing.allocator);
    defer img.deinit();
    for ([_]usize{ 3, 7, 11, 12, 13, 16, 17, 18, 20, 21, 22, 23, 25 }) |i| img.data[i] = 255;
    try img.writeToFile("./test/img.ppm");
}

test "draw horizontal line" {
    const size = 24;
    var img = try create(size, size, std.testing.allocator);
    defer img.deinit();

    var x: u8 = 0;
    while (x < size * 3) : (x += 3) {
        img.data[x + 0] = 255;
        img.data[x + 1] = 255;
        img.data[x + 2] = 255;
    }

    try img.writeToFile("./test/hline.ppm");
}

test "draw vertical line" {
    const size = 24;
    var img = try create(size, size, std.testing.allocator);
    defer img.deinit();

    var x: usize = 0;
    while (x < size * size * 3) : (x += size * 3) {
        img.data[x + 0] = 255;
        img.data[x + 1] = 255;
        img.data[x + 2] = 255;
    }

    try img.writeToFile("./test/vline.ppm");
}
