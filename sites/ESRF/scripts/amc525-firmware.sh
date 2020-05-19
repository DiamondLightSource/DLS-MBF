#!/bin/bash

amc_ip_tail=199
amc_ip=192.168.40.$amc_ip_tail
try_max=120
try_wait=3
try_nbr=1

mbf_esrf=/home/dserver/mbf/sites/ESRF
mbf_tools=/home/dserver/mbf/tools

case "$1" in

   startpre)
      if ! lspci -v | grep -q "Xilinx"; then
         echo "Xilinx not found, check AMC525 network availibility..."
         
         #while ! ping -c 1 -W 1 $amc_ip &> /dev/null ; do
         while ! ssh $amc_ip date &> /dev/null ; do
            echo "Unable to join AMC525 at IP $amc_ip (attempt $try_nbr): retring in $try_wait seconds" >&2
            (( try_nbr++ ))
            if [[ $try_nbr -le $try_max ]]; then
               sleep $try_wait
            else
               echo "Unable to join AMC525 at IP $amc_ip: aborting"
               exit 1
            fi
         done
         
         try_nbr=1
         while ! [ -e $mbf_esrf/firmware/amc525_mbf.bit ] ; do
            echo "Firmware: $mbf_esrf/firmware/amc525_mbf.bit not found (attempt $try_nbr): retring in $try_wait seconds" >&2
            (( try_nbr++ ))
            if [[ $try_nbr -le $try_max ]]; then
               sleep $try_wait
            else
               echo "Error, firmware: $mbf_esrf/firmware/amc525_mbf.bit not found: aborting"
               exit 1
            fi
         done
         
         eval $mbf_tools/load_fpga -f "$mbf_esrf/firmware/amc525_mbf.bit" $amc_ip_tail
         sleep 4
         
         #echo "AMC525 access ok, loading Xilinx firmware..."
         #if ; then
         #   eval $mbf_tools/load_fpga -f "$mbf_esrf/firmware/amc525_mbf.bit" $amc_ip_tail
         #   sleep 4
         #else
         #   echo "Error, firmware: $mbf_esrf/firmware/amc525_mbf.bit not found !"
         #   exit 1
         #fi
      fi
   ;;

   start)
      if lspci -v | grep -q "Xilinx"; then
         echo "Xilinx available..."
         lspci -v | grep "Xilinx"
      else
         echo "Unable to load Xilinx !"
         exit 1
      fi
   ;;

esac

exit 0

