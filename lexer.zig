const std = @import("std");

pub const TokenType = enum {
    Number,
    Plus,
    Minus,
    Multiply,
    Divide,
    EOF,
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};

pub const Lexer = struct {
    input: []const u8,
    position: usize,
    read_position: usize,
    ch: u8,

    pub fn init(input: []const u8) Lexer {
        var l = Lexer{
            .input = input,
            .position = 0,
            .read_position = 0,
            .ch = 0,
        };
        l.readChar();
        return l;
    }

    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();

        const tok: Token = switch (self.ch) {
            '+' => .{ .type = .Plus, .literal = "+" },
            '-' => .{ .type = .Minus, .literal = "-" },
            '*' => .{ .type = .Multiply, .literal = "*" },
            '/' => .{ .type = .Divide, .literal = "/" },
            0 => return .{ .type = .EOF, .literal = "" },
            else => if (std.ascii.isDigit(self.ch)) {
                const start = self.position;
                while (std.ascii.isDigit(self.ch)) {
                    self.readChar();
                }
                return .{ .type = .Number, .literal = self.input[start..self.position] };
            } else {
                return .{ .type = .EOF, .literal = "" };
            },
        };

        self.readChar();
        return tok;
    }

    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }
};

test "lexer" {
    const input = "3 + 4 * 2 - 1 * 10 / 2 + 5 * 8";
    var lexer = Lexer.init(input);
    const tok = lexer.nextToken();
    try std.testing.expectEqual(tok.type, .Number);
    try std.testing.expectEqual(tok.literal, "3");
}
