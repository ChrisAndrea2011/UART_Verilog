module UART_top(
  input Clk,      //System Clock - Input to BaudGenerator
  input Reset,
  input [7:0]DataIn,
  input LoadTx,
  output TxBusy,
  output RxBusy,
  output FrameError,
  output ParityError,
  output [7:0]DataOut);
  
  wire SampleClk;
  wire BitClk;
  wire SerialOut;

  
  
  UARTClkGen UARTClkGen_inst (.Clk(Clk), .Reset(Reset), .SampleClk(SampleClk), .BitClk(BitClk));
  UARTTx UARTTx_inst(.Reset(Reset), .BitClk(BitClk), .LoadTx(LoadTx),  .DataIn(DataIn), .TxBusy(TxBusy), .SerialOut(SerialOut));
  UARTRx UARTRx_inst(.SerialIn(SerialOut), .Reset(Reset), .SampleClk(SampleClk),.RxBusy(RxBusy), .FrameError(FrameError), .ParityError(ParityError),  .DataOut(DataOut));
  
endmodule

module UART_top_TB();
  reg Clk;
  reg Reset;
  reg [7:0]DataIn;
  reg LoadTx;
  wire [7:0]DataOut;
  
  UART_top UART_top_inst(.Clk(Clk), .Reset(Reset), .DataIn(DataIn), .LoadTx(LoadTx),  .TxBusy(TxBusy), .RxBusy(RxBusy), .FrameError(FrameError), .ParityError(ParityError), .DataOut(DataOut));
  
  initial
  begin
    Clk =0;
    forever #5 Clk = ~Clk;
  end
  initial
  begin
    Reset = 1'b0; #50;
    LoadTx = 1'b0; #50;
    Reset = 1; DataIn = 8'b10001110;  LoadTx = 1'b1; #200;
    LoadTx = 1'b0; #200;
    
  end
  
endmodule