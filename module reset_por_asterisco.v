module reset_por_asterisco (
    input wire evento_tecla,
    input wire [4:0] tecla,
    output wire reset
);
    assign reset = (evento_tecla && tecla == 5'd14); // '*' = 14
endmodule
