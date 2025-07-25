module decodificador_teclado_matricial (
    input  wire clk,
    output reg  [3:0] columnas,       // columnas (activas en bajo)
    input  wire [3:0] filas,          // filas (activas en alto)
    output reg  [4:0] tecla_valida    // código de tecla
);

    reg [23:0] contador = 0;
    reg [1:0] estado = 0;

    // Oscilador de columnas
    always @(posedge clk) begin
        contador <= contador + 1;
        if (contador == 24'd4_000_000) begin
            contador <= 0;
            estado <= estado + 1;
        end
    end

    // Activación de columnas (una por una)
    always @(*) begin
        case (estado)
            2'd0: columnas = 4'b0001;
            2'd1: columnas = 4'b0010;
            2'd2: columnas = 4'b0100;
            2'd3: columnas = 4'b1000;
            default: columnas = 4'b0000;
        endcase
    end

    // Decodificación con tu sintaxis exacta
    always @(*) begin
        tecla_valida = 5'd16; // ninguna tecla (default)

        if ((columnas == 4'b0001) && (filas[0])) tecla_valida = 5'd1;
        else if ((columnas == 4'b0010) && (filas[0])) tecla_valida = 5'd2;
        else if ((columnas == 4'b0100) && (filas[0])) tecla_valida = 5'd3;
        else if ((columnas == 4'b1000) && (filas[0])) tecla_valida = 5'd10; // +

        else if ((columnas == 4'b0001) && (filas[1])) tecla_valida = 5'd4;
        else if ((columnas == 4'b0010) && (filas[1])) tecla_valida = 5'd5;
        else if ((columnas == 4'b0100) && (filas[1])) tecla_valida = 5'd6;
        else if ((columnas == 4'b1000) && (filas[1])) tecla_valida = 5'd11; // -

        else if ((columnas == 4'b0001) && (filas[2])) tecla_valida = 5'd7;
        else if ((columnas == 4'b0010) && (filas[2])) tecla_valida = 5'd8;
        else if ((columnas == 4'b0100) && (filas[2])) tecla_valida = 5'd9;
        else if ((columnas == 4'b1000) && (filas[2])) tecla_valida = 5'd12; // *

        else if ((columnas == 4'b0001) && (filas[3])) tecla_valida = 5'd14; // '*'
        else if ((columnas == 4'b0010) && (filas[3])) tecla_valida = 5'd0;
        else if ((columnas == 4'b0100) && (filas[3])) tecla_valida = 5'd15; // '#'
        else if ((columnas == 4'b1000) && (filas[3])) tecla_valida = 5'd13; // /
    end

endmodule