module cache(
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
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
    
//==== wire/reg definition ================================
    reg [127:0] blocks [0:7];   // 4*32 bits per block
    reg valid [0:7];
    reg dirty [0:7];
    reg [24:0] tag [0:7];   // one tag per block

    wire [24:0] addr_tag;
    wire [2:0] addr_idx;
    wire [1:0] addr_offset;

    reg [2:0] state, nxt_state;
    parameter S_IDLE = 3'd0;
    parameter S_WRITE_BACK = 3'd1;
    parameter S_READ_MEM = 3'd2;
    parameter S_WRITE_CACHE = 3'd3;
    
    reg proc_stall_r;
    reg [31:0] proc_rdata_r;
    reg mem_read_r, mem_write_r;
    reg [27:0] mem_addr_r;
    reg [127:0] mem_wdata_r;
    
    wire hit;
    wire [31:0] word_selected;
    
    // For handling read data from memory
    reg [31:0] read_data_from_mem;
    
    integer i;

//==== combinational circuit ==============================
    assign {addr_tag, addr_idx, addr_offset} = proc_addr;

    assign proc_stall = proc_stall_r;
    assign proc_rdata = proc_rdata_r;
    assign mem_read = mem_read_r;
    assign mem_write = mem_write_r;
    assign mem_addr = mem_addr_r;
    assign mem_wdata = mem_wdata_r;

    assign hit = valid[addr_idx] && (tag[addr_idx] == addr_tag);

    assign word_selected = (addr_offset == 2'b00) ? blocks[addr_idx][31:0] :
                          (addr_offset == 2'b01) ? blocks[addr_idx][63:32] :
                          (addr_offset == 2'b10) ? blocks[addr_idx][95:64] :
                                                  blocks[addr_idx][127:96];
                                                  
    // Select the correct word from memory data
    always @(*) begin
        case(addr_offset)
            2'b00: read_data_from_mem = mem_rdata[31:0];
            2'b01: read_data_from_mem = mem_rdata[63:32];
            2'b10: read_data_from_mem = mem_rdata[95:64];
            2'b11: read_data_from_mem = mem_rdata[127:96];
            default: read_data_from_mem = 32'b0;
        endcase
    end

    // Next state logic
    always @(*) begin
        nxt_state = state;
        case (state)
            S_IDLE: begin
                if((proc_read || proc_write) && !hit) begin
                    if(valid[addr_idx] && dirty[addr_idx])
                        nxt_state = S_WRITE_BACK;
                    else
                        nxt_state = S_READ_MEM;
                end
                // hit - stay in IDLE (default behavior)
            end
            S_WRITE_BACK: begin
                if (mem_ready) nxt_state = S_READ_MEM;
            end
            S_READ_MEM: begin
                if (mem_ready) nxt_state = S_WRITE_CACHE;
            end
            S_WRITE_CACHE: begin
                nxt_state = S_IDLE;
            end
            default: nxt_state = S_IDLE;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        // Default values
        proc_stall_r = 1'b0;
        proc_rdata_r = 32'b0;
        mem_read_r = 1'b0;
        mem_write_r = 1'b0;
        mem_addr_r = 28'b0;
        mem_wdata_r = 128'b0;
        
        case (state)
            S_IDLE: begin
                if(proc_read) begin
                    if(hit) begin
                        // Read hit - return data immediately
                        proc_rdata_r = word_selected;
                        proc_stall_r = 1'b0;
                    end
                    else begin
                        // Read miss - stall processor
                        proc_stall_r = 1'b1;
                        
                        if(valid[addr_idx] && dirty[addr_idx]) begin
                            // Need to write back first
                            mem_write_r = 1'b1;
                            mem_addr_r = {tag[addr_idx], addr_idx};
                            mem_wdata_r = blocks[addr_idx];
                        end
                        else begin
                            // Can read directly
                            mem_read_r = 1'b1;
                            mem_addr_r = {addr_tag, addr_idx};
                        end
                    end
                end
                else if(proc_write) begin
                    if(hit) begin
                        // Write hit - no stall for write-back policy
                        proc_stall_r = 1'b0;
                    end
                    else begin
                        // Write miss - stall processor
                        proc_stall_r = 1'b1;
                        
                        if(valid[addr_idx] && dirty[addr_idx]) begin
                            // Need to write back first
                            mem_write_r = 1'b1;
                            mem_addr_r = {tag[addr_idx], addr_idx};
                            mem_wdata_r = blocks[addr_idx];
                        end
                        else begin
                            // Can read directly
                            mem_read_r = 1'b1;
                            mem_addr_r = {addr_tag, addr_idx};
                        end
                    end
                end
            end
            
            S_WRITE_BACK: begin
                // Keep writing back to memory
                proc_stall_r = 1'b1;
                mem_write_r = 1'b1;
                mem_addr_r = {tag[addr_idx], addr_idx};
                mem_wdata_r = blocks[addr_idx];
            end
            
            S_READ_MEM: begin
                // Keep reading from memory
                proc_stall_r = 1'b1;
                mem_read_r = 1'b1;
                mem_addr_r = {addr_tag, addr_idx};
                
                // When data is ready from memory and it's a read operation
                if(mem_ready && proc_read) begin
                    proc_rdata_r = read_data_from_mem;
                end
            end
            
            S_WRITE_CACHE: begin
                // Still stalling while updating cache
                proc_stall_r = 1'b1;
                
                // If it's a read operation, return the data
                if(proc_read) begin
                    proc_rdata_r = read_data_from_mem;
                end
            end
        endcase
    end

//==== sequential circuit =================================
    always@(posedge clk) begin
        if(proc_reset) begin
            // Reset state
            state <= S_IDLE;
            
            // Reset cache arrays
            for(i = 0; i < 8; i = i + 1) begin
                valid[i] <= 1'b0;
                dirty[i] <= 1'b0;
                tag[i] <= 25'b0;
                blocks[i] <= 128'b0;
            end
        end
        else begin
            // State transition
            state <= nxt_state;
            
            // Cache operations based on state
            case(state)
                S_IDLE: begin
                    if(proc_write && hit) begin
                        // Write hit: update cache data and mark as dirty
                        case(addr_offset)
                            2'b00: blocks[addr_idx][31:0] <= proc_wdata;
                            2'b01: blocks[addr_idx][63:32] <= proc_wdata;
                            2'b10: blocks[addr_idx][95:64] <= proc_wdata;
                            2'b11: blocks[addr_idx][127:96] <= proc_wdata;
                        endcase
                        dirty[addr_idx] <= 1'b1; // Mark as dirty
                    end
                end
                
                S_WRITE_CACHE: begin
                    // Update cache with data from memory
                    blocks[addr_idx] <= mem_rdata;
                    tag[addr_idx] <= addr_tag;
                    valid[addr_idx] <= 1'b1;
                    
                    if(proc_write) begin
                        // For write miss, update the specific word
                        case(addr_offset)
                            2'b00: blocks[addr_idx][31:0] <= proc_wdata;
                            2'b01: blocks[addr_idx][63:32] <= proc_wdata;
                            2'b10: blocks[addr_idx][95:64] <= proc_wdata;
                            2'b11: blocks[addr_idx][127:96] <= proc_wdata;
                        endcase
                        dirty[addr_idx] <= 1'b1; // Mark as dirty
                    end
                    else begin
                        // For read miss, just update with memory data
                        dirty[addr_idx] <= 1'b0;
                    end
                end
            endcase
        end
    end
endmodule