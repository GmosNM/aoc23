const std = @import("std");

pub fn read_file(filename: []const u8) ![]const u8 {
    var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const result = try std.fs.cwd().readFile(filename, &buffer);
    return result;
}

pub fn main() !void {
    const input = try read_file("input.txt");
    var index: usize = 0;
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();
    var digits = std.ArrayList(u8).init(alloc.allocator());
    try digits.append('-');
    while (index < input.len) : (index += 1) {
        if (input[index] == '\n') {
            try digits.append('-');
        }
        if (std.ascii.isDigit(input[index])) {
            try digits.append(input[index]);
        }
    }

    var digits2 = std.ArrayList(usize).init(alloc.allocator());
    var i: usize = 0;

    var two_nums: [2]u8 = undefined;
    var two_nums_index: usize = 0;
    while (i < digits.items.len) : (i += 1) {
        const hasMinusBefore = i > 0 and digits.items[i - 1] == '-';
        const hasMinusAfter = i + 1 < digits.items.len and digits.items[i + 1] == '-';

        if (std.ascii.isDigit(digits.items[i]) and (hasMinusBefore or hasMinusAfter)) {
            two_nums[two_nums_index] = digits.items[i];
            two_nums_index += 1;

            if (hasMinusBefore and hasMinusAfter) {
                two_nums[two_nums_index] = digits.items[i];
                two_nums_index += 1;
            }

            if (two_nums_index == 2) {
                const combined_num = (two_nums[0] - '0') * 10 + (two_nums[1] - '0');
                try digits2.append(combined_num);
                two_nums_index = 0;
            }
        }
    }

    var sum: usize = 0;
    for (digits2.items) |num| {
        std.debug.print("{d}\n", .{num});
        sum += num;
    }

    std.debug.print("Sum: {d}\n", .{sum});
}
