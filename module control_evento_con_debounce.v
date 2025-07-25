module control_evento_con_debounce (
    input wire clk,
    input wire tecla_presionada,
    output reg evento_tecla,
    output wire [0:0] lista // dummy para compatibilidad
);
    reg tecla_ant = 0;
    reg [23:0] debounce_counter = 0;
    reg debounce_ready = 1;

    assign lista = 1'b0;

    always @(posedge clk) begin
        tecla_ant <= tecla_presionada;
        if (tecla_presionada && !tecla_ant && debounce_ready) begin
            evento_tecla <= 1;
            debounce_ready <= 0;
            debounce_counter <= 0;
        end else begin
            evento_tecla <= 0;
        end

        if (!debounce_ready) begin
            debounce_counter <= debounce_counter + 1;
            if (debounce_counter >= 24'd6_000_000)
                debounce_ready <= 1;
        end
    end
endmodule