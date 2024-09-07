const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Token = @import("lexer.zig").Token;
const TokenType = @import("lexer.zig").TokenType;
const ast = @import("ast.zig");

pub const Parser = struct {
    lexer: *Lexer,
    current_token: Token,
    peek_token: Token,
    allocator: std.mem.Allocator,

    pub fn init(lexer: *Lexer, allocator: std.mem.Allocator) Parser {
        var p = Parser{
            .lexer = lexer,
            .current_token = undefined,
            .peek_token = undefined,
            .allocator = allocator,
        };
        p.nextToken();
        p.nextToken();
        return p;
    }

    pub fn parseExpression(self: *Parser) !*ast.Node {
        return try self.parsePrecedence(.Lowest);
    }

    fn parsePrecedence(self: *Parser, precedence: ast.Precedence) !*ast.Node {
        var left = try self.parseNumberLiteral();

        while (@intFromEnum(precedence) < @intFromEnum(ast.getTokenPrecedence(self.current_token.type))) {
            const op = self.current_token.type;
            self.nextToken();
            const next_precedence = ast.getTokenPrecedence(op);
            const right = try self.parsePrecedence(next_precedence);

            const node = try self.allocator.create(ast.Node);
            node.* = .{ .BinaryExpression = .{
                .left = left,
                .operator = op,
                .right = right,
            } };
            left = node;
        }

        return left;
    }

    fn parseNumberLiteral(self: *Parser) !*ast.Node {
        const node = try self.allocator.create(ast.Node);
        const value = try std.fmt.parseInt(i64, self.current_token.literal, 10);
        node.* = .{ .NumberLiteral = .{ .value = value } };
        self.nextToken();
        return node;
    }

    fn nextToken(self: *Parser) void {
        self.current_token = self.peek_token;
        self.peek_token = self.lexer.nextToken();
    }
};
