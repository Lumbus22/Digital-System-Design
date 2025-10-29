// Debug Interface Module
// Provides external access to CPU internals for debugging and programming
// Communicates with ESP32 via UART to enable web-based IDE

module debug_interface #(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire reset,
    
    // UART Interface
    input wire uart_rx,
    output wire uart_tx,
    
    // CPU Control Signals
    output reg cpu_enable,           // Enable/disable CPU execution
    output reg cpu_reset,            // Reset CPU
    output reg cpu_step,             // Single-step pulse
    input wire cpu_halted,           // CPU halted status
    
    // Program Counter Read
    input wire [31:0] pc_in,
    input wire [31:0] current_instr,
    
    // Register File Read Access (all 32 registers)
    output reg [4:0] debug_reg_addr,
    input wire [31:0] debug_reg_data,
    
    // Instruction Memory Access
    output reg imem_write_enable,
    output reg [5:0] imem_addr,      // 64 instructions (0-63)
    output reg [31:0] imem_data_in,
    input wire [31:0] imem_data_out,
    
    // Data Memory Read Access
    output reg [5:0] dmem_addr,
    input wire [31:0] dmem_data_out,
    
    // Status Output
    output reg [7:0] debug_status
);

    // Command Protocol Definitions
    localparam CMD_NOP              = 8'h00;
    localparam CMD_CPU_START        = 8'h01;
    localparam CMD_CPU_STOP         = 8'h02;
    localparam CMD_CPU_RESET        = 8'h03;
    localparam CMD_CPU_STEP         = 8'h04;
    localparam CMD_READ_PC          = 8'h10;
    localparam CMD_READ_INSTR       = 8'h11;
    localparam CMD_READ_REG         = 8'h20;
    localparam CMD_READ_IMEM        = 8'h30;
    localparam CMD_WRITE_IMEM       = 8'h31;
    localparam CMD_READ_DMEM        = 8'h40;
    localparam CMD_GET_STATUS       = 8'h50;
    
    // Response codes
    localparam RESP_OK              = 8'hAA;
    localparam RESP_ERROR           = 8'hEE;
    
    // UART signals
    wire [7:0] uart_rx_data;
    wire uart_rx_valid;
    wire uart_tx_busy;
    reg [7:0] uart_tx_data;
    reg uart_tx_send;
    
    // UART modules
    uart_rx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .data_out(uart_rx_data),
        .data_valid(uart_rx_valid),
        .frame_error()
    );
    
    uart_tx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk(clk),
        .reset(reset),
        .data_in(uart_tx_data),
        .transmit(uart_tx_send),
        .tx(uart_tx),
        .busy(uart_tx_busy)
    );
    
    // Command processing state machine
    localparam STATE_IDLE           = 4'h0;
    localparam STATE_READ_ADDR      = 4'h1;
    localparam STATE_READ_DATA_0    = 4'h2;
    localparam STATE_READ_DATA_1    = 4'h3;
    localparam STATE_READ_DATA_2    = 4'h4;
    localparam STATE_READ_DATA_3    = 4'h5;
    localparam STATE_PROCESS        = 4'h6;
    localparam STATE_SEND_RESP      = 4'h7;
    localparam STATE_SEND_DATA_0    = 4'h8;
    localparam STATE_SEND_DATA_1    = 4'h9;
    localparam STATE_SEND_DATA_2    = 4'hA;
    localparam STATE_SEND_DATA_3    = 4'hB;
    localparam STATE_WAIT_TX        = 4'hC;
    
    reg [3:0] state;
    reg [7:0] command;
    reg [7:0] addr_byte;
    reg [31:0] data_buffer;
    reg [31:0] response_data;
    reg [1:0] tx_byte_counter;
    
    // CPU control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            command <= CMD_NOP;
            addr_byte <= 8'h00;
            data_buffer <= 32'h00000000;
            response_data <= 32'h00000000;
            tx_byte_counter <= 2'b00;
            
            cpu_enable <= 1'b0;
            cpu_reset <= 1'b1;
            cpu_step <= 1'b0;
            
            debug_reg_addr <= 5'h00;
            imem_write_enable <= 1'b0;
            imem_addr <= 6'h00;
            imem_data_in <= 32'h00000000;
            dmem_addr <= 6'h00;
            
            uart_tx_data <= 8'h00;
            uart_tx_send <= 1'b0;
            
            debug_status <= 8'h00;
        end
        else begin
            // Default: clear single-cycle pulses
            uart_tx_send <= 1'b0;
            cpu_step <= 1'b0;
            cpu_reset <= 1'b0;
            imem_write_enable <= 1'b0;
            
            case (state)
                STATE_IDLE: begin
                    if (uart_rx_valid) begin
                        command <= uart_rx_data;
                        
                        // Commands that need address
                        if (uart_rx_data == CMD_READ_REG || 
                            uart_rx_data == CMD_READ_IMEM ||
                            uart_rx_data == CMD_WRITE_IMEM ||
                            uart_rx_data == CMD_READ_DMEM) begin
                            state <= STATE_READ_ADDR;
                        end
                        // Commands that need 4 bytes of data
                        else if (uart_rx_data == CMD_WRITE_IMEM) begin
                            state <= STATE_READ_ADDR;
                        end
                        // Immediate commands
                        else begin
                            state <= STATE_PROCESS;
                        end
                    end
                end
                
                STATE_READ_ADDR: begin
                    if (uart_rx_valid) begin
                        addr_byte <= uart_rx_data;
                        
                        if (command == CMD_WRITE_IMEM) begin
                            state <= STATE_READ_DATA_0;
                        end
                        else begin
                            state <= STATE_PROCESS;
                        end
                    end
                end
                
                STATE_READ_DATA_0: begin
                    if (uart_rx_valid) begin
                        data_buffer[7:0] <= uart_rx_data;
                        state <= STATE_READ_DATA_1;
                    end
                end
                
                STATE_READ_DATA_1: begin
                    if (uart_rx_valid) begin
                        data_buffer[15:8] <= uart_rx_data;
                        state <= STATE_READ_DATA_2;
                    end
                end
                
                STATE_READ_DATA_2: begin
                    if (uart_rx_valid) begin
                        data_buffer[23:16] <= uart_rx_data;
                        state <= STATE_READ_DATA_3;
                    end
                end
                
                STATE_READ_DATA_3: begin
                    if (uart_rx_valid) begin
                        data_buffer[31:24] <= uart_rx_data;
                        state <= STATE_PROCESS;
                    end
                end
                
                STATE_PROCESS: begin
                    case (command)
                        CMD_CPU_START: begin
                            cpu_enable <= 1'b1;
                            debug_status[0] <= 1'b1;  // Running bit
                            response_data <= 32'h00000000;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_CPU_STOP: begin
                            cpu_enable <= 1'b0;
                            debug_status[0] <= 1'b0;  // Running bit
                            response_data <= 32'h00000000;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_CPU_RESET: begin
                            cpu_reset <= 1'b1;
                            cpu_enable <= 1'b0;
                            debug_status <= 8'h00;
                            response_data <= 32'h00000000;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_CPU_STEP: begin
                            cpu_step <= 1'b1;
                            response_data <= 32'h00000000;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_READ_PC: begin
                            response_data <= pc_in;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_READ_INSTR: begin
                            response_data <= current_instr;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_READ_REG: begin
                            debug_reg_addr <= addr_byte[4:0];
                            response_data <= debug_reg_data;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_READ_IMEM: begin
                            imem_addr <= addr_byte[5:0];
                            response_data <= imem_data_out;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_WRITE_IMEM: begin
                            imem_addr <= addr_byte[5:0];
                            imem_data_in <= data_buffer;
                            imem_write_enable <= 1'b1;
                            response_data <= 32'h00000000;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_READ_DMEM: begin
                            dmem_addr <= addr_byte[5:0];
                            response_data <= dmem_data_out;
                            state <= STATE_SEND_RESP;
                        end
                        
                        CMD_GET_STATUS: begin
                            response_data <= {24'h000000, debug_status};
                            state <= STATE_SEND_RESP;
                        end
                        
                        default: begin
                            response_data <= 32'hDEADBEEF;  // Error indicator
                            state <= STATE_SEND_RESP;
                        end
                    endcase
                end
                
                STATE_SEND_RESP: begin
                    if (!uart_tx_busy) begin
                        uart_tx_data <= RESP_OK;
                        uart_tx_send <= 1'b1;
                        tx_byte_counter <= 2'b00;
                        state <= STATE_WAIT_TX;
                    end
                end
                
                STATE_WAIT_TX: begin
                    if (!uart_tx_busy && !uart_tx_send) begin
                        state <= STATE_SEND_DATA_0;
                    end
                end
                
                STATE_SEND_DATA_0: begin
                    if (!uart_tx_busy) begin
                        uart_tx_data <= response_data[7:0];
                        uart_tx_send <= 1'b1;
                        state <= STATE_SEND_DATA_1;
                    end
                end
                
                STATE_SEND_DATA_1: begin
                    if (!uart_tx_busy && !uart_tx_send) begin
                        uart_tx_data <= response_data[15:8];
                        uart_tx_send <= 1'b1;
                        state <= STATE_SEND_DATA_2;
                    end
                end
                
                STATE_SEND_DATA_2: begin
                    if (!uart_tx_busy && !uart_tx_send) begin
                        uart_tx_data <= response_data[23:16];
                        uart_tx_send <= 1'b1;
                        state <= STATE_SEND_DATA_3;
                    end
                end
                
                STATE_SEND_DATA_3: begin
                    if (!uart_tx_busy && !uart_tx_send) begin
                        uart_tx_data <= response_data[31:24];
                        uart_tx_send <= 1'b1;
                        state <= STATE_IDLE;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end
    
endmodule

