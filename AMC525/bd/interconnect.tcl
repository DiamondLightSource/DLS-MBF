
################################################################
# This is a generated script based on design: interconnect
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source interconnect_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7vx690tffg1761-2
}


# CHANGE DESIGN NAME HERE
set design_name interconnect

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir .

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_msg_id "BD_TCL-110" "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_msg_id "BD_TCL-008" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_msg_id "BD_TCL-009" "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-111" "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-010" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-112" "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_msg_id "BD_TCL-113" "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-011" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_msg_id "BD_TCL-012" "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_interconnect_mig_7series_0_0 { str_mig_prj_filepath } {

   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {<?xml version='1.0' encoding='UTF-8'?>}
   puts $mig_prj_file {<!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {<Project DDR3Count="2" DDR2Count="0" NoOfControllers="2" RLDIICount="0" QDRIIPCount="0" >}
   puts $mig_prj_file {    <ModuleName>interconnect_mig_7series_0_0</ModuleName>}
   puts $mig_prj_file {    <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {    <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {    <Debug_En></Debug_En>}
   puts $mig_prj_file {    <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {    <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {    <XADC_En>Enabled</XADC_En>}
   puts $mig_prj_file {    <TargetFPGA>xc7vx690t-ffg1761/-2</TargetFPGA>}
   puts $mig_prj_file {    <Version>4.0</Version>}
   puts $mig_prj_file {    <SystemClock>Differential</SystemClock>}
   puts $mig_prj_file {    <ReferenceClock>No Buffer</ReferenceClock>}
   puts $mig_prj_file {    <SysResetPolarity>ACTIVE LOW</SysResetPolarity>}
   puts $mig_prj_file {    <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {    <InternalVref>0</InternalVref>}
   puts $mig_prj_file {    <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {    <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {    <Controller number="0" >}
   puts $mig_prj_file {        <MemoryDevice>DDR3_SDRAM/Components/MT41K256M16XX-125</MemoryDevice>}
   puts $mig_prj_file {        <TimePeriod>1875</TimePeriod>}
   puts $mig_prj_file {        <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {        <PHYRatio>2:1</PHYRatio>}
   puts $mig_prj_file {        <InputClkFreq>533.333</InputClkFreq>}
   puts $mig_prj_file {        <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {        <MMCM_VCO>1066</MMCM_VCO>}
   puts $mig_prj_file {        <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {        <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {        <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {        <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {        <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {        <DataWidth>64</DataWidth>}
   puts $mig_prj_file {        <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {        <DataMask>1</DataMask>}
   puts $mig_prj_file {        <ECC>Disabled</ECC>}
   puts $mig_prj_file {        <Ordering>Normal</Ordering>}
   puts $mig_prj_file {        <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {        <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {        <NewPartName></NewPartName>}
   puts $mig_prj_file {        <RowAddress>15</RowAddress>}
   puts $mig_prj_file {        <ColAddress>10</ColAddress>}
   puts $mig_prj_file {        <BankAddress>3</BankAddress>}
   puts $mig_prj_file {        <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {        <C0_MEM_SIZE>2147483648</C0_MEM_SIZE>}
   puts $mig_prj_file {        <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {        <PinSelection>}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AE38" SLEW="" name="ddr3_addr[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="Y42" SLEW="" name="ddr3_addr[10]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="Y40" SLEW="" name="ddr3_addr[11]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="W40" SLEW="" name="ddr3_addr[12]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AB42" SLEW="" name="ddr3_addr[13]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AB41" SLEW="" name="ddr3_addr[14]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AD38" SLEW="" name="ddr3_addr[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AE42" SLEW="" name="ddr3_addr[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AD42" SLEW="" name="ddr3_addr[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AC39" SLEW="" name="ddr3_addr[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AC38" SLEW="" name="ddr3_addr[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AA40" SLEW="" name="ddr3_addr[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AB39" SLEW="" name="ddr3_addr[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AB38" SLEW="" name="ddr3_addr[8]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AA42" SLEW="" name="ddr3_addr[9]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AE39" SLEW="" name="ddr3_ba[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AC41" SLEW="" name="ddr3_ba[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AC40" SLEW="" name="ddr3_ba[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AD41" SLEW="" name="ddr3_cas_n" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15" PADName="AA39" SLEW="" name="ddr3_ck_n[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15" PADName="Y39" SLEW="" name="ddr3_ck_p[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AG39" SLEW="" name="ddr3_cke[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="T34" SLEW="" name="ddr3_dm[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="T36" SLEW="" name="ddr3_dm[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="W36" SLEW="" name="ddr3_dm[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="V39" SLEW="" name="ddr3_dm[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AF35" SLEW="" name="ddr3_dm[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="Y37" SLEW="" name="ddr3_dm[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AF31" SLEW="" name="ddr3_dm[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="Y32" SLEW="" name="ddr3_dm[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="R35" SLEW="" name="ddr3_dq[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="P38" SLEW="" name="ddr3_dq[10]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="R38" SLEW="" name="ddr3_dq[11]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="R39" SLEW="" name="ddr3_dq[12]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U37" SLEW="" name="ddr3_dq[13]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U38" SLEW="" name="ddr3_dq[14]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U39" SLEW="" name="ddr3_dq[15]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U36" SLEW="" name="ddr3_dq[16]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="T37" SLEW="" name="ddr3_dq[17]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="V35" SLEW="" name="ddr3_dq[18]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="V36" SLEW="" name="ddr3_dq[19]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="N33" SLEW="" name="ddr3_dq[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="W37" SLEW="" name="ddr3_dq[20]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U32" SLEW="" name="ddr3_dq[21]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U33" SLEW="" name="ddr3_dq[22]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="W32" SLEW="" name="ddr3_dq[23]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="T40" SLEW="" name="ddr3_dq[24]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="T41" SLEW="" name="ddr3_dq[25]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U41" SLEW="" name="ddr3_dq[26]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="T42" SLEW="" name="ddr3_dq[27]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="W38" SLEW="" name="ddr3_dq[28]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="V38" SLEW="" name="ddr3_dq[29]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="N34" SLEW="" name="ddr3_dq[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="V41" SLEW="" name="ddr3_dq[30]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="U42" SLEW="" name="ddr3_dq[31]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AF36" SLEW="" name="ddr3_dq[32]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AE37" SLEW="" name="ddr3_dq[33]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AF37" SLEW="" name="ddr3_dq[34]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD36" SLEW="" name="ddr3_dq[35]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD37" SLEW="" name="ddr3_dq[36]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AC35" SLEW="" name="ddr3_dq[37]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AC36" SLEW="" name="ddr3_dq[38]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AG36" SLEW="" name="ddr3_dq[39]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="P35" SLEW="" name="ddr3_dq[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AA37" SLEW="" name="ddr3_dq[40]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="Y35" SLEW="" name="ddr3_dq[41]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AA36" SLEW="" name="ddr3_dq[42]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AA34" SLEW="" name="ddr3_dq[43]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AA35" SLEW="" name="ddr3_dq[44]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AB31" SLEW="" name="ddr3_dq[45]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AB32" SLEW="" name="ddr3_dq[46]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AB33" SLEW="" name="ddr3_dq[47]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD32" SLEW="" name="ddr3_dq[48]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD33" SLEW="" name="ddr3_dq[49]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="P36" SLEW="" name="ddr3_dq[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AC34" SLEW="" name="ddr3_dq[50]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD35" SLEW="" name="ddr3_dq[51]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AF32" SLEW="" name="ddr3_dq[52]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AE34" SLEW="" name="ddr3_dq[53]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AE35" SLEW="" name="ddr3_dq[54]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AE29" SLEW="" name="ddr3_dq[55]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AC31" SLEW="" name="ddr3_dq[56]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD31" SLEW="" name="ddr3_dq[57]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AC30" SLEW="" name="ddr3_dq[58]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AD30" SLEW="" name="ddr3_dq[59]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="T32" SLEW="" name="ddr3_dq[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AA29" SLEW="" name="ddr3_dq[60]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AA30" SLEW="" name="ddr3_dq[61]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AB29" SLEW="" name="ddr3_dq[62]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AC29" SLEW="" name="ddr3_dq[63]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="R32" SLEW="" name="ddr3_dq[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="P32" SLEW="" name="ddr3_dq[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="R37" SLEW="" name="ddr3_dq[8]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="P37" SLEW="" name="ddr3_dq[9]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="R34" SLEW="" name="ddr3_dqs_n[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="T35" SLEW="" name="ddr3_dqs_n[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="V34" SLEW="" name="ddr3_dqs_n[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="W42" SLEW="" name="ddr3_dqs_n[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AG34" SLEW="" name="ddr3_dqs_n[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AB37" SLEW="" name="ddr3_dqs_n[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AE33" SLEW="" name="ddr3_dqs_n[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AA32" SLEW="" name="ddr3_dqs_n[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="R33" SLEW="" name="ddr3_dqs_p[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="U34" SLEW="" name="ddr3_dqs_p[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="V33" SLEW="" name="ddr3_dqs_p[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="W41" SLEW="" name="ddr3_dqs_p[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AF34" SLEW="" name="ddr3_dqs_p[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AB36" SLEW="" name="ddr3_dqs_p[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AE32" SLEW="" name="ddr3_dqs_p[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AA31" SLEW="" name="ddr3_dqs_p[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AH39" SLEW="" name="ddr3_odt[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AE40" SLEW="" name="ddr3_ras_n" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="LVCMOS15" PADName="T39" SLEW="" name="ddr3_reset_n" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AF40" SLEW="" name="ddr3_we_n" IN_TERM="" />}
   puts $mig_prj_file {        </PinSelection>}
   puts $mig_prj_file {        <System_Clock>}
   puts $mig_prj_file {            <Pin PADName="AF41/AG41(CC_P/N)" Bank="17" name="c0_sys_clk_p/n" />}
   puts $mig_prj_file {        </System_Clock>}
   puts $mig_prj_file {        <System_Control>}
   puts $mig_prj_file {            <Pin PADName="No connect" Bank="Select Bank" name="sys_rst" />}
   puts $mig_prj_file {            <Pin PADName="No connect" Bank="Select Bank" name="init_calib_complete" />}
   puts $mig_prj_file {            <Pin PADName="No connect" Bank="Select Bank" name="tg_compare_error" />}
   puts $mig_prj_file {        </System_Control>}
   puts $mig_prj_file {        <TimingParameters>}
   puts $mig_prj_file {            <Parameters twtr="7.5" trrd="7.5" trefi="7.8" tfaw="40" trtp="7.5" tcke="5" trfc="260" trp="13.75" tras="35" trcd="13.75" />}
   puts $mig_prj_file {        </TimingParameters>}
   puts $mig_prj_file {        <mrBurstLength name="Burst Length" >8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {        <mrBurstType name="Read Burst Type and Length" >Sequential</mrBurstType>}
   puts $mig_prj_file {        <mrCasLatency name="CAS Latency" >7</mrCasLatency>}
   puts $mig_prj_file {        <mrMode name="Mode" >Normal</mrMode>}
   puts $mig_prj_file {        <mrDllReset name="DLL Reset" >No</mrDllReset>}
   puts $mig_prj_file {        <mrPdMode name="DLL control for precharge PD" >Slow Exit</mrPdMode>}
   puts $mig_prj_file {        <emrDllEnable name="DLL Enable" >Enable</emrDllEnable>}
   puts $mig_prj_file {        <emrOutputDriveStrength name="Output Driver Impedance Control" >RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {        <emrMirrorSelection name="Address Mirroring" >Disable</emrMirrorSelection>}
   puts $mig_prj_file {        <emrCSSelection name="Controller Chip Select Pin" >Disable</emrCSSelection>}
   puts $mig_prj_file {        <emrRTT name="RTT (nominal) - On Die Termination (ODT)" >RZQ/4</emrRTT>}
   puts $mig_prj_file {        <emrPosted name="Additive Latency (AL)" >0</emrPosted>}
   puts $mig_prj_file {        <emrOCD name="Write Leveling Enable" >Disabled</emrOCD>}
   puts $mig_prj_file {        <emrDQS name="TDQS enable" >Enabled</emrDQS>}
   puts $mig_prj_file {        <emrRDQS name="Qoff" >Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {        <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh" >Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {        <mr2CasWriteLatency name="CAS write latency" >6</mr2CasWriteLatency>}
   puts $mig_prj_file {        <mr2AutoSelfRefresh name="Auto Self Refresh" >Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {        <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate" >Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {        <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)" >Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {        <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {        <AXIParameters>}
   puts $mig_prj_file {            <C0_C_RD_WR_ARB_ALGORITHM>WRITE_PRIORITY_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {            <C0_S_AXI_ADDR_WIDTH>31</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {            <C0_S_AXI_DATA_WIDTH>256</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {            <C0_S_AXI_ID_WIDTH>1</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {            <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {        </AXIParameters>}
   puts $mig_prj_file {    </Controller>}
   puts $mig_prj_file {    <Controller number="1" >}
   puts $mig_prj_file {        <MemoryDevice>DDR3_SDRAM/Components/MT41K256M16XX-125</MemoryDevice>}
   puts $mig_prj_file {        <TimePeriod>1875</TimePeriod>}
   puts $mig_prj_file {        <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {        <PHYRatio>2:1</PHYRatio>}
   puts $mig_prj_file {        <InputClkFreq>533.333</InputClkFreq>}
   puts $mig_prj_file {        <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {        <MMCM_VCO>1066</MMCM_VCO>}
   puts $mig_prj_file {        <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {        <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {        <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {        <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {        <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {        <DataWidth>16</DataWidth>}
   puts $mig_prj_file {        <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {        <DataMask>1</DataMask>}
   puts $mig_prj_file {        <ECC>Disabled</ECC>}
   puts $mig_prj_file {        <Ordering>Normal</Ordering>}
   puts $mig_prj_file {        <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {        <CustomPart>TRUE</CustomPart>}
   puts $mig_prj_file {        <NewPartName>MT41K256M16XX-125-UNUSEDA14A13</NewPartName>}
   puts $mig_prj_file {        <RowAddress>13</RowAddress>}
   puts $mig_prj_file {        <ColAddress>10</ColAddress>}
   puts $mig_prj_file {        <BankAddress>3</BankAddress>}
   puts $mig_prj_file {        <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {        <C1_MEM_SIZE>134217728</C1_MEM_SIZE>}
   puts $mig_prj_file {        <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {        <PinSelection>}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AU36" SLEW="" name="ddr3_addr[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AV36" SLEW="" name="ddr3_addr[10]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="BA35" SLEW="" name="ddr3_addr[11]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AY34" SLEW="" name="ddr3_addr[12]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AT36" SLEW="" name="ddr3_addr[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AU34" SLEW="" name="ddr3_addr[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AT34" SLEW="" name="ddr3_addr[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AW35" SLEW="" name="ddr3_addr[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="BB33" SLEW="" name="ddr3_addr[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="BB32" SLEW="" name="ddr3_addr[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="BB36" SLEW="" name="ddr3_addr[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="BA36" SLEW="" name="ddr3_addr[8]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AW36" SLEW="" name="ddr3_addr[9]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AR34" SLEW="" name="ddr3_ba[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AU33" SLEW="" name="ddr3_ba[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AT32" SLEW="" name="ddr3_ba[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AU32" SLEW="" name="ddr3_cas_n" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15" PADName="BB34" SLEW="" name="ddr3_ck_n[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15" PADName="BA34" SLEW="" name="ddr3_ck_p[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AW32" SLEW="" name="ddr3_cke[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AW30" SLEW="" name="ddr3_dm[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AR30" SLEW="" name="ddr3_dm[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AV34" SLEW="" name="ddr3_dq[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AP32" SLEW="" name="ddr3_dq[10]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AR32" SLEW="" name="ddr3_dq[11]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AN31" SLEW="" name="ddr3_dq[12]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AP31" SLEW="" name="ddr3_dq[13]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AP33" SLEW="" name="ddr3_dq[14]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AR33" SLEW="" name="ddr3_dq[15]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AV35" SLEW="" name="ddr3_dq[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AY32" SLEW="" name="ddr3_dq[2]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AY33" SLEW="" name="ddr3_dq[3]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AY30" SLEW="" name="ddr3_dq[4]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="BA30" SLEW="" name="ddr3_dq[5]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="BB31" SLEW="" name="ddr3_dq[6]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AV30" SLEW="" name="ddr3_dq[7]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AU31" SLEW="" name="ddr3_dq[8]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15_T_DCI" PADName="AV31" SLEW="" name="ddr3_dq[9]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="BA32" SLEW="" name="ddr3_dqs_n[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AP30" SLEW="" name="ddr3_dqs_n[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="BA31" SLEW="" name="ddr3_dqs_p[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AN30" SLEW="" name="ddr3_dqs_p[1]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AW33" SLEW="" name="ddr3_odt[0]" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AT35" SLEW="" name="ddr3_ras_n" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="LVCMOS15" PADName="AW31" SLEW="" name="ddr3_reset_n" IN_TERM="" />}
   puts $mig_prj_file {            <Pin VCCAUX_IO="NORMAL" IOSTANDARD="SSTL15" PADName="AV33" SLEW="" name="ddr3_we_n" IN_TERM="" />}
   puts $mig_prj_file {        </PinSelection>}
   puts $mig_prj_file {        <System_Clock>}
   puts $mig_prj_file {            <Pin PADName="AJ32/AK32(CC_P/N)" Bank="14" name="c1_sys_clk_p/n" />}
   puts $mig_prj_file {        </System_Clock>}
   puts $mig_prj_file {        <TimingParameters>}
   puts $mig_prj_file {            <Parameters twtr="7.5" trrd="7.5" trefi="7.8" tfaw="40" trtp="7.5" tcke="5" trfc="260" trp="13.75" tras="35" trcd="13.75" />}
   puts $mig_prj_file {        </TimingParameters>}
   puts $mig_prj_file {        <mrBurstLength name="Burst Length" >8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {        <mrBurstType name="Read Burst Type and Length" >Sequential</mrBurstType>}
   puts $mig_prj_file {        <mrCasLatency name="CAS Latency" >7</mrCasLatency>}
   puts $mig_prj_file {        <mrMode name="Mode" >Normal</mrMode>}
   puts $mig_prj_file {        <mrDllReset name="DLL Reset" >No</mrDllReset>}
   puts $mig_prj_file {        <mrPdMode name="DLL control for precharge PD" >Slow Exit</mrPdMode>}
   puts $mig_prj_file {        <emrDllEnable name="DLL Enable" >Enable</emrDllEnable>}
   puts $mig_prj_file {        <emrOutputDriveStrength name="Output Driver Impedance Control" >RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {        <emrMirrorSelection name="Address Mirroring" >Disable</emrMirrorSelection>}
   puts $mig_prj_file {        <emrCSSelection name="Controller Chip Select Pin" >Disable</emrCSSelection>}
   puts $mig_prj_file {        <emrRTT name="RTT (nominal) - On Die Termination (ODT)" >RZQ/4</emrRTT>}
   puts $mig_prj_file {        <emrPosted name="Additive Latency (AL)" >0</emrPosted>}
   puts $mig_prj_file {        <emrOCD name="Write Leveling Enable" >Disabled</emrOCD>}
   puts $mig_prj_file {        <emrDQS name="TDQS enable" >Enabled</emrDQS>}
   puts $mig_prj_file {        <emrRDQS name="Qoff" >Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {        <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh" >Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {        <mr2CasWriteLatency name="CAS write latency" >6</mr2CasWriteLatency>}
   puts $mig_prj_file {        <mr2AutoSelfRefresh name="Auto Self Refresh" >Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {        <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate" >Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {        <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)" >Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {        <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {        <AXIParameters>}
   puts $mig_prj_file {            <C1_C_RD_WR_ARB_ALGORITHM>WRITE_PRIORITY_REG</C1_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {            <C1_S_AXI_ADDR_WIDTH>27</C1_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {            <C1_S_AXI_DATA_WIDTH>64</C1_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {            <C1_S_AXI_ID_WIDTH>1</C1_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {            <C1_S_AXI_SUPPORTS_NARROW_BURST>0</C1_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {        </AXIParameters>}
   puts $mig_prj_file {    </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_interconnect_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: memory_interconnect
proc create_hier_cell_memory_interconnect { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_memory_interconnect() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DMA_W
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DRAM0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DRAM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DMA
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DSP_DRAM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DSP_DRAM1

  # Create pins
  create_bd_pin -dir I -type clk DMA_ACLK
  create_bd_pin -dir I -type rst DMA_ARESETN
  create_bd_pin -dir I -type clk DRAM0_ACLK
  create_bd_pin -dir I -type rst DRAM0_ARESETN
  create_bd_pin -dir I -type clk DRAM1_ACLK
  create_bd_pin -dir I -type rst DRAM1_ARESETN
  create_bd_pin -dir I -type rst DSP_ARESETN
  create_bd_pin -dir I -type clk DSP_CLK

  # Create instance: ddr0_buf, and set properties
  set ddr0_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 ddr0_buf ]
  set_property -dict [ list \
CONFIG.REG_AR {7} \
CONFIG.REG_AW {7} \
CONFIG.REG_B {7} \
 ] $ddr0_buf

  # Create instance: ddr0_crossbar, and set properties
  set ddr0_crossbar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 ddr0_crossbar ]
  set_property -dict [ list \
CONFIG.M00_S00_READ_CONNECTIVITY {0} \
CONFIG.M00_S00_WRITE_CONNECTIVITY {1} \
CONFIG.M00_S01_READ_CONNECTIVITY {1} \
CONFIG.M00_S01_WRITE_CONNECTIVITY {0} \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {2} \
 ] $ddr0_crossbar

  # Create instance: ddr0_us, and set properties
  set ddr0_us [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 ddr0_us ]
  set_property -dict [ list \
CONFIG.ACLK_ASYNC {1} \
CONFIG.FIFO_MODE {2} \
CONFIG.MI_DATA_WIDTH {256} \
CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
CONFIG.SI_DATA_WIDTH {64} \
 ] $ddr0_us

  # Create instance: ddr1_buf, and set properties
  set ddr1_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 ddr1_buf ]

  # Create instance: ddr1_crossbar, and set properties
  set ddr1_crossbar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 ddr1_crossbar ]
  set_property -dict [ list \
CONFIG.M00_S00_READ_CONNECTIVITY {0} \
CONFIG.M00_S00_WRITE_CONNECTIVITY {1} \
CONFIG.M00_S01_READ_CONNECTIVITY {1} \
CONFIG.M00_S01_WRITE_CONNECTIVITY {0} \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {2} \
 ] $ddr1_crossbar

  # Create instance: dma_buf, and set properties
  set dma_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 dma_buf ]
  set_property -dict [ list \
CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
 ] $dma_buf

  # Create instance: dma_ddr0_cc, and set properties
  set dma_ddr0_cc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 dma_ddr0_cc ]
  set_property -dict [ list \
CONFIG.READ_WRITE_MODE {READ_ONLY} \
 ] $dma_ddr0_cc

  # Create instance: dma_ddr1_cc, and set properties
  set dma_ddr1_cc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 dma_ddr1_cc ]
  set_property -dict [ list \
CONFIG.READ_WRITE_MODE {READ_ONLY} \
 ] $dma_ddr1_cc

  # Create instance: dma_ddr1_ds, and set properties
  set dma_ddr1_ds [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 dma_ddr1_ds ]
  set_property -dict [ list \
CONFIG.READ_WRITE_MODE {READ_ONLY} \
 ] $dma_ddr1_ds

  # Create instance: dma_xbar, and set properties
  set dma_xbar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 dma_xbar ]
  set_property -dict [ list \
CONFIG.M00_S00_READ_CONNECTIVITY {1} \
CONFIG.M00_S00_WRITE_CONNECTIVITY {0} \
CONFIG.M00_S01_READ_CONNECTIVITY {0} \
CONFIG.M00_S01_WRITE_CONNECTIVITY {0} \
CONFIG.M00_S02_READ_CONNECTIVITY {1} \
CONFIG.M00_S02_WRITE_CONNECTIVITY {0} \
CONFIG.M01_S00_READ_CONNECTIVITY {1} \
CONFIG.M01_S00_WRITE_CONNECTIVITY {0} \
CONFIG.M01_S01_READ_CONNECTIVITY {0} \
CONFIG.M01_S01_WRITE_CONNECTIVITY {1} \
CONFIG.M01_S02_READ_CONNECTIVITY {1} \
CONFIG.M01_S02_WRITE_CONNECTIVITY {0} \
CONFIG.M02_S00_READ_CONNECTIVITY {0} \
CONFIG.M02_S00_WRITE_CONNECTIVITY {1} \
CONFIG.M02_S01_READ_CONNECTIVITY {0} \
CONFIG.M02_S01_WRITE_CONNECTIVITY {0} \
CONFIG.M02_S02_READ_CONNECTIVITY {0} \
CONFIG.M02_S02_WRITE_CONNECTIVITY {1} \
CONFIG.NUM_MI {3} \
CONFIG.NUM_SI {1} \
CONFIG.STRATEGY {0} \
 ] $dma_xbar

  # Create instance: dsp_ddr1_buf, and set properties
  set dsp_ddr1_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 dsp_ddr1_buf ]

  # Create instance: dsp_ddr1_cc, and set properties
  set dsp_ddr1_cc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 dsp_ddr1_cc ]
  set_property -dict [ list \
CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
 ] $dsp_ddr1_cc

  # Create instance: dsp_ddr1_pc, and set properties
  set dsp_ddr1_pc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 dsp_ddr1_pc ]
  set_property -dict [ list \
CONFIG.MI_PROTOCOL {AXI4} \
CONFIG.SI_PROTOCOL {AXI4LITE} \
CONFIG.TRANSLATION_MODE {2} \
 ] $dsp_ddr1_pc

  # Create interface connections
  connect_bd_intf_net -intf_net S_DMA_1 [get_bd_intf_pins S_DMA] [get_bd_intf_pins dma_xbar/S00_AXI]
  connect_bd_intf_net -intf_net S_DSP_DRAM0_1 [get_bd_intf_pins S_DSP_DRAM0] [get_bd_intf_pins ddr0_us/S_AXI]
  connect_bd_intf_net -intf_net S_DSP_DRAM1_1 [get_bd_intf_pins S_DSP_DRAM1] [get_bd_intf_pins dsp_ddr1_buf/S_AXI]
  connect_bd_intf_net -intf_net auto_ds_M_AXI [get_bd_intf_pins dma_ddr1_cc/S_AXI] [get_bd_intf_pins dma_ddr1_ds/M_AXI]
  connect_bd_intf_net -intf_net axi_protocol_converter_0_M_AXI [get_bd_intf_pins dsp_ddr1_cc/S_AXI] [get_bd_intf_pins dsp_ddr1_pc/M_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_0_M_AXI [get_bd_intf_pins dsp_ddr1_buf/M_AXI] [get_bd_intf_pins dsp_ddr1_pc/S_AXI]
  connect_bd_intf_net -intf_net ddr0_buf2_M_AXI [get_bd_intf_pins M_DRAM0] [get_bd_intf_pins ddr0_buf/M_AXI]
  connect_bd_intf_net -intf_net ddr0_crossbar_M00_AXI [get_bd_intf_pins ddr0_buf/S_AXI] [get_bd_intf_pins ddr0_crossbar/M00_AXI]
  connect_bd_intf_net -intf_net ddr0_us_M_AXI [get_bd_intf_pins ddr0_crossbar/S00_AXI] [get_bd_intf_pins ddr0_us/M_AXI]
  connect_bd_intf_net -intf_net ddr1_buf_M_AXI [get_bd_intf_pins M_DRAM1] [get_bd_intf_pins ddr1_buf/M_AXI]
  connect_bd_intf_net -intf_net ddr1_crossbar_M00_AXI [get_bd_intf_pins ddr1_buf/S_AXI] [get_bd_intf_pins ddr1_crossbar/M00_AXI]
  connect_bd_intf_net -intf_net dma_buf_M_AXI [get_bd_intf_pins M_DMA_W] [get_bd_intf_pins dma_buf/M_AXI]
  connect_bd_intf_net -intf_net dma_ddr0_cc_M_AXI [get_bd_intf_pins ddr0_crossbar/S01_AXI] [get_bd_intf_pins dma_ddr0_cc/M_AXI]
  connect_bd_intf_net -intf_net dma_ddr1_cc_M_AXI [get_bd_intf_pins ddr1_crossbar/S01_AXI] [get_bd_intf_pins dma_ddr1_cc/M_AXI]
  connect_bd_intf_net -intf_net dma_xbar_M00_AXI [get_bd_intf_pins dma_ddr0_cc/S_AXI] [get_bd_intf_pins dma_xbar/M00_AXI]
  connect_bd_intf_net -intf_net dma_xbar_M01_AXI [get_bd_intf_pins dma_ddr1_ds/S_AXI] [get_bd_intf_pins dma_xbar/M01_AXI]
  connect_bd_intf_net -intf_net dma_xbar_M02_AXI [get_bd_intf_pins dma_buf/S_AXI] [get_bd_intf_pins dma_xbar/M02_AXI]
  connect_bd_intf_net -intf_net dsp_ddr1_cc_M_AXI [get_bd_intf_pins ddr1_crossbar/S00_AXI] [get_bd_intf_pins dsp_ddr1_cc/M_AXI]

  # Create port connections
  connect_bd_net -net DMA_ACLK_1 [get_bd_pins DMA_ACLK] [get_bd_pins dma_buf/aclk] [get_bd_pins dma_ddr0_cc/s_axi_aclk] [get_bd_pins dma_ddr1_cc/s_axi_aclk] [get_bd_pins dma_ddr1_ds/s_axi_aclk] [get_bd_pins dma_xbar/aclk]
  connect_bd_net -net DMA_ARESETN_1 [get_bd_pins DMA_ARESETN] [get_bd_pins dma_buf/aresetn] [get_bd_pins dma_ddr0_cc/s_axi_aresetn] [get_bd_pins dma_ddr1_cc/s_axi_aresetn] [get_bd_pins dma_ddr1_ds/s_axi_aresetn] [get_bd_pins dma_xbar/aresetn]
  connect_bd_net -net DRAM0_ACLK_1 [get_bd_pins DRAM0_ACLK] [get_bd_pins ddr0_buf/aclk] [get_bd_pins ddr0_crossbar/aclk] [get_bd_pins ddr0_us/m_axi_aclk] [get_bd_pins dma_ddr0_cc/m_axi_aclk]
  connect_bd_net -net DRAM0_ARESETN_1 [get_bd_pins DRAM0_ARESETN] [get_bd_pins ddr0_buf/aresetn] [get_bd_pins ddr0_crossbar/aresetn] [get_bd_pins ddr0_us/m_axi_aresetn] [get_bd_pins dma_ddr0_cc/m_axi_aresetn]
  connect_bd_net -net DRAM1_ACLK_1 [get_bd_pins DRAM1_ACLK] [get_bd_pins ddr1_buf/aclk] [get_bd_pins ddr1_crossbar/aclk] [get_bd_pins dma_ddr1_cc/m_axi_aclk] [get_bd_pins dsp_ddr1_cc/m_axi_aclk]
  connect_bd_net -net DRAM1_ARESETN_1 [get_bd_pins DRAM1_ARESETN] [get_bd_pins ddr1_buf/aresetn] [get_bd_pins ddr1_crossbar/aresetn] [get_bd_pins dma_ddr1_cc/m_axi_aresetn] [get_bd_pins dsp_ddr1_cc/m_axi_aresetn]
  connect_bd_net -net DSP_ARESETN_1 [get_bd_pins DSP_ARESETN] [get_bd_pins ddr0_us/s_axi_aresetn] [get_bd_pins dsp_ddr1_buf/aresetn] [get_bd_pins dsp_ddr1_cc/s_axi_aresetn] [get_bd_pins dsp_ddr1_pc/aresetn]
  connect_bd_net -net DSP_CLK_1 [get_bd_pins DSP_CLK] [get_bd_pins ddr0_us/s_axi_aclk] [get_bd_pins dsp_ddr1_buf/aclk] [get_bd_pins dsp_ddr1_cc/s_axi_aclk] [get_bd_pins dsp_ddr1_pc/aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: memory
proc create_hier_cell_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 C0_DDR3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_SYS_CLK
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 C1_DDR3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C1_SYS_CLK
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DRAM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DRAM1

  # Create pins
  create_bd_pin -dir I -type clk CLKREF
  create_bd_pin -dir O -type clk DRAM0_ACLK
  create_bd_pin -dir O DRAM0_ARESETN
  create_bd_pin -dir O -type clk DRAM1_ACLK
  create_bd_pin -dir O DRAM1_ARESETN
  create_bd_pin -dir I -type rst SYS_RSTN

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.0 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_b.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_interconnect_mig_7series_0_0 $str_mig_file_path

  set_property -dict [ list \
CONFIG.BOARD_MIG_PARAM {Custom} \
CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
CONFIG.RESET_BOARD_INTERFACE {Custom} \
CONFIG.XML_INPUT_FILE {mig_b.prj} \
 ] $mig_7series_0

  # Create instance: util_reduced_logic_0, and set properties
  set util_reduced_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 util_reduced_logic_0 ]
  set_property -dict [ list \
CONFIG.C_SIZE {1} \
 ] $util_reduced_logic_0

  # Create instance: util_reduced_logic_1, and set properties
  set util_reduced_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 util_reduced_logic_1 ]
  set_property -dict [ list \
CONFIG.C_SIZE {1} \
 ] $util_reduced_logic_1

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_1

  # Create interface connections
  connect_bd_intf_net -intf_net C0_SYS_CLK_1 [get_bd_intf_pins C0_SYS_CLK] [get_bd_intf_pins mig_7series_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net C1_SYS_CLK_1 [get_bd_intf_pins C1_SYS_CLK] [get_bd_intf_pins mig_7series_0/C1_SYS_CLK]
  connect_bd_intf_net -intf_net DRAM0_AXI_R_1 [get_bd_intf_pins M_DRAM0] [get_bd_intf_pins mig_7series_0/S0_AXI]
  connect_bd_intf_net -intf_net DRAM1_AXI_R_1 [get_bd_intf_pins M_DRAM1] [get_bd_intf_pins mig_7series_0/S1_AXI]
  connect_bd_intf_net -intf_net mig_7series_0_C0_DDR3 [get_bd_intf_pins C0_DDR3] [get_bd_intf_pins mig_7series_0/C0_DDR3]
  connect_bd_intf_net -intf_net mig_7series_0_C1_DDR3 [get_bd_intf_pins C1_DDR3] [get_bd_intf_pins mig_7series_0/C1_DDR3]

  # Create port connections
  connect_bd_net -net CLK200MHZ_1 [get_bd_pins CLKREF] [get_bd_pins mig_7series_0/clk_ref_i]
  connect_bd_net -net mig_7series_0_c0_ui_clk [get_bd_pins DRAM0_ACLK] [get_bd_pins mig_7series_0/c0_ui_clk]
  connect_bd_net -net mig_7series_0_c0_ui_clk_sync_rst [get_bd_pins mig_7series_0/c0_ui_clk_sync_rst] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net mig_7series_0_c1_ui_clk [get_bd_pins DRAM1_ACLK] [get_bd_pins mig_7series_0/c1_ui_clk]
  connect_bd_net -net mig_7series_0_c1_ui_clk_sync_rst [get_bd_pins mig_7series_0/c1_ui_clk_sync_rst] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net nCOLDRST_1 [get_bd_pins SYS_RSTN] [get_bd_pins mig_7series_0/sys_rst]
  connect_bd_net -net util_reduced_logic_0_Res [get_bd_pins DRAM0_ARESETN] [get_bd_pins mig_7series_0/c0_aresetn] [get_bd_pins util_reduced_logic_0/Res]
  connect_bd_net -net util_reduced_logic_1_Res [get_bd_pins DRAM1_ARESETN] [get_bd_pins mig_7series_0/c1_aresetn] [get_bd_pins util_reduced_logic_1/Res]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins util_reduced_logic_0/Op1] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins util_reduced_logic_1/Op1] [get_bd_pins util_vector_logic_1/Res]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: memory_dma
proc create_hier_cell_memory_dma { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_memory_dma() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 C0_DDR3
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 C1_DDR3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 DRAM0_CLK
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 DRAM1_CLK
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DMA_W
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DMA_REGS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DSP_DRAM0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DSP_DRAM1

  # Create pins
  create_bd_pin -dir I -type clk CLK200MHZ
  create_bd_pin -dir I -type clk DMA_ACLK
  create_bd_pin -dir I -type rst DMA_ARESETN
  create_bd_pin -dir O -type intr DMA_INT_REQ
  create_bd_pin -dir I -type clk DSP_CLK
  create_bd_pin -dir I -type rst DSP_RESETN
  create_bd_pin -dir I -type rst SYS_RSTN

  # Create instance: axi_cdma_0, and set properties
  set axi_cdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_cdma:4.1 axi_cdma_0 ]
  set_property -dict [ list \
CONFIG.C_ADDR_WIDTH {48} \
CONFIG.C_INCLUDE_SG {0} \
CONFIG.C_M_AXI_DATA_WIDTH {256} \
CONFIG.C_M_AXI_MAX_BURST_LEN {128} \
 ] $axi_cdma_0

  # Create instance: memory
  create_hier_cell_memory $hier_obj memory

  # Create instance: memory_interconnect
  create_hier_cell_memory_interconnect $hier_obj memory_interconnect

  # Create interface connections
  connect_bd_intf_net -intf_net C0_SYS_CLK_1 [get_bd_intf_pins DRAM0_CLK] [get_bd_intf_pins memory/C0_SYS_CLK]
  connect_bd_intf_net -intf_net C1_SYS_CLK_1 [get_bd_intf_pins DRAM1_CLK] [get_bd_intf_pins memory/C1_SYS_CLK]
  connect_bd_intf_net -intf_net S_DSP_DRAM0_1 [get_bd_intf_pins S_DSP_DRAM0] [get_bd_intf_pins memory_interconnect/S_DSP_DRAM0]
  connect_bd_intf_net -intf_net S_DSP_DRAM1_1 [get_bd_intf_pins S_DSP_DRAM1] [get_bd_intf_pins memory_interconnect/S_DSP_DRAM1]
  connect_bd_intf_net -intf_net axi_cdma_0_M_AXI [get_bd_intf_pins axi_cdma_0/M_AXI] [get_bd_intf_pins memory_interconnect/S_DMA]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins memory/M_DRAM0] [get_bd_intf_pins memory_interconnect/M_DRAM0]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins memory/M_DRAM1] [get_bd_intf_pins memory_interconnect/M_DRAM1]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins M_DMA_W] [get_bd_intf_pins memory_interconnect/M_DMA_W]
  connect_bd_intf_net -intf_net axi_lite_interconnect_M02_AXI [get_bd_intf_pins S_DMA_REGS] [get_bd_intf_pins axi_cdma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net mig_7series_0_C0_DDR3 [get_bd_intf_pins C0_DDR3] [get_bd_intf_pins memory/C0_DDR3]
  connect_bd_intf_net -intf_net mig_7series_0_C1_DDR3 [get_bd_intf_pins C1_DDR3] [get_bd_intf_pins memory/C1_DDR3]

  # Create port connections
  connect_bd_net -net DRAM0_ARESETN_1 [get_bd_pins memory/DRAM0_ARESETN] [get_bd_pins memory_interconnect/DRAM0_ARESETN]
  connect_bd_net -net DSP_CLK_1 [get_bd_pins DSP_CLK] [get_bd_pins memory_interconnect/DSP_CLK]
  connect_bd_net -net DSP_RESETN_1 [get_bd_pins DSP_RESETN] [get_bd_pins memory_interconnect/DSP_ARESETN]
  connect_bd_net -net axi_cdma_0_cdma_introut [get_bd_pins DMA_INT_REQ] [get_bd_pins axi_cdma_0/cdma_introut]
  connect_bd_net -net axi_pcie3_axi_aclk [get_bd_pins DMA_ACLK] [get_bd_pins axi_cdma_0/m_axi_aclk] [get_bd_pins axi_cdma_0/s_axi_lite_aclk] [get_bd_pins memory_interconnect/DMA_ACLK]
  connect_bd_net -net axi_pcie3_axi_aresetn [get_bd_pins DMA_ARESETN] [get_bd_pins axi_cdma_0/s_axi_lite_aresetn] [get_bd_pins memory_interconnect/DMA_ARESETN]
  connect_bd_net -net clk_in1_1 [get_bd_pins CLK200MHZ] [get_bd_pins memory/CLKREF]
  connect_bd_net -net memory_DRAM1_ARESETN1 [get_bd_pins memory/DRAM1_ARESETN] [get_bd_pins memory_interconnect/DRAM1_ARESETN]
  connect_bd_net -net memory_c0_ui_clk [get_bd_pins memory/DRAM0_ACLK] [get_bd_pins memory_interconnect/DRAM0_ACLK]
  connect_bd_net -net memory_c1_ui_clk [get_bd_pins memory/DRAM1_ACLK] [get_bd_pins memory_interconnect/DRAM1_ACLK]
  connect_bd_net -net reset_rtl_0_1 [get_bd_pins SYS_RSTN] [get_bd_pins memory/SYS_RSTN]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: interrupts
proc create_hier_cell_interrupts { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_interrupts() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_INTC_REGS

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 In0
  create_bd_pin -dir I -from 30 -to 0 In1
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_intc, and set properties
  set axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc ]
  set_property -dict [ list \
CONFIG.C_HAS_CIE {0} \
CONFIG.C_HAS_ILR {0} \
CONFIG.C_HAS_IPR {0} \
CONFIG.C_HAS_IVR {0} \
CONFIG.C_HAS_SIE {0} \
CONFIG.C_IRQ_CONNECTION {1} \
CONFIG.C_IRQ_IS_LEVEL {0} \
CONFIG.C_NUM_SW_INTR {0} \
CONFIG.C_S_AXI_ACLK_FREQ_MHZ {250} \
 ] $axi_intc

  # Create instance: xlconcat, and set properties
  set xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_lite_M03_AXI [get_bd_intf_pins S_INTC_REGS] [get_bd_intf_pins axi_intc/s_axi]

  # Create port connections
  connect_bd_net -net INTR_1 [get_bd_pins In1] [get_bd_pins xlconcat/In1]
  connect_bd_net -net axi_intc_0_irq [get_bd_pins irq] [get_bd_pins axi_intc/irq]
  connect_bd_net -net axi_pcie3_axi_aclk [get_bd_pins s_axi_aclk] [get_bd_pins axi_intc/s_axi_aclk]
  connect_bd_net -net axi_pcie3_axi_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_intc/s_axi_aresetn]
  connect_bd_net -net memory_dma_DMA_INT_REQ [get_bd_pins In0] [get_bd_pins xlconcat/In0]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_intc/intr] [get_bd_pins xlconcat/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: axi_lite
proc create_hier_cell_axi_lite { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_axi_lite() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DMA_REGS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DSP_REGS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_INTC_REGS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_PCIE

  # Create pins
  create_bd_pin -dir I -type clk PCIE_ACLK
  create_bd_pin -dir I -type rst PCIE_ARESETN
  create_bd_pin -dir I -type clk REG_CLK
  create_bd_pin -dir I -type rst REG_RESETN

  # Create instance: axi_lite_interconnect, and set properties
  set axi_lite_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_lite_interconnect ]
  set_property -dict [ list \
CONFIG.M00_HAS_REGSLICE {4} \
CONFIG.M01_HAS_REGSLICE {4} \
CONFIG.M02_HAS_REGSLICE {4} \
CONFIG.NUM_MI {3} \
CONFIG.S00_HAS_REGSLICE {3} \
 ] $axi_lite_interconnect

  # Create instance: axi_register_slice_0, and set properties
  set axi_register_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_0 ]
  set_property -dict [ list \
CONFIG.REG_AR {1} \
CONFIG.REG_AW {1} \
CONFIG.REG_B {1} \
 ] $axi_register_slice_0

  # Create instance: axi_register_slice_1, and set properties
  set axi_register_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_1 ]
  set_property -dict [ list \
CONFIG.REG_AR {7} \
CONFIG.REG_AW {7} \
CONFIG.REG_B {7} \
 ] $axi_register_slice_1

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M_INTC_REGS] [get_bd_intf_pins axi_lite_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net S_PCIE_1 [get_bd_intf_pins S_PCIE] [get_bd_intf_pins axi_register_slice_0/S_AXI]
  connect_bd_intf_net -intf_net axi_lite_interconnect_M00_AXI [get_bd_intf_pins axi_lite_interconnect/M00_AXI] [get_bd_intf_pins axi_register_slice_1/S_AXI]
  connect_bd_intf_net -intf_net axi_lite_interconnect_M02_AXI [get_bd_intf_pins M_DMA_REGS] [get_bd_intf_pins axi_lite_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_0_M_AXI [get_bd_intf_pins axi_lite_interconnect/S00_AXI] [get_bd_intf_pins axi_register_slice_0/M_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_1_M_AXI [get_bd_intf_pins M_DSP_REGS] [get_bd_intf_pins axi_register_slice_1/M_AXI]

  # Create port connections
  connect_bd_net -net DSP_CLK_1 [get_bd_pins REG_CLK] [get_bd_pins axi_lite_interconnect/M00_ACLK] [get_bd_pins axi_register_slice_1/aclk]
  connect_bd_net -net DSP_RESETN_1 [get_bd_pins REG_RESETN] [get_bd_pins axi_lite_interconnect/M00_ARESETN] [get_bd_pins axi_register_slice_1/aresetn]
  connect_bd_net -net axi_pcie3_axi_aclk [get_bd_pins PCIE_ACLK] [get_bd_pins axi_lite_interconnect/ACLK] [get_bd_pins axi_lite_interconnect/M01_ACLK] [get_bd_pins axi_lite_interconnect/M02_ACLK] [get_bd_pins axi_lite_interconnect/S00_ACLK] [get_bd_pins axi_register_slice_0/aclk]
  connect_bd_net -net axi_pcie3_axi_aresetn [get_bd_pins PCIE_ARESETN] [get_bd_pins axi_lite_interconnect/ARESETN] [get_bd_pins axi_lite_interconnect/M01_ARESETN] [get_bd_pins axi_lite_interconnect/M02_ARESETN] [get_bd_pins axi_lite_interconnect/S00_ARESETN] [get_bd_pins axi_register_slice_0/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set C0_DDR3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 C0_DDR3 ]
  set C1_DDR3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 C1_DDR3 ]
  set CLK533MHZ0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK533MHZ0 ]
  set CLK533MHZ1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK533MHZ1 ]
  set M_DSP_REGS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_DSP_REGS ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {16} \
CONFIG.DATA_WIDTH {32} \
CONFIG.FREQ_HZ {125000000} \
CONFIG.HAS_BRESP {0} \
CONFIG.HAS_PROT {0} \
CONFIG.HAS_RRESP {0} \
CONFIG.HAS_WSTRB {0} \
CONFIG.NUM_READ_OUTSTANDING {7} \
CONFIG.NUM_WRITE_OUTSTANDING {7} \
CONFIG.PROTOCOL {AXI4LITE} \
 ] $M_DSP_REGS
  set S_DSP_DRAM0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DSP_DRAM0 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {48} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {64} \
CONFIG.FREQ_HZ {250000000} \
CONFIG.HAS_BRESP {0} \
CONFIG.HAS_BURST {1} \
CONFIG.HAS_CACHE {1} \
CONFIG.HAS_LOCK {0} \
CONFIG.HAS_PROT {0} \
CONFIG.HAS_QOS {0} \
CONFIG.HAS_REGION {0} \
CONFIG.HAS_RRESP {0} \
CONFIG.HAS_WSTRB {0} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {256} \
CONFIG.NUM_READ_OUTSTANDING {7} \
CONFIG.NUM_READ_THREADS {1} \
CONFIG.NUM_WRITE_OUTSTANDING {7} \
CONFIG.NUM_WRITE_THREADS {1} \
CONFIG.PROTOCOL {AXI4} \
CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
CONFIG.RUSER_BITS_PER_BYTE {0} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {0} \
CONFIG.WUSER_BITS_PER_BYTE {0} \
CONFIG.WUSER_WIDTH {0} \
 ] $S_DSP_DRAM0
  set S_DSP_DRAM1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_DSP_DRAM1 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {48} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {64} \
CONFIG.FREQ_HZ {250000000} \
CONFIG.HAS_BRESP {0} \
CONFIG.HAS_BURST {0} \
CONFIG.HAS_CACHE {0} \
CONFIG.HAS_LOCK {0} \
CONFIG.HAS_PROT {0} \
CONFIG.HAS_QOS {0} \
CONFIG.HAS_REGION {0} \
CONFIG.HAS_RRESP {0} \
CONFIG.HAS_WSTRB {0} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {1} \
CONFIG.NUM_READ_OUTSTANDING {7} \
CONFIG.NUM_READ_THREADS {1} \
CONFIG.NUM_WRITE_OUTSTANDING {7} \
CONFIG.NUM_WRITE_THREADS {1} \
CONFIG.PROTOCOL {AXI4LITE} \
CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
CONFIG.RUSER_BITS_PER_BYTE {0} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {0} \
CONFIG.WUSER_BITS_PER_BYTE {0} \
CONFIG.WUSER_WIDTH {0} \
 ] $S_DSP_DRAM1
  set pcie_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt ]

  # Create ports
  set CLK200MHZ [ create_bd_port -dir I -type clk CLK200MHZ ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_RESET {CLK200MHZ_RSTN} \
CONFIG.FREQ_HZ {200000000} \
 ] $CLK200MHZ
  set DSP_CLK [ create_bd_port -dir I -type clk DSP_CLK ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_BUSIF {S_DSP_DRAM0:S_DSP_DRAM1} \
CONFIG.ASSOCIATED_RESET {DSP_RESETN} \
CONFIG.FREQ_HZ {250000000} \
 ] $DSP_CLK
  set DSP_RESETN [ create_bd_port -dir I -type rst DSP_RESETN ]
  set FCLKA [ create_bd_port -dir I -type clk FCLKA ]
  set_property -dict [ list \
CONFIG.CLK_DOMAIN {design_1_clk_wiz_0_0_clk_out1} \
CONFIG.PHASE {0.0} \
 ] $FCLKA
  set INTR [ create_bd_port -dir I -from 30 -to 0 -type intr INTR ]
  set_property -dict [ list \
CONFIG.PortWidth {31} \
CONFIG.SENSITIVITY {EDGE_RISING} \
 ] $INTR
  set REG_CLK [ create_bd_port -dir I -type clk REG_CLK ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_BUSIF {M_DSP_REGS} \
CONFIG.ASSOCIATED_RESET {REG_RESETN} \
CONFIG.FREQ_HZ {125000000} \
 ] $REG_CLK
  set REG_RESETN [ create_bd_port -dir I -type rst REG_RESETN ]
  set nCOLDRST [ create_bd_port -dir I -type rst nCOLDRST ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_LOW} \
 ] $nCOLDRST

  # Create instance: axi_lite
  create_hier_cell_axi_lite [current_bd_instance .] axi_lite

  # Create instance: axi_pcie3_bridge, and set properties
  set axi_pcie3_bridge [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie3:3.0 axi_pcie3_bridge ]
  set_property -dict [ list \
CONFIG.axi_addr_width {48} \
CONFIG.axi_data_width {256_bit} \
CONFIG.axisten_freq {250} \
CONFIG.en_axi_slave_if {true} \
CONFIG.pcie_blk_locn {X0Y1} \
CONFIG.pciebar2axibar_0 {0x0000000000010000} \
CONFIG.pciebar2axibar_1 {0x0000000000000000} \
CONFIG.pciebar2axibar_2 {0x0000000000020000} \
CONFIG.pf0_Use_Class_Code_Lookup_Assistant {false} \
CONFIG.pf0_bar0_64bit {true} \
CONFIG.pf0_bar0_scale {Kilobytes} \
CONFIG.pf0_bar0_size {64} \
CONFIG.pf0_bar1_enabled {false} \
CONFIG.pf0_bar2_64bit {true} \
CONFIG.pf0_bar2_enabled {true} \
CONFIG.pf0_bar2_prefetchable {false} \
CONFIG.pf0_bar2_scale {Kilobytes} \
CONFIG.pf0_bar2_size {64} \
CONFIG.pf0_class_code {118000} \
CONFIG.pf0_class_code_base {11} \
CONFIG.pf0_class_code_sub {80} \
CONFIG.pf0_device_id {7038} \
CONFIG.pf0_interrupt_pin {NONE} \
CONFIG.pf0_msi_enabled {true} \
CONFIG.pf0_msix_cap_pba_bir {BAR_1:0} \
CONFIG.pf0_msix_cap_table_bir {BAR_1:0} \
CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
CONFIG.pl_link_cap_max_link_width {X8} \
 ] $axi_pcie3_bridge

  # Create instance: interrupts
  create_hier_cell_interrupts [current_bd_instance .] interrupts

  # Create instance: memory_dma
  create_hier_cell_memory_dma [current_bd_instance .] memory_dma

  # Create interface connections
  connect_bd_intf_net -intf_net C0_SYS_CLK_1 [get_bd_intf_ports CLK533MHZ1] [get_bd_intf_pins memory_dma/DRAM0_CLK]
  connect_bd_intf_net -intf_net C1_SYS_CLK_1 [get_bd_intf_ports CLK533MHZ0] [get_bd_intf_pins memory_dma/DRAM1_CLK]
  connect_bd_intf_net -intf_net DSP_AXI_DRAM1_1 [get_bd_intf_ports S_DSP_DRAM1] [get_bd_intf_pins memory_dma/S_DSP_DRAM1]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_ports S_DSP_DRAM0] [get_bd_intf_pins memory_dma/S_DSP_DRAM0]
  connect_bd_intf_net -intf_net axi_crossbar_0_M01_AXI [get_bd_intf_pins axi_pcie3_bridge/S_AXI] [get_bd_intf_pins memory_dma/M_DMA_W]
  connect_bd_intf_net -intf_net axi_lite_M03_AXI [get_bd_intf_pins axi_lite/M_INTC_REGS] [get_bd_intf_pins interrupts/S_INTC_REGS]
  connect_bd_intf_net -intf_net axi_lite_M_DMA [get_bd_intf_pins axi_lite/M_DMA_REGS] [get_bd_intf_pins memory_dma/S_DMA_REGS]
  connect_bd_intf_net -intf_net axi_lite_M_DSP_REGS [get_bd_intf_ports M_DSP_REGS] [get_bd_intf_pins axi_lite/M_DSP_REGS]
  connect_bd_intf_net -intf_net axi_pcie3_bridge_M_AXI [get_bd_intf_pins axi_lite/S_PCIE] [get_bd_intf_pins axi_pcie3_bridge/M_AXI]
  connect_bd_intf_net -intf_net axi_pcie3_pcie_7x_mgt [get_bd_intf_ports pcie_mgt] [get_bd_intf_pins axi_pcie3_bridge/pcie_7x_mgt]
  connect_bd_intf_net -intf_net mig_7series_0_C0_DDR3 [get_bd_intf_ports C0_DDR3] [get_bd_intf_pins memory_dma/C0_DDR3]
  connect_bd_intf_net -intf_net mig_7series_0_C1_DDR3 [get_bd_intf_ports C1_DDR3] [get_bd_intf_pins memory_dma/C1_DDR3]

  # Create port connections
  connect_bd_net -net DSPCLK_1 [get_bd_ports DSP_CLK] [get_bd_pins memory_dma/DSP_CLK]
  connect_bd_net -net DSPRSTN_1 [get_bd_ports DSP_RESETN] [get_bd_pins memory_dma/DSP_RESETN]
  connect_bd_net -net INTR_1 [get_bd_ports INTR] [get_bd_pins interrupts/In1]
  connect_bd_net -net REG_CLK_1 [get_bd_ports REG_CLK] [get_bd_pins axi_lite/REG_CLK]
  connect_bd_net -net REG_RESETN_1 [get_bd_ports REG_RESETN] [get_bd_pins axi_lite/REG_RESETN]
  connect_bd_net -net axi_intc_0_irq [get_bd_pins axi_pcie3_bridge/intx_msi_request] [get_bd_pins interrupts/irq]
  connect_bd_net -net axi_pcie3_axi_aclk [get_bd_pins axi_lite/PCIE_ACLK] [get_bd_pins axi_pcie3_bridge/axi_aclk] [get_bd_pins interrupts/s_axi_aclk] [get_bd_pins memory_dma/DMA_ACLK]
  connect_bd_net -net axi_pcie3_axi_aresetn [get_bd_pins axi_lite/PCIE_ARESETN] [get_bd_pins axi_pcie3_bridge/axi_aresetn] [get_bd_pins interrupts/s_axi_aresetn] [get_bd_pins memory_dma/DMA_ARESETN]
  connect_bd_net -net clk_in1_1 [get_bd_ports CLK200MHZ] [get_bd_pins memory_dma/CLK200MHZ]
  connect_bd_net -net memory_dma_DMA_INT_REQ [get_bd_pins interrupts/In0] [get_bd_pins memory_dma/DMA_INT_REQ]
  connect_bd_net -net nCOLDRST_1 [get_bd_ports nCOLDRST] [get_bd_pins axi_pcie3_bridge/sys_rst_n] [get_bd_pins memory_dma/SYS_RSTN]
  connect_bd_net -net refclk_1 [get_bd_ports FCLKA] [get_bd_pins axi_pcie3_bridge/refclk]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x00010000 [get_bd_addr_spaces axi_pcie3_bridge/M_AXI] [get_bd_addr_segs M_DSP_REGS/Reg] SEG_M_DSP_REGS_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x00020000 [get_bd_addr_spaces axi_pcie3_bridge/M_AXI] [get_bd_addr_segs memory_dma/axi_cdma_0/S_AXI_LITE/Reg] SEG_axi_cdma_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x00021000 [get_bd_addr_spaces axi_pcie3_bridge/M_AXI] [get_bd_addr_segs interrupts/axi_intc/S_AXI/Reg] SEG_axi_intc_Reg
  create_bd_addr_seg -range 0x800000000000 -offset 0x00000000 [get_bd_addr_spaces memory_dma/axi_cdma_0/Data] [get_bd_addr_segs axi_pcie3_bridge/S_AXI/BAR0] SEG_axi_pcie3_bridge_BAR0
  create_bd_addr_seg -range 0x80000000 -offset 0x800000000000 [get_bd_addr_spaces memory_dma/axi_cdma_0/Data] [get_bd_addr_segs memory_dma/memory/mig_7series_0/c0_memmap/c0_memaddr] SEG_mig_7series_0_c0_memaddr
  create_bd_addr_seg -range 0x08000000 -offset 0x800080000000 [get_bd_addr_spaces memory_dma/axi_cdma_0/Data] [get_bd_addr_segs memory_dma/memory/mig_7series_0/c1_memmap/c1_memaddr] SEG_mig_7series_0_c1_memaddr
  create_bd_addr_seg -range 0x80000000 -offset 0x800000000000 [get_bd_addr_spaces S_DSP_DRAM0] [get_bd_addr_segs memory_dma/memory/mig_7series_0/c0_memmap/c0_memaddr] SEG_mig_7series_0_c0_memaddr
  create_bd_addr_seg -range 0x08000000 -offset 0x800080000000 [get_bd_addr_spaces S_DSP_DRAM1] [get_bd_addr_segs memory_dma/memory/mig_7series_0/c1_memmap/c1_memaddr] SEG_mig_7series_0_c1_memaddr


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


