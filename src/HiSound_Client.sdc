# ============================================================
# HiSound_Client 时序约束文件 (SDC)
# 器件: GW1NSR-LV4CQN48PC6/I5 (GW1NSR-4C)
#
# 时钟架构 (全部 CLKDIV 硬件分频):
#   clk_24_576 ─> PLL1 (×4) ─┐
#   clk_22_5792 ─> PLL2 (×4) ─┤ DCS ─> pll_4x (98.304/90.3168 MHz)
#                               │
#              ┌────────────────┼────────────────────┐
#          CLKDIV/4        CLKDIV/32           CLKDIV/32→CLKDIV/64
#              │                │                      │
#           (mclk1)     (bclk0/1/2)            (fsclk0/1/2)
# ============================================================

# ============================================================
# 1. 输入时钟定义 (晶振)
# ============================================================

create_clock -name clk_24_576 -period 40.690 [get_ports {clk_24_576}]
create_clock -name clk_22_5792 -period 44.290 [get_ports {clk_22_5792}]

set_clock_groups -exclusive -group {clk_24_576} -group {clk_22_5792}

# ============================================================
# 2. 内部主时钟 pll_4x (DCS 输出, 全局时钟网络)
# ============================================================
# 48K 系列: 24.576 × 4 = 98.304 MHz, period = 10.172 ns
# 44.1K 系列: 22.5792 × 4 = 90.3168 MHz
create_clock -name pll_4x -period 10.172 [get_nets {pll_4x}]

# ============================================================
# 3. 输出端口时钟 (全部从 pll_4x 推导)
# ============================================================

# mclk1 = pll_4x / 4 (CLKDIV 硬件分频)
create_generated_clock -name mclk_out -source [get_nets {pll_4x}] -divide_by 4 [get_ports {mclk1}]

# bclk0/1/2 = pll_4x / 32 (CLKDIV 硬件分频)
create_generated_clock -name bclk_out_dac -source [get_nets {pll_4x}] -divide_by 32 [get_ports {bclk0}]
create_generated_clock -name bclk_out_rj12 -source [get_nets {pll_4x}] -divide_by 32 [get_ports {bclk1}]
create_generated_clock -name bclk_out_3863 -source [get_nets {pll_4x}] -divide_by 32 [get_ports {bclk2}]

# fsclk0/1/2 = pll_4x / 2048 (CLKDIV/32 → CLKDIV/64 级联)
create_generated_clock -name fsclk_out_dac -source [get_nets {pll_4x}] -divide_by 2048 [get_ports {fsclk0}]
create_generated_clock -name fsclk_out_rj12 -source [get_nets {pll_4x}] -divide_by 2048 [get_ports {fsclk1}]
create_generated_clock -name fsclk_out_3863 -source [get_nets {pll_4x}] -divide_by 2048 [get_ports {fsclk2}]

# ============================================================
# 4. I/O 时序约束 (相对各自对应的输出时钟)
# ============================================================

# --- di2: I2S 数据输入 (来自 Hi3863) ---
set_input_delay -clock bclk_out_3863 -max 8.0 [get_ports {di2}]
set_input_delay -clock bclk_out_3863 -min 2.0 [get_ports {di2}]

# --- do0: I2S 数据输出 (DAC) ---
set_output_delay -clock bclk_out_dac -max 8.0 [get_ports {do0}]
set_output_delay -clock bclk_out_dac -min 2.0 [get_ports {do0}]

# --- do1: I2S 数据输出 (DAC-RJ12) ---
set_output_delay -clock bclk_out_rj12 -max 8.0 [get_ports {do1}]
set_output_delay -clock bclk_out_rj12 -min 2.0 [get_ports {do1}]

# --- spdif_do: SPDIF 数据输出 ---
set_output_delay -clock bclk_out_dac -max 8.0 [get_ports {spdif_do}]
set_output_delay -clock bclk_out_dac -min 2.0 [get_ports {spdif_do}]

# ============================================================
# 5. 例外路径
# ============================================================

set_false_path -from [get_ports {sample_sel}]
set_false_path -from [get_ports {dev_cs_bin_3863[*]}]
