`include "color_cycle.sv"

// top level module
module top #(
    parameter PWM_INTERVAL = 1200
) (
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

  logic red, green, blue;

  color_cycle #(
      .PWM_INTERVAL(PWM_INTERVAL),
      .INITIAL_STATE(2'b01),  // HOLD HIGH
      .INITIAL_STEP_COUNT(0.5),  // Start midway through cycle
      .INITIAL_DUTY_CYCLE(1)  // all 1s
  ) red_light (
      .clk(clk),
      .CLR(red)
  );

  color_cycle #(PWM_INTERVAL) green_light (
      .clk(clk),
      .CLR(green)
  );

  color_cycle #(
      .PWM_INTERVAL(PWM_INTERVAL),
      .INITIAL_STATE(2'b11)  // HOLD LOW
  ) blue_light (
      .clk(clk),
      .CLR(blue)
  );

  assign RGB_R = ~red;
  assign RGB_G = ~green;
  assign RGB_B = ~blue;
endmodule
