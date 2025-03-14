# Environment can be PROD, SPARE, EMPTY
ENV=EMPTY

readonly -A valid_hosts=( ['l-c31-3']="PROD" ['l-mbf-spare']="SPARE" )


#FUNCTIONS##########################################################

# Creation of symbolic link
# SYNTAX create_link src_path dst_link
fn_create_link_file (){
   src_path=$1
   dst_path=$2
   echo "TASK: create symlink from $src_path to $dst_path"
   if [ -f "$src_path" ]; then
      ln -sf "$src_path" "$dst_path"
   else
      echo " ERROR no source file found !"
      exit 1
   fi
}

# Start rsync
fn_sync_files (){
   src_path=$1
   dst_path=$2
   echo "TASK: copy file from $src_path to $dst_path ..."
   if [ -d "$src_path" ] && [ -d "$dst_path" ]; then
      /usr/bin/rsync -acvh "$src_path" "$dst_path"
   else
      echo " ERROR: source or destination folder not found !"
      exit 1
   fi
}


#BEGIN###############################################################

echo "########################################"
echo "START ESRF MBF CONFIG ON $HOSTNAME"
echo ""
# Check if the current host is allow to run this script.
for host in "${!valid_hosts[@]}"; do
   if [[ "$host" == "$HOSTNAME" ]]; then
      ENV="${valid_hosts["$host"]}"
      echo "HOST CHECK: $HOSTNAME allow to execute install script in $ENV environment"
      break
   fi
done
if [[ "$ENV" == "EMPTY" ]]; then
   echo " ERROR: computer not allow to execute this script !"
   exit 1
fi

# Symlink creation
fn_create_link_file /home/esrf/dserver/mbf/sites/ESRF/CONFIG /home/esrf/dserver/mbf/CONFIG
fn_create_link_file /home/esrf/dserver/mbf/sites/ESRF/scripts/.bashrc /home/esrf/dserver/
fn_create_link_file /home/esrf/dserver/mbf/sites/ESRF/scripts/.mbf-env /home/esrf/dserver/
fn_create_link_file /home/esrf/dserver/mbf/sites/ESRF/scripts/amc525-firmware.sh /home/esrf/dserver/script/
fn_create_link_file /home/esrf/dserver/mbf/sites/ESRF/scripts/mbf-backup.sh /home/esrf/dserver/script/

# Copy MBF file to host
fn_sync_files /home/dserver/mbf/sites/ESRF/INSTALL/common/ /home/esrf/dserver/
fn_sync_files /home/dserver/mbf/sites/ESRF/INSTALL/$HOSTNAME/ /home/esrf/dserver/



