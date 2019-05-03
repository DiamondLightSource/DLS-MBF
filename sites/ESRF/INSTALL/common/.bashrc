export HTTP_PROXY=http://proxy.esrf.fr:3128
export HTTPS_PROXY=https://proxy.esrf.fr:3128

# This line was intended to solve an issue using backspace with vim
# but it creates much more problems
#[[ $- == *i* ]] && stty erase '^?'

. ./.mbf-env

echo ""
echo ""
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "*************************************************************************"
echo "                      WELCOME on $HOSTNAME "
echo "                    -------------------------- "
echo ""
echo " This is a multi-bunch feedback (MBF) crate. "
echo ""
echo " This server should ONLY host multi-bunch feedback servers. "
echo " Be aware that it runs some EPICS device. "
echo ""
echo " For more information please consult: "
echo "   http://wikiserv.esrf.fr/asd-diag/index.php/Bunch-by-Bunch_Feedback_DLS "
echo ""
echo "*************************************************************************"
echo "?????????????????????????????????????????????????????????????????????????"
echo ""
echo ""
