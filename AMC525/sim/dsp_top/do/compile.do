# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    register_defs.vhd \
    $vhd_dir/system/adc_dsp_phase.vhd \
    $vhd_dir/system/pulse_adc_to_dsp.vhd \
    $vhd_dir/system/pulse_dsp_to_adc.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/sync_bit.vhd \
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/util/short_delay.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/util/long_delay.vhd \
    $vhd_dir/registers/all_pulsed_bits.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/registers/register_block.vhd \
    $vhd_dir/registers/register_read_adc.vhd \
    $vhd_dir/arithmetic/extract_signed.vhd \
    $vhd_dir/arithmetic/gain_control.vhd \
    $vhd_dir/arithmetic/rounded_product.vhd \
    $vhd_dir/fast_fir/fast_fir.vhd \
    $vhd_dir/fast_fir/fast_fir_top.vhd \
    $vhd_dir/min_max_sum/min_max_sum_defs.vhd \
    $vhd_dir/min_max_sum/min_max_sum_memory.vhd \
    $vhd_dir/min_max_sum/min_max_sum_store.vhd \
    $vhd_dir/min_max_sum/min_max_sum_update.vhd \
    $vhd_dir/min_max_sum/min_max_sum_readout.vhd \
    $vhd_dir/min_max_sum/min_max_sum_bank.vhd \
    $vhd_dir/min_max_sum/min_max_sum.vhd \
    $vhd_dir/min_max_sum/min_max_limit.vhd \
    $vhd_dir/bunch/bunch_defs.vhd \
    $vhd_dir/bunch/bunch_counter.vhd \
    $vhd_dir/bunch/bunch_store.vhd \
    $vhd_dir/bunch/bunch_select.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    nco_cos_sin_table.vhd \
    $vhd_dir/nco/nco_phase.vhd \
    $vhd_dir/nco/nco_cos_sin_prepare.vhd \
    $vhd_dir/nco/nco_cos_sin_refine.vhd \
    $vhd_dir/nco/nco_cos_sin_octant.vhd \
    $vhd_dir/nco/nco_core.vhd \
    $vhd_dir/nco/nco_delay.vhd \
    $vhd_dir/nco/nco.vhd \
    $vhd_dir/dsp/dsp_to_adc.vhd \
    $vhd_dir/dsp/dsp_defs.vhd \
    $vhd_dir/dsp/mms_dram_data_source.vhd \
    $vhd_dir/dac/dac_nco_delay.vhd \
    $vhd_dir/dac/dac_output_mux.vhd \
    $vhd_dir/dac/dac_top.vhd \
    $vhd_dir/bunch_fir/bunch_fir_dsp.vhd \
    $vhd_dir/bunch_fir/bunch_fir_taps.vhd \
    $vhd_dir/bunch_fir/bunch_fir_delay.vhd \
    $vhd_dir/bunch_fir/bunch_fir_decimate.vhd \
    $vhd_dir/bunch_fir/bunch_fir_interpolate.vhd \
    $vhd_dir/bunch_fir/bunch_fir.vhd \
    $vhd_dir/bunch_fir/bunch_fir_top.vhd \
    $vhd_dir/memory/memory_buffer_fast.vhd \
    $vhd_dir/memory/memory_buffer_simple.vhd \
    $vhd_dir/memory/memory_buffer.vhd \
    $vhd_dir/sequencer/sequencer_defs.vhd \
    $vhd_dir/sequencer/sequencer_registers.vhd \
    $vhd_dir/sequencer/sequencer_super.vhd \
    $vhd_dir/sequencer/sequencer_pc.vhd \
    $vhd_dir/sequencer/sequencer_load_state.vhd \
    $vhd_dir/sequencer/sequencer_dwell.vhd \
    $vhd_dir/sequencer/sequencer_counter.vhd \
    $vhd_dir/sequencer/sequencer_window.vhd \
    $vhd_dir/sequencer/sequencer_delays.vhd \
    $vhd_dir/sequencer/sequencer_clocking.vhd \
    $vhd_dir/sequencer/sequencer_top.vhd \
    $vhd_dir/detector/detector_defs.vhd \
    $vhd_dir/detector/detector_registers.vhd \
    $vhd_dir/detector/detector_bunch_mem.vhd \
    $vhd_dir/detector/detector_bunch_select.vhd \
    $vhd_dir/detector/detector_dsp96.vhd \
    $vhd_dir/detector/detector_core.vhd \
    $vhd_dir/detector/detector_output.vhd \
    $vhd_dir/detector/detector_body.vhd \
    $vhd_dir/detector/detector_input.vhd \
    $vhd_dir/detector/detector_dram_output.vhd \
    $vhd_dir/detector/detector_top.vhd \
    $vhd_dir/dsp/dsp_loopback.vhd \
    $vhd_dir/dsp/adc_overflow.vhd \
    $vhd_dir/dsp/adc_top.vhd \
    $vhd_dir/dsp/dsp_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \


# vim: set filetype=tcl:
