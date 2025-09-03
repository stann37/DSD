module I_cache #(
    parameter ENTRY = 16
)(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);

// Cache configuration parameters
localparam ENTRY_WIDTH = $clog2(ENTRY);
localparam INDEX_WIDTH = $clog2(ENTRY/2);
localparam OFFSET_WIDTH = 4;

// State encoding
localparam ST_IDLE = 1'b0;
localparam ST_FETCH = 1'b1;

//==== Interface Definitions ============================
input wire         clk;
// CPU interface signals
input wire         proc_reset;
input wire         proc_read, proc_write;
input wire  [29:0] proc_addr;
input wire  [31:0] proc_wdata;
output reg         proc_stall;
output reg  [31:0] proc_rdata;
// Memory subsystem interface
input wire [127:0] mem_rdata;
input wire         mem_ready;
output wire        mem_read, mem_write;
output wire [27:0] mem_addr;
output wire [127:0] mem_wdata;

//==== Internal Storage and Control Signals ================================
reg [127:0] cache_line_next [0:ENTRY-1], cache_line_curr [0:ENTRY-1];
reg [31-INDEX_WIDTH-OFFSET_WIDTH:0] addr_tag_curr [0:ENTRY-1], addr_tag_next [0:ENTRY-1];
reg line_valid_curr [0:ENTRY-1], line_valid_next [0:ENTRY-1];
reg access_recent_curr [0:ENTRY-1], access_recent_next [0:ENTRY-1];
reg memory_read_next, memory_read_curr;

reg [27:0] memory_address_curr;
reg current_state, next_state;
reg [127:0] memory_data_curr;
reg memory_ready_curr;
reg reset_delayed;
integer loop_index;

// Memory interface assignments
assign mem_write = 1'b0;
assign mem_wdata = 128'b0;
assign mem_read = memory_read_curr;
assign mem_addr = memory_address_curr;

//==== Cache Hit Detection Logic ==============================
wire way0_match;
assign way0_match = (line_valid_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b0}]) && 
                    (addr_tag_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] == proc_addr[29:2+INDEX_WIDTH]);

wire way1_match;
assign way1_match = (line_valid_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b1}]) && 
                    (addr_tag_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] == proc_addr[29:2+INDEX_WIDTH]);

wire [1:0] replacement_status;
assign replacement_status = {access_recent_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b1}], 
                            access_recent_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b0}]};

//==== Main Control Logic ==============================
always @(*) begin
    // Initialize all outputs and next-state variables
    proc_rdata = 32'b0;
    proc_stall = 1'b0;
    memory_read_next = memory_read_curr;
    next_state = current_state;
    
    // Initialize all array next-state values
    for (loop_index = 0; loop_index < ENTRY; loop_index = loop_index + 1) begin
        cache_line_next[loop_index] = cache_line_curr[loop_index];
        addr_tag_next[loop_index] = addr_tag_curr[loop_index];
        line_valid_next[loop_index] = line_valid_curr[loop_index];
        access_recent_next[loop_index] = access_recent_curr[loop_index];
    end

    case (current_state) //synopsys parallel_case full_case
        ST_IDLE: begin // Idle state - check for hits
            proc_stall = 1'b0;
            if (proc_read) begin
                case ({way0_match, way1_match}) //synopsys parallel_case full_case
                    2'b10: begin // Hit in way 0
                        proc_rdata = cache_line_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b0}][({proc_addr[1:0], 5'b0}) +: 32];
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b0;
                        if (replacement_status == 2'b11) begin
                            access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                            access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b1;
                        end
                    end
                    2'b01: begin // Hit in way 1
                        proc_rdata = cache_line_curr[{proc_addr[1+INDEX_WIDTH:2], 1'b1}][({proc_addr[1:0], 5'b0}) +: 32];
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b0;
                    end
                    default: begin // Cache miss - initiate memory fetch
                        memory_read_next = 1'b1;
                        next_state = ST_FETCH;
                        proc_stall = 1'b1;
                    end
                endcase
            end
        end
        
        ST_FETCH: begin // Memory fetch state
            proc_stall = 1'b1;
            if (memory_ready_curr) begin
                next_state = ST_IDLE;
                case (replacement_status) //synopsys parallel_case full_case
                    2'b00: begin // Both ways invalid - use way 0
                        cache_line_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = memory_data_curr;
                        addr_tag_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = proc_addr[29:2+INDEX_WIDTH];
                        line_valid_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                        proc_rdata = memory_data_curr[({proc_addr[1:0], 5'b0}) +: 32];
                        proc_stall = 1'b0;
                        memory_read_next = 1'b0;
                    end
                    2'b11: begin // Both ways valid - replace way 1 (LRU)
                        cache_line_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = memory_data_curr;
                        addr_tag_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = proc_addr[29:2+INDEX_WIDTH];
                        line_valid_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b0;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                        proc_rdata = memory_data_curr[({proc_addr[1:0], 5'b0}) +: 32];
                        proc_stall = 1'b0;
                        memory_read_next = 1'b0;
                    end
                    2'b01: begin // Way 0 is LRU - replace way 1
                        cache_line_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = memory_data_curr;
                        addr_tag_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = proc_addr[29:2+INDEX_WIDTH];
                        line_valid_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b0;
                        proc_rdata = memory_data_curr[({proc_addr[1:0], 5'b0}) +: 32];
                        proc_stall = 1'b0;
                        memory_read_next = 1'b0;
                    end
                    2'b10: begin // Way 1 is LRU - replace way 0
                        cache_line_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = memory_data_curr;
                        addr_tag_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = proc_addr[29:2+INDEX_WIDTH];
                        line_valid_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b0}] = 1'b1;
                        access_recent_next[{proc_addr[1+INDEX_WIDTH:2], 1'b1}] = 1'b0;
                        proc_rdata = memory_data_curr[({proc_addr[1:0], 5'b0}) +: 32];
                        proc_stall = 1'b0;
                        memory_read_next = 1'b0;
                    end
                endcase
            end
        end
    endcase
end

//==== Clock-Driven State Updates =================================
always @(posedge clk) begin
    reset_delayed <= proc_reset;
    if (reset_delayed) begin
        // Reset all cache state
        for (loop_index = 0; loop_index < ENTRY; loop_index = loop_index + 1) begin
            cache_line_curr[loop_index] <= 128'b0;
            addr_tag_curr[loop_index] <= {(32-INDEX_WIDTH-OFFSET_WIDTH){1'b0}};
            line_valid_curr[loop_index] <= 1'b0;
            access_recent_curr[loop_index] <= 1'b0;
        end
        current_state <= ST_IDLE;
        memory_read_curr <= 1'b0;
        memory_data_curr <= 128'b0;
        memory_ready_curr <= 1'b0;
        memory_address_curr <= 28'b0;
    end
    else if (mem_ready) begin
        // Memory operation completed
        memory_read_curr <= 1'b0;
        for (loop_index = 0; loop_index < ENTRY; loop_index = loop_index + 1) begin
            cache_line_curr[loop_index] <= cache_line_next[loop_index];
            addr_tag_curr[loop_index] <= addr_tag_next[loop_index];
            line_valid_curr[loop_index] <= line_valid_next[loop_index];
            access_recent_curr[loop_index] <= access_recent_next[loop_index];
        end
        memory_data_curr <= mem_rdata;
        memory_ready_curr <= mem_ready;
        current_state <= next_state;
        memory_address_curr <= proc_addr[29:2];
    end
    else begin
        // Normal operation - update state
        for (loop_index = 0; loop_index < ENTRY; loop_index = loop_index + 1) begin
            cache_line_curr[loop_index] <= cache_line_next[loop_index];
            addr_tag_curr[loop_index] <= addr_tag_next[loop_index];
            line_valid_curr[loop_index] <= line_valid_next[loop_index];
            access_recent_curr[loop_index] <= access_recent_next[loop_index];
        end
        current_state <= next_state;
        memory_read_curr <= memory_read_next;
        memory_data_curr <= mem_rdata;
        memory_ready_curr <= mem_ready;
        memory_address_curr <= proc_addr[29:2];
    end
end

endmodule