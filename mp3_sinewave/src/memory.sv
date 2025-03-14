// Sample memory module

module memory #(
    parameter INIT_FILE = ""
) (
    input logic clk,
    input logic [6:0] read_address,
    output logic [8:0] read_data
);
  logic [8:0] sample_memory[128];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, sample_memory);
    end
  end

  assign data = sample_memory[read_address];

endmodule
