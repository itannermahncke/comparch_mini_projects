// Finite state machine
`include "memory.sv"

module fsm #(
    parameter MEM_SIZE  = 128,
    parameter SINE_PATH = ""
) (
    input logic clk,
    output logic [9:0] out
);

    // states
    typedef enum logic [1:0] {
        POS_INC,
        POS_DEC,
        NEG_DEC,
        NEG_INC
    } state_t;

    state_t current_state, next_state;
    logic [6:0] addr, next_addr;
    logic [6:0] counter, next_counter;
    logic [8:0] data;
    localparam FULL_SIZE = MEM_SIZE * 4;

    // startup the fsm
    initial begin
        current_state = POS_INC;
        addr = 0;
        counter = 0;
    end

    // set up memory unit
    memory #(
        .INIT_FILE      (SINE_PATH)
    ) u1 (
        .clk            (clk), 
        .read_address   (addr), 
        .read_data      (data)
    );

    // iterate the fsm
    always_ff @(posedge clk) begin
        current_state <= next_state;
        addr <= next_addr;
        counter <= counter + 1;
    end

    // compute the next state of the FSM
    always_comb begin
        next_state = current_state;
        next_addr = addr;
        next_counter = counter + 1;

        // if the next phase is starting
        if (counter == MEM_SIZE - 1) begin
            next_counter = 0;
            case (current_state)
                // normal data
                POS_INC: begin
                    next_state = POS_DEC;
                    next_addr = MEM_SIZE - 1;
                end
                // data in reverse
                POS_DEC: begin
                    next_state = NEG_DEC;
                    next_addr = 0;
                end
                // data inverted
                NEG_DEC: begin
                    next_state = NEG_INC;
                    next_addr = MEM_SIZE - 1;
                end
                // data inverted in reverse
                NEG_INC: begin
                    next_state = POS_INC;
                    next_addr = 0;
                end
                default: begin
                    next_state = POS_INC;
                    next_addr  = 0;
                end
            endcase
        // if moving within a phase
        end else begin
            case (current_state)
                POS_INC:
                    next_addr = addr + 1;
                POS_DEC:
                    next_addr = addr - 1;
                NEG_DEC:
                    next_addr = addr + 1;
                NEG_INC:
                    next_addr = addr - 1;
                default: next_addr = 0;
            endcase
        end
    end

    // output fixed sine wave
    always_ff @(posedge clk) begin
        case (current_state)
            POS_INC:
                out <= data + FULL_SIZE;
            POS_DEC:
                out <= data + FULL_SIZE;
            NEG_DEC:
                out <= FULL_SIZE - data;
            NEG_INC:
                out <= FULL_SIZE - data;
            default: out <= 0;
        endcase
        end
endmodule
