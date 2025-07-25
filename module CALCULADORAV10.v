module CALCULADORAV10 (
    input wire clk,
    input wire [3:0] filas,
    output wire [3:0] columnas,
    output wire [7:0] data,
    output wire rs,
    output wire rw,
    output wire en
);

    wire tecla_presionada;
    wire [4:0] tecla_actual;
    wire evento_tecla;
    wire reset;

    wire [7:0] data_lcd_in, data_fila_inf;
    wire rs_lcd_in, rs_fila_inf;
    wire en_lcd_in, en_fila_inf;

    decodificador_teclado_matricial deco (
        .clk(clk),
        .columnas(columnas),
        .filas(filas),
        .tecla_valida(tecla_actual)
    );

    assign tecla_presionada = |filas;

    control_evento_con_debounce debouncer (
        .clk(clk),
        .tecla_presionada(tecla_presionada),
        .evento_tecla(evento_tecla),
        .lista()
    );

    reset_por_asterisco reset_unit (
        .evento_tecla(evento_tecla),
        .tecla(tecla_actual),
        .reset(reset)
    );

    lcd_decimal_input lcd_display (
        .clk(clk),
        .reset(reset),
        .evento_tecla(evento_tecla),
        .tecla(tecla_actual),
        .data(data_lcd_in),
        .rs(rs_lcd_in),
        .rw(),
        .en(en_lcd_in)
    );

    wire [19:0] op_a;
    wire [19:0] op_b;
    wire [4:0] operador;
    wire [31:0] resultado_alu;

    repre_fila_inf resultado_fijo (
        .clk(clk),
        .reset(reset),
        .evento_tecla(evento_tecla),
        .tecla(tecla_actual),
        .numero(resultado_alu),
        .data(data_fila_inf),
        .rs(rs_fila_inf),
        .en(en_fila_inf)
    );

    reg mostrar_resultado = 0;
    reg [21:0] contador = 0;

    always @(posedge clk) begin
        if (reset) begin
            mostrar_resultado <= 0;
            contador <= 0;
        end else if (evento_tecla && tecla_actual == 5'd15) begin
            mostrar_resultado <= 1;
            contador <= 0;
        end else if (mostrar_resultado) begin
            contador <= contador + 1;
            if (contador >= 22'd2_000_000) begin
                mostrar_resultado <= 0;
                contador <= 0;
            end
        end
    end
    wire listo_operacion;

    acumulador_operandos acumulador (
        .clk(clk),
        .reset(reset),
        .evento_tecla(evento_tecla),
        .tecla(tecla_actual),
        .op_a(op_a),
        .op_b(op_b),
        .operador(operador),
        .listo(listo_operacion)
    );
    alu_basica alu_inst (
        .op_a(op_a),
        .op_b(op_b),
        .operador(operador),
        .resultado(resultado_alu)
    );
    assign data = (mostrar_resultado) ? data_fila_inf : data_lcd_in;
    assign rs   = (mostrar_resultado) ? rs_fila_inf   : rs_lcd_in;
    assign rw   = 1'b0;
    assign en   = (mostrar_resultado) ? en_fila_inf   : en_lcd_in;

endmodule
