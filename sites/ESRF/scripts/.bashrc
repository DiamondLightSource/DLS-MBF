# This line was intended to solve an issue using backspace with vim
# but it creates much more problems
#[[ $- == *i* ]] && stty erase '^?'

. ./.mbf-env

padding='                                        '
PADDED_HOSTNAME=$(printf "%s %s" "$HOSTNAME" "${padding:${#HOSTNAME}}")

if [ -n "$WELCOME_MESSAGE" ]; then
	return
fi

export WELCOME_MESSAGE="done"

echo ""
echo ""
echo "  ╔══════════════════════════════════════════════════════════════════════════╗"
echo "  ║                                                                          ║"
echo "  ║                     WELCOME on $PADDED_HOSTNAME ║"
echo "  ║                   ┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉                             ║"
echo "  ║                                                                          ║"
echo "  ║  This is a multi-bunch feedback (MBF) crate.                             ║"
echo "  ║                                                                          ║"
echo "  ║  This server should ONLY host multi-bunch feedback servers.              ║"
echo "  ║  Be aware that it runs some EPICS devices.                               ║"
echo "  ║                                                                          ║"
echo "  ║  For more information please consult:                                    ║"
echo "  ║  http://wikiserv.esrf.fr/asd-diag/index.php/Bunch-by-Bunch_Feedback_DLS  ║"
echo "  ║                                                                          ║"
echo "  ║                                                                          ║"
echo "  ╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo ""
