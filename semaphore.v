module Semaphore #(
    parameter CLK_FREQ = 25_000_000
) (
    input  wire clk,
    input  wire rst_n,
    input  wire pedestrian,
    output wire green,
    output wire yellow,
    output wire red
);

    // Estados do semáforo
    localparam S_RED    = 2'b00;
    localparam S_GREEN  = 2'b01;
    localparam S_YELLOW = 2'b10;

    // Registradores para estado atual e próximo estado
    reg [1:0] state_reg, state_next;

    // Registradores para contagem de ciclos
    reg [31:0] counter_reg, counter_next;

    // Cálculo do número de ciclos para cada estado
    localparam RED_CYCLES    = 5 * CLK_FREQ;
    localparam GREEN_CYCLES  = 7 * CLK_FREQ;
    localparam YELLOW_CYCLES = CLK_FREQ / 2;

    // Atribuição das saídas com base no estado atual
    assign red    = (state_reg == S_RED);
    assign green  = (state_reg == S_GREEN);
    assign yellow = (state_reg == S_YELLOW);

    // Lógica sequencial para atualização de estado e contador
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state_reg <= S_RED;
            counter_reg <= RED_CYCLES - 1;
        end else begin
            state_reg <= state_next;
            counter_reg <= counter_next;
        end
    end

    // Lógica combinacional para transição de estados e contagem
    always @* begin
        state_next = state_reg;
        counter_next = counter_reg;

        case (state_reg)
            S_RED: begin
                if (counter_reg == 0) begin
                    state_next = S_GREEN;
                    counter_next = GREEN_CYCLES - 1;
                end else begin
                    counter_next = counter_reg - 1;
                end
            end

            S_GREEN: begin
                if (pedestrian) begin
                    state_next = S_YELLOW;
                    counter_next = YELLOW_CYCLES - 1;
                end else if (counter_reg == 0) begin
                    state_next = S_YELLOW;
                    counter_next = YELLOW_CYCLES - 1;
                end else begin
                    counter_next = counter_reg - 1;
                end
            end

            S_YELLOW: begin
                if (counter_reg == 0) begin
                    state_next = S_RED;
                    counter_next = RED_CYCLES - 1;
                end else begin
                    counter_next = counter_reg - 1;
                end
            end

            default: begin
                state_next = S_RED;
                counter_next = RED_CYCLES - 1;
            end
        endcase
    end

endmodule