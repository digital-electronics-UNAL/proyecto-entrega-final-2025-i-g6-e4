module acumulador_operandos (
    input wire clk,
    input wire reset,
    input wire evento_tecla,
    input wire [4:0] tecla,
    output reg [19:0] op_a,
    output reg [19:0] op_b,
    output reg [4:0] operador,
    output reg listo
);

    reg operador_detectado = 0;

    always @(posedge clk) begin
        if (reset) begin
            op_a <= 0;
            op_b <= 0;
            operador <= 5'd31;  // valor inválido
            operador_detectado <= 0;
            listo <= 0;
        end else if (evento_tecla) begin
            if (tecla <= 5'd9) begin
                if (!operador_detectado)
                    op_a <= (op_a * 10) + tecla;
                else
                    op_b <= (op_b * 10) + tecla;
            end else if (tecla >= 5'd10 && tecla <= 5'd13) begin
                if (!operador_detectado) begin
                    operador <= tecla;
                    operador_detectado <= 1;
                end
            end else if (tecla == 5'd15) begin  // '#' presionado
                listo <= 1;
            end
        end else begin
            listo <= 0;
        end
    end

endmodule
