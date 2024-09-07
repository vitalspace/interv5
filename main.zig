const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;
const ast = @import("ast.zig");
const evaluate = @import("evaluator.zig").evaluate;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const gpa_status = gpa.deinit();
        if (gpa_status == .leak) {
            std.debug.print("Leak detected\n", .{});
        }
    }

    const allocator = gpa.allocator();

    const input = "3 + 4 * 2 - 1 *  10 / 2 + 5 * 8";
    var lexer = Lexer.init(input);

    var parser = Parser.init(&lexer, allocator);
    const tree = try parser.parseExpression();
    defer ast.freeAst(allocator, tree);

    const stdout = std.io.getStdOut().writer();

    // try stdout.print("AST:\n", .{});
    // try ast.printAst(tree, 0, stdout);

    const result = evaluate(tree);
    try stdout.print("Result: {}\n", .{result});
}
