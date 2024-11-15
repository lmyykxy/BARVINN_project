module rom_sim (
    input wire [7:0] source_address,   // 输入地址，假设8位地址
    output reg [31:0] source_data,     // 输出数据，假设16位数据宽度
    input wire source_valid,           // 输入数据请求信号
    output reg source_ready            // 输出数据准备信号
);

    // 定义ROM大小
    localparam ROM_SIZE = 256;

    // ROM 存储器，初始化数据
    reg [31:0] rom [0:ROM_SIZE-1];

	reg[8*300-1:0] rom_file;
    // 初始化ROM内容
    initial begin
		if($value$plusargs("ROM_FILE=%s",rom_file))begin
      		$display("ROM_FILE=%s",rom_file);
    	end
        $readmemb({rom_file,".mem"}, rom);
    end

    // 读取操作
    always @(*) begin
        if (source_valid) begin
            source_data = rom[source_address]; // 根据地址获取数据
            source_ready = 1'b1;               // 表示数据准备完成
        end else begin
            source_ready = 1'b0;               // 没有请求时，准备信号无效
            source_data = 16'b0;               // 输出数据保持为0
        end
    end

endmodule
