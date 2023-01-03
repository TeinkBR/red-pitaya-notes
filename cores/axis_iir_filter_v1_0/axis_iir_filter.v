
`timescale 1 ns / 1 ps

module axis_iir_filter
(
  // System signals
  input  wire        aclk,
  input  wire        aresetn,

  input  wire [79:0] cfg_data,

  // Slave side
  output wire        s_axis_tready,
  input  wire [15:0] s_axis_tdata,
  input  wire        s_axis_tvalid,

  // Master side
  input  wire        m_axis_tready,
  output wire [15:0] m_axis_tdata,
  output wire        m_axis_tvalid
);

  wire [47:0] int_p_wire [2:0];

  DSP48E1 #(
    .ALUMODEREG(0), .CARRYINSELREG(0), .INMODEREG(0), .OPMODEREG(0),
    .AREG(0), .ACASCREG(0), .BREG(0), .BCASCREG(0),
    .CREG(0), .CARRYINREG(0), .MREG(1), .PREG(1)
  ) dsp_0 (
    .CLK(aclk),
    .RSTM(~aresetn),
    .RSTP(~aresetn),
    .CEM(1'b1),
    .CEP(1'b1),
    .OPMODE(7'b0000101),
    .A({{(5){s_axis_tdata[15]}}, s_axis_tdata, 9'd0}),
    .B(cfg_data[15:0]),
    .P(int_p_wire[0])
  );

  DSP48E1 #(
    .ALUMODEREG(0), .CARRYINSELREG(0), .INMODEREG(0), .OPMODEREG(0),
    .AREG(0), .ACASCREG(0), .BREG(0), .BCASCREG(0),
    .CREG(0), .CARRYINREG(0), .MREG(0), .PREG(1)
  ) dsp_1 (
    .CLK(aclk),
    .RSTP(~aresetn),
    .CEP(1'b1),
    .OPMODE(7'b0110101),
    .A(int_p_wire[1][45:16]),
    .B(cfg_data[31:16]),
    .C(int_p_wire[0]),
    .P(int_p_wire[1])
  );

  DSP48E1 #(
    .ALUMODEREG(0), .CARRYINSELREG(0), .INMODEREG(0), .OPMODEREG(0),
    .AREG(0), .ACASCREG(0), .BREG(0), .BCASCREG(0),
    .CREG(0), .CARRYINREG(0), .MREG(0), .PREG(1)
  ) dsp_2 (
    .CLK(aclk),
    .RSTP(~aresetn),
    .CEP(1'b1),
    .OPMODE(7'b0110101),
    .A(int_p_wire[2][45:16]),
    .B(cfg_data[47:32]),
    .C(int_p_wire[1]),
    .P(int_p_wire[2])
  );

  assign s_axis_tready = m_axis_tready;
  assign m_axis_tdata = $signed(int_p_wire[2][47:25]) < $signed(cfg_data[63:48]) ? cfg_data[63:48] : $signed(int_p_wire[2][47:25]) > $signed(cfg_data[79:64]) ? cfg_data[79:64] : int_p_wire[2][40:25];
  assign m_axis_tvalid = s_axis_tvalid;

endmodule
