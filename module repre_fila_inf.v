module repre_fila_inf (
    input wire clk,
    input wire reset,
    input wire evento_tecla,
    input wire [4:0] tecla,
    input wire [31:0] numero,  // nuevo: número a mostrar
    output reg [7:0] data,
    output reg rs,
    output reg en
);

    assign rw = 1'b0;

    reg [3:0] i = 0;
    reg [3:0] digitos [0:9];    // hasta 10 dígitos decimales
    reg [3:0] start_idx = 0;    // primer índice no cero
    reg [31:0] count = 0;
    reg [2:0] state = 0;
    reg mostrando = 0;

    // Conversión binario -> dígitos decimales
    task convertir_a_digitos;
        integer j;
        reg [31:0] n;
        begin
            n = numero;
            for (j = 9; j >= 0; j = j - 1) begin
                digitos[j] = n % 10;
                n = n / 10;
            end

            // Buscar primer dígito no cero
            start_idx = 0;
            while (start_idx < 9 && digitos[start_idx] == 0)
                start_idx = start_idx + 1;

            // Si todo era cero
            if (numero == 0)
                start_idx = 9;
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            i <= 0;
            count <= 0;
            mostrando <= 0;
        end else if (evento_tecla && tecla == 5'd15) begin  // '#'
            convertir_a_digitos();
            mostrando <= 1;
            state <= 0;
            i <= start_idx;
        end else if (mostrando) begin
            case (state)
                0: if (count == 50000) begin
                    rs <= 0;
                    en <= 1;
                    data <= 8'h80 | 8'd64; // Dirección segunda fila
                    state <= 1;
                    count <= 0;
                end else count <= count + 1;

                1: if (count == 20) begin
                    en <= 0;
                    state <= 2;
                    count <= 0;
                end else count <= count + 1;

                2: if (count == 50000) begin
                    rs <= 1;
                    en <= 1;
                    data <= digitos[i] + 8'd48;
                    state <= 3;
                    count <= 0;
                end else count <= count + 1;

                3: if (count == 20) begin
                    en <= 0;
                    if (i < 9) begin
                        i <= i + 1;
                        state <= 2;
                    end else begin
                        mostrando <= 0;
                        state <= 0;
                    end
                    count <= 0;
                end else count <= count + 1;

                default: begin
                    state <= 0;
                    mostrando <= 0;
                end
            endcase
        end
    end
endmodule
