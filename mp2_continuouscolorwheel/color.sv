`include "fade.sv"
`include "pwm.sv"

module color_cycle #(
    parameter PWM_INTERVAL = 1200,  // 1ms
    parameter INITIAL_STATE = 0,
    parameter INITIAL_STEP_COUNT = 0,
    parameter INITIAL_DUTY_CYCLE = 0
) (
    input  logic clk,
    output logic CLR
);

  logic [$clog2(PWM_INTERVAL)-1:0] duty_cycle;
  logic pwm_out;

    fade #(
        .PWM_INTERVAL(PWM_INTERVAL),
        .INITIAL_STATE(INITIAL_STATE),
        .INITIAL_STEP_COUNT(INITIAL_STEP_COUNT),
        .INITIAL_DUTY_CYCLE(INITIAL_DUTY_CYCLE)
    ) u1 (
        .clk(clk),
        .cycle_value(duty_cycle)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u2 (
        .clk(clk),
        .pwm_value(duty_cycle),
        .pwm_out(pwm_out)
    );

    assign CLR = ~pwm_out;

endmodule
