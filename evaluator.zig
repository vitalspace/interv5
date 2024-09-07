const ast = @import("ast.zig");

pub fn evaluate(node: *ast.Node) i64 {
    switch (node.*) {
        .NumberLiteral => |n| return n.value,
        .BinaryExpression => |b| {
            const left = evaluate(b.left);
            const right = evaluate(b.right);
            return switch (b.operator) {
                .Plus => left + right,
                .Minus => left - right,
                .Multiply => left * right,
                .Divide => @divTrunc(left, right),
                else => unreachable,
            };
        },
    }
}
