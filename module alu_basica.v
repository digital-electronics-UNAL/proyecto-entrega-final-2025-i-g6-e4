module alu_basica (
    input wire [19:0] op_a,
    input wire [19:0] op_b,
    input wire [4:0] operador,   // 10: +, 11: -, 12: *, 13: /
    output reg [31:0] resultado
);

    always @(*) begin
        case (operador)
            5'd10: resultado = op_a + op_b;   // +
            5'd11: resultado = op_a - op_b;   // -
            5'd12: resultado = op_a * op_b;   // *
            5'd13: resultado = (op_b != 0) ? (op_a / op_b) : 32'd0; // /
            default: resultado = 32'd0;
        endcase
    end

endmodule
