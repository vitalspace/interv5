const std = @import("std");
const TokenType = @import("lexer.zig").TokenType;

pub const NodeType = enum {
    NumberLiteral,
    BinaryExpression,
};

pub const Node = union(NodeType) {
    NumberLiteral: struct {
        value: i64,
    },
    BinaryExpression: struct {
        left: *Node,
        operator: TokenType,
        right: *Node,
    },
};

pub const Precedence = enum(u8) {
    Lowest,
    Sum, // + -
    Product, // * /
    Highest, // Para asegurarnos de tener un valor máximo válido
};

pub fn getTokenPrecedence(token_type: TokenType) Precedence {
    return switch (token_type) {
        .Plus, .Minus => .Sum,
        .Multiply, .Divide => .Product,
        else => .Lowest,
    };
}

pub fn printAst(node: *Node, depth: usize, writer: anytype) !void {
    try printIndent(writer, depth);
    switch (node.*) {
        .NumberLiteral => |n| try writer.print("Number: {}\n", .{n.value}),
        .BinaryExpression => |b| {
            try writer.print("BinaryExpression:\n", .{});
            try printIndent(writer, depth + 1);
            try writer.print("Operator: {}\n", .{b.operator});
            try printIndent(writer, depth + 1);
            try writer.print("Left:\n", .{});
            try printAst(b.left, depth + 2, writer);
            try printIndent(writer, depth + 1);
            try writer.print("Right:\n", .{});
            try printAst(b.right, depth + 2, writer);
        },
    }
}

fn printIndent(writer: anytype, depth: usize) !void {
    var i: usize = 0;
    while (i < depth) : (i += 1) {
        try writer.writeAll("  ");
    }
}

pub fn freeAst(allocator: std.mem.Allocator, node: *Node) void {
    switch (node.*) {
        .NumberLiteral => {},
        .BinaryExpression => |b| {
            freeAst(allocator, b.left);
            freeAst(allocator, b.right);
        },
    }
    allocator.destroy(node);
}
