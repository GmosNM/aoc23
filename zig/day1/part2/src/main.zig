const std = @import("std");

fn number_to_strings(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    var map = std.StringHashMap([]const u8).init(allocator);
    defer map.deinit();
    var replaced: []u8 = try allocator.alloc(u8, source.len);
    std.mem.copyForwards(u8, replaced, source);
    try map.put("one", "1");
    try map.put("two", "2");
    try map.put("three", "3");
    try map.put("four", "4");
    try map.put("five", "5");
    try map.put("six", "6");
    try map.put("seven", "7");
    try map.put("eight", "8");
    try map.put("nine", "9");
    try map.put("zero", "0");

    for (0..replaced.len) |i| {
        var it = map.iterator();
        var isAlphabetic = std.ascii.isAlphabetic(replaced[i]);
        while (it.next()) |item| {
            const key = item.key_ptr.*;
            const value = item.value_ptr.*;
            if (replaced[i..].len >= key.len) {
                if (std.mem.eql(u8, replaced[i .. i + key.len], key)) {
                    std.mem.copyForwards(u8, replaced[i..], value);
                    isAlphabetic = false;
                }
            }
        }
        if (isAlphabetic) {
            replaced[i] = ':';
        }
    }
    return replaced;
}

pub fn read_file(filename: []const u8) ![]const u8 {
    var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const result = try std.fs.cwd().readFile(filename, &buffer);
    return result;
}

pub fn main() !void {
    const input = try read_file("input.txt");
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();
    const replaced = try number_to_strings(alloc.allocator(), input);

    var index: usize = 0;
    var digits1 = std.ArrayList(u8).init(alloc.allocator());
    try digits1.append('-');

    while (index < replaced.len) : (index += 1) {
        if (input[index] == '\n') {
            try digits1.append('-');
        }
        if (std.ascii.isDigit(replaced[index]) and replaced[index] != ':' and replaced[index] != ' ' and input[index] != ' ' and input[index] != ':') {
            try digits1.append(replaced[index]);
        }
    }

    var digits2 = std.ArrayList(usize).init(alloc.allocator());
    var i: usize = 0;

    var two_nums: [2]u8 = undefined;
    var two_nums_index: usize = 0;
    while (i < digits1.items.len) : (i += 1) {
        const hasMinusBefore = i > 0 and digits1.items[i - 1] == '-';
        const hasMinusAfter = i + 1 < digits1.items.len and digits1.items[i + 1] == '-';

        if (std.ascii.isDigit(digits1.items[i]) and (hasMinusBefore or hasMinusAfter)) {
            two_nums[two_nums_index] = digits1.items[i];
            two_nums_index += 1;

            if (hasMinusBefore and hasMinusAfter) {
                two_nums[two_nums_index] = digits1.items[i];
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
        sum += num;
    }
    std.debug.print("Sum: {d}\n", .{sum});
}
