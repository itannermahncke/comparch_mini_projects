// Discrete Color Wheel

module fsm #(
    parameter BLINK_INTERVAL = 2000000,     // CLK freq is 12MHz, so 2,000,000 cycles is 1/6s
)(
    input logic     clk,
    output logic    red, 
    output logic    green, 
    output logic    blue
);

    // Define state variable values: 3 bits needed to store 6 possibilities
    localparam RED = 3'b000;
    localparam YELLOW = 3'b001;
    localparam GREEN= 3'b010;
    localparam CYAN = 3'b011;
    localparam BLUE = 3'b100;
    localparam MAGENTA = 3'b101;

    // Declare state variables
    logic [2:0] current_state = GREEN;
    logic [2:0] next_state;

    // Declare next output values
    logic next_red, next_green, next_blue;

    // declare clock counter
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;

    // Compute the next state of the FSM
    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            next_state = 3'bxxx;
            case (current_state)
                GREEN:
                    next_state = CYAN;
                CYAN:
                    next_state = BLUE;
                BLUE:
                    next_state = MAGENTA;
                MAGENTA:
                    next_state = RED;
                RED:
                    next_state = YELLOW;
                YELLOW:
                    next_state = GREEN;
            endcase
        end
        else begin
            count <= count + 1;
        end
    end

    // Register the FSM state
    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    // Compute next output values based on state
    always_comb begin
        next_red = 1'b0;
        next_green = 1'b0;
        next_blue = 1'b0;
        case (current_state)
            GREEN:
                next_green <= 1'b1;
            CYAN: begin
                next_blue <= 1'b1;
                next_green <= 1'b1;
            end
            BLUE:
                next_blue <= 1'b1;
            MAGENTA: begin
                next_blue <= 1'b1;
                next_red <= 1'b1;
            end
            RED:
                next_red <= 1'b1;
            YELLOW: begin
                next_red <= 1'b1;
                next_green <= 1'b1;
            end
        endcase
    end

    // Register the FSM outputs
    always_ff @(posedge clk) begin
        red <= next_red;
        green <= next_green;
        blue <= next_blue;
    end

endmodule

module top(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    logic red, green, blue;

    fsm u0(
        .clk(clk),
        .red    (red),
        .green  (green),
        .blue   (blue)
    );

    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;
endmodule
