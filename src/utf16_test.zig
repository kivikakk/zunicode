const std = @import("std");
const unicode = @import("zunicode.zig");
const utf16 = @import("utf16.zig");

const mem = std.mem;
const testing = std.testing;

test "constants" {
    try testing.expectEqual(utf16.max_rune, unicode.tables.max_rune);
}

const encodeTest = struct {
    in: []const i32,
    out: []const u16,
};

const encode_tests = [_]encodeTest{
    encodeTest{ .in = &[_]i32{ 1, 2, 3, 4 }, .out = &[_]u16{ 1, 2, 3, 4 } },
    encodeTest{
        .in = &[_]i32{ 0xffff, 0x10000, 0x10001, 0x12345, 0x10ffff },
        .out = &[_]u16{ 0xffff, 0xd800, 0xdc00, 0xd800, 0xdc01, 0xd808, 0xdf45, 0xdbff, 0xdfff },
    },
    encodeTest{
        .in = &[_]i32{ 'a', 'b', 0xd7ff, 0xd800, 0xdfff, 0xe000, 0x110000, -1 },
        .out = &[_]u16{ 'a', 'b', 0xd7ff, 0xfffd, 0xfffd, 0xe000, 0xfffd, 0xfffd },
    },
};

test "encode" {
    const a = std.testing.allocator;
    for (encode_tests) |ts| {
        const value = try utf16.encode(a, ts.in);
        try testing.expectEqualSlices(u16, ts.out, value.items);
        value.deinit();
    }
}

test "encodeRune" {
    for (encode_tests) |tt| {
        var j: usize = 0;
        for (tt.in) |r| {
            const pair = utf16.encodeRune(r);
            if (r < 0x10000 or r > unicode.tables.max_rune) {
                try testing.expect(!(j >= tt.out.len));
                try testing.expect(!(pair.r1 != unicode.tables.replacement_char or pair.r2 != unicode.tables.replacement_char));
                j += 1;
            } else {
                try testing.expect(!(j >= tt.out.len));
                try testing.expect(!(pair.r1 != @as(i32, @intCast(tt.out[j])) or pair.r2 != @as(i32, @intCast(tt.out[j + 1]))));
                j += 2;
                const dec = utf16.decodeRune(pair.r1, pair.r2);
                try testing.expectEqual(r, dec);
            }
        }
    }
}
