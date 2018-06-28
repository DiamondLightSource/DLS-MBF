// This script is used to pass the text of a single PV through to the local
// tune_prefix macro.  This is called from overview.opi

importPackage(Packages.org.csstudio.opibuilder.scriptUtil);
importPackage(Packages.org.csstudio.opibuilder.util);

macroUtil = OPIBuilderMacroUtil();
macroMap = macroUtil.getWidgetMacroMap(widget.getWidgetModel());

macroMap.put('tune_prefix', PVUtil.getString(pvs[0]));
