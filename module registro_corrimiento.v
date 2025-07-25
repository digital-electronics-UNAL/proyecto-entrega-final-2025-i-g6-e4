module registro_corrimiento (
    input wire clk,
    input wire evento_tecla,
    input wire reset,
    input wire [4:0] tecla,  // ahora de 5 bits
    output reg [19:0] registro_flat
);
    reg [4:0] r0 = 5'd16;
    reg [4:0] r1 = 5'd16;
    reg [4:0] r2 = 5'd16;
    reg [4:0] r3 = 5'd16;

    always @(posedge clk) begin
        if (reset) begin
            r0 <= 5'd16;
            r1 <= 5'd16;
            r2 <= 5'd16;
            r3 <= 5'd16;
        end else if (evento_tecla && tecla < 5'd16) begin
            r3 <= r2;
            r2 <= r1;
            r1 <= r0;
            r0 <= tecla;
        end
    end

    always @(*) begin
        registro_flat = {r3, r2, r1, r0}; // total: 4*5 = 20 bits
    end
endmodule
