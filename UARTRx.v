//UART Receiver

module UARTRx(
  input SerialIn,
  input Reset,
  input SampleClk,
  output reg RxBusy,
  output reg FrameError,
  output reg ParityError,
  output reg [0:7]DataOut);
  
  reg [3:0]count;
  reg [3:0]Width;
  reg [1:0]NextStateRx;
  reg [0:10]RxShiftReg;
  reg [0:7]RxDataReg;
  reg [1:0]StateRx;
  reg DataReceived;
  
  parameter Idle = 2'b00, StartBit = 2'b01, DataBits = 2'b10, StopBit = 2'b11;
  
  always @(posedge SampleClk or negedge Reset)
    begin
        if ( Reset == 0) begin
            StateRx = Idle; 
            DataOut = 8'b11111111; 
            RxDataReg = 8'b11111111;  end               
        else 
            StateRx = NextStateRx;
  end
  
  
  always @(posedge SampleClk,StateRx, SerialIn, count, Width)
  begin
  case (StateRx) 
            Idle:     begin
                          count = 4'b0000;
                          Width = 4'b0000; 
                          RxShiftReg = 11'b11111111111;
                          FrameError = 1'b0;
                          
  //Falling edge in data input is detected as startbit and it moves to the 
  // next state.   
                      if (SerialIn == 0) begin
                          NextStateRx = StartBit; 
                          RxBusy = 1'b1;
                           end
                      else begin                      
                          DataReceived = 0;
                          NextStateRx = Idle;
                          FrameError = 1'b0; end
                        end
     
            StartBit: if (count < 4'b1001) begin
                        count = count + 4'b0001; 
                        NextStateRx = StartBit; end
          
                      else  if ( count == 4'b1001) begin
                          if( SerialIn== 1'b0) begin
                              RxShiftReg[9] = { RxShiftReg [1:10], SerialIn};
                              if (^RxShiftReg[1:8] != RxShiftReg[9]) begin
                                ParityError = 1'b1; end
                              else begin
                                ParityError = 1'b0;
                              end
                              NextStateRx = DataBits;
                              count = 4'b0000; end
                      else begin
                              NextStateRx = Idle; end
                      end
     
            DataBits : if (Width < 4'b1010) begin
                          if(count < 4'b1111)begin
                              count = count + 4'b0001; 
                              NextStateRx = DataBits; end
                        else if (count == 4'b1111)begin
                 	          RxShiftReg = { RxShiftReg [1:10], SerialIn};
                              
                            count = 4'b0000;  
                            NextStateRx = DataBits; 
                            Width = Width +4'b0001; end
                        end
                      else if (Width == 4'b1010)begin
                            NextStateRx = StopBit;
                            Width = 4'b0000;
                             end
            StopBit : 
                      if (count < 4'b1111) begin
                            NextStateRx = StopBit;
                            RxDataReg = RxShiftReg[1:8];
                            count = count +4'b0001;end
                      else begin
                            if (SerialIn == 1'b1) begin
                              NextStateRx = Idle;
                              RxBusy = 1'b0;
                              RxShiftReg = { RxShiftReg [1:9], SerialIn}; end
                            else begin
                              FrameError = 1'b1;
                              NextStateRx = Idle; end 
                      end
          endcase
          DataOut = RxDataReg;
 end
 
 endmodule
 
       
 module  UARTRx_TB();  
 reg SerialIn;
 reg Reset;
 reg SampleClk;
 wire [7:0]DataOut;
 
 UARTRx UARTRx_inst(.SerialIn(SerialIn), .Reset(Reset), .SampleClk(SampleClk), .RxBusy(RxBusy), .FrameError(FrameError), .ParityError(ParityError), .DataOut(DataOut));
 
 initial
 begin
 SampleClk = 0;
 forever #10 SampleClk = ~SampleClk;
 end
 
 initial
 begin
 Reset = 1'b0; #50;
 Reset = 1'b1; SerialIn =  1; #320;
 Reset = 1'b1; SerialIn =  0; #320;
 Reset = 1'b1; SerialIn =  0; #320;
 Reset = 1'b1; SerialIn =  1; #320;
 Reset = 1'b1; SerialIn =  1; #320;
 Reset = 1'b1; SerialIn =  0; #320;
 Reset = 1'b1; SerialIn =  0; #320;
 Reset = 1'b1; SerialIn =  1; #320;
 Reset = 1'b1; SerialIn =  0; #320;
 Reset = 1'b1; SerialIn =  1; #320;
 Reset = 1'b1; SerialIn =  1; #320;
 Reset = 1'b1; SerialIn =  1; #320;
 end
 endmodule