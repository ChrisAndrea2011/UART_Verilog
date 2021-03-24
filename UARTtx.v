//UART Transmitter

module UARTTx(
  input Reset,
  input BitClk,
  input LoadTx,
  input [0:7]DataIn,
  output reg TxBusy,
  output reg SerialOut);
  
  reg [0:7]DataReg;
  reg [1:0]State;
  reg [1:0]NextState;
  reg [0:10]TxShiftReg;
  reg LoadShiftReg, Start, Stop;
  reg [3:0] BitCount;
  
  parameter Idle = 2'b00, Shift = 2'b01, Transmit = 2'b10;
  
 // assign Parity = ^DataReg;
  always @(posedge BitClk or negedge Reset)
  begin
        if ( Reset == 0)
            State = Idle;      
        else
            State = NextState;
  end 
            
  always @( posedge BitClk, LoadTx, LoadShiftReg, BitCount)
  begin 
    case (State)
    Idle :      if (LoadTx == 1)begin
                    DataReg = DataIn;
                    
                    LoadShiftReg = 1'b1;
                    NextState = Shift; 
                    Start = 1'b0; 
                    TxBusy = 1'b1;
                    Stop = 1'b1;         
                end
                else begin
                    NextState = Idle; 
                    TxShiftReg = 10'b1111111111;     
                    SerialOut =1;
                    TxBusy = 1'b0;
                    BitCount = 4'b0000;end
              
    Shift :     if (LoadShiftReg == 1) begin
                    TxShiftReg = {Start, DataReg, Stop} ;
                    NextState = Transmit; end
                else begin
                    NextState = Shift; end
                        
    Transmit :  if (BitCount < 4'b1011) begin
                    BitCount = BitCount + 4'b0001;
                    SerialOut = TxShiftReg[0];
                    TxShiftReg = {TxShiftReg[1:10], 1'b1};
                    NextState = Transmit;end
                      
                else begin
                     BitCount = 4'b0000;
                     NextState = Idle; 
                     LoadShiftReg = 1'b0; end
           default : 
           begin NextState = Idle; end   
            endcase
          end
        endmodule
        

module UART_TB();
  reg Reset;
  reg DataReady;
  reg BitClk;
  reg [0:7]DataIn;
  reg TxByte;
  wire SerialOut;

UARTTx UARTTx_inst(.Reset(Reset), .BitClk(BitClk), .LoadTx(LoadTx), .DataIn(DataIn), .TxDone(TxDone),   .SerialOut(SerialOut));

initial
begin
  BitClk = 0;
forever  #10 BitClk = ~BitClk;        
end

initial
begin
Reset = 1'b0; #20;
Reset = 1'b1; 
DataReady = 1'b1; 
DataIn= 8'b10010010;  
#200;
end
initial
begin
Reset = 1'b0; #20;
Reset = 1'b1; 
DataReady = 1'b1; 
DataIn= 8'b10010010;  
#200;
end
initial
begin
Reset = 1'b0; #20;
Reset = 1'b1; 
DataReady = 1'b1; 
DataIn= 8'b10010010;  
#200;
end
 endmodule      
                