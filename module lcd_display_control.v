module lcd_decimal_input (
    input wire clk,
    input wire reset,
    input wire evento_tecla,
    input wire [4:0] tecla,
    output reg [7:0] data,
    output reg rs,
    output wire rw,
    output reg en
);

assign rw = 1'b0;

reg [4:0] state = 0;
reg [31:0] count = 0;
reg [7:0] buffer [0:15];
reg [4:0] pos = 0;

reg agregar = 0;
reg [7:0] ascii = 8'd32;

reg es_operador;
reg [4:0] pos_operador = 5'd31;  // 31 = valor inválido

// ================================
// Conversión de tecla a ASCII
// ================================
always @(*) begin
    agregar = 0;
    es_operador = 0;
    case (tecla)
        5'd0:  begin ascii = "0"; agregar = 1; end
        5'd1:  begin ascii = "1"; agregar = 1; end
        5'd2:  begin ascii = "2"; agregar = 1; end
        5'd3:  begin ascii = "3"; agregar = 1; end
        5'd4:  begin ascii = "4"; agregar = 1; end
        5'd5:  begin ascii = "5"; agregar = 1; end
        5'd6:  begin ascii = "6"; agregar = 1; end
        5'd7:  begin ascii = "7"; agregar = 1; end
        5'd8:  begin ascii = "8"; agregar = 1; end
        5'd9:  begin ascii = "9"; agregar = 1; end
        5'd10: begin ascii = "+"; agregar = 1; es_operador = 1; end
        5'd11: begin ascii = "-"; agregar = 1; es_operador = 1; end
        5'd12: begin ascii = "*"; agregar = 1; es_operador = 1; end
        5'd13: begin ascii = "/"; agregar = 1; es_operador = 1; end
        default: agregar = 0;
    endcase
end

// ================================
// FSM para control del LCD
// ================================
always @(posedge clk) begin
    case (state)
        // Inicialización
        0: if (count == 1_000_000) begin rs <= 0; en <= 1; data <= 8'b00111000; state <= 1; count <= 0; end else count <= count + 1;
        1: if (count == 20) begin en <= 0; state <= 2; count <= 0; end else count <= count + 1;
        2: if (count == 50000) begin rs <= 0; en <= 1; data <= 8'b00001100; state <= 3; count <= 0; end else count <= count + 1;
        3: if (count == 20) begin en <= 0; state <= 4; count <= 0; end else count <= count + 1;
        4: if (count == 50000) begin rs <= 0; en <= 1; data <= 8'b00000001; state <= 5; count <= 0; end else count <= count + 1;
        5: if (count == 20) begin en <= 0; state <= 6; count <= 0; end else count <= count + 1;
        6: if (count == 100000) begin rs <= 0; en <= 1; data <= 8'b00000110; state <= 7; count <= 0; end else count <= count + 1;
        7: if (count == 20) begin en <= 0; state <= 8; count <= 0; end else count <= count + 1;

        // Estado principal
        8: begin
            if (reset) begin
                pos <= 0;
                pos_operador <= 5'd31;
                state <= 9;
            end else if (evento_tecla && agregar) begin
                if (es_operador) begin
                    if (pos_operador == 5'd31 && pos < 16) begin
                        buffer[pos] <= ascii;
                        pos_operador <= pos;
                        pos <= pos + 1;
                        state <= 20;
                    end else if (pos_operador != 5'd31) begin
                        buffer[pos_operador] <= ascii;
                        state <= 22;
                    end
                end else if (pos < 16) begin
                    buffer[pos] <= ascii;
                    pos <= pos + 1;
                    state <= 20;
                end
            end
        end

        // Limpieza
        9: if (count == 100_000) begin rs <= 0; en <= 1; data <= 8'b00000001; state <= 10; count <= 0; end else count <= count + 1;
        10: if (count == 20) begin en <= 0; state <= 8; count <= 0; end else count <= count + 1;

        // Impresión de nuevo carácter
        20: if (count == 50000) begin rs <= 1; en <= 1; data <= buffer[pos - 1]; count <= 0; state <= 21; end else count <= count + 1;
        21: if (count == 20) begin en <= 0; state <= 8; count <= 0; end else count <= count + 1;

        // Reimpresión de operador (reemplazo)
        22: if (count == 50000) begin rs <= 0; en <= 1; data <= 8'b10000000 | pos_operador; state <= 23; count <= 0; end else count <= count + 1;
        23: if (count == 20) begin en <= 0; state <= 24; count <= 0; end else count <= count + 1;
        24: if (count == 50000) begin rs <= 1; en <= 1; data <= buffer[pos_operador]; state <= 25; count <= 0; end else count <= count + 1;
        25: if (count == 20) begin en <= 0; state <= 8; count <= 0; end else count <= count + 1;

        default: state <= 8;
    endcase
end

endmodule
