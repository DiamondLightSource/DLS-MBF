/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package MBF;

import fr.esrf.Tango.DevFailed;
import fr.esrf.TangoApi.DeviceAttribute;
import fr.esrf.TangoApi.DeviceProxy;
import fr.esrf.tangoatk.core.ConnectionException;
import fr.esrf.tangoatk.core.DeviceFactory;
import fr.esrf.tangoatk.widget.util.ErrorPane;
import java.awt.Color;
import javax.swing.JComponent;
import javax.swing.JEditorPane;
import static MBF.MainPanel.mfdbkHEpicsDevName;
import static MBF.MainPanel.mfdbkVEpicsDevName;
import static MBF.MainPanel.mfdbkGEpicsDevName;
import static MBF.MainPanel.mfdbkHDevName;
import static MBF.MainPanel.mfdbkVDevName;

public class Utils {
  
  private static ADCSetupPanel hADCPanel = null;
  private static ADCSetupPanel vADCPanel = null;
  private static DACSetupPanel hDACPanel = null;
  private static DACSetupPanel vDACPanel = null;
  private static FIRSetupPanel hFIRPanel = null;
  private static FIRSetupPanel vFIRPanel = null;
  private static SEQSetupPanel hSEQPanel = null;
  private static SEQSetupPanel vSEQPanel = null;
  private static DETSetupPanel hDETPanel = null;
  private static DETSetupPanel vDETPanel = null;
  private static GlobalTriggerPanel trigPanel = null;
  private static TriggerPanel vSEQTrigPanel = null;
  private static TriggerPanel hSEQTrigPanel = null;
  private static TriggerPanel MEMTrigPanel = null;
  private static DelayPanel   delayPanel = null;
  private static MemoryPanel  memoryPanel = null;    
  private static DETWaveformPanel hWaveformPanel = null; 
  private static DETWaveformPanel vWaveformPanel = null; 
  
  
  public static void execCommand(String devName,String cmd) {
    try {
      DeviceAttribute da = new DeviceAttribute(cmd,(int)0);
      DeviceProxy ds = DeviceFactory.getInstance().getDevice(devName);
      ds.write_attribute(da);
    } catch(ConnectionException | DevFailed e1) {
      ErrorPane.showErrorMessage(null, devName, e1);
    }
  }
  
  public static void resetSetpoint(String devName) {
    try {
      DeviceProxy ds = DeviceFactory.getInstance().getDevice(devName);
      ds.command_inout("ResetSetpoint");
    } catch(ConnectionException | DevFailed e1) {
      ErrorPane.showErrorMessage(null, devName, e1);
    }
  }
  
  public static void showhADCPanel() {
     if(hADCPanel==null) hADCPanel = new ADCSetupPanel(mfdbkHEpicsDevName); 
     hADCPanel.setVisible(true);    
  }
  public static void showvADCPanel() {
     if(vADCPanel==null) vADCPanel = new ADCSetupPanel(mfdbkVEpicsDevName); 
     vADCPanel.setVisible(true);    
  }
  public static void showhDACPanel() {
     if(hDACPanel==null) hDACPanel = new DACSetupPanel(mfdbkHEpicsDevName); 
     hDACPanel.setVisible(true);    
  }
  public static void showvDACPanel() {
     if(vDACPanel==null) vDACPanel = new DACSetupPanel(mfdbkVEpicsDevName); 
     vDACPanel.setVisible(true);    
  }
  public static void showhFIRPanel() {
     if(hFIRPanel==null) hFIRPanel = new FIRSetupPanel(mfdbkHEpicsDevName); 
     hFIRPanel.setVisible(true);    
  }
  public static void showvFIRPanel() {
     if(vFIRPanel==null) vFIRPanel = new FIRSetupPanel(mfdbkVEpicsDevName); 
     vFIRPanel.setVisible(true);    
  }
  public static void showhSEQPanel() {
     if(hSEQPanel==null) hSEQPanel = new SEQSetupPanel(mfdbkHEpicsDevName,mfdbkHDevName); 
     hSEQPanel.setVisible(true);    
  }
  public static void showvSEQPanel() {
     if(vSEQPanel==null) vSEQPanel = new SEQSetupPanel(mfdbkVEpicsDevName,mfdbkVDevName); 
     vSEQPanel.setVisible(true);    
  }
  public static void showhDETPanel() {
     if(hDETPanel==null) hDETPanel = new DETSetupPanel(mfdbkHEpicsDevName); 
     hDETPanel.setVisible(true);    
  }
  public static void showvDETPanel() {
     if(vDETPanel==null) vDETPanel = new DETSetupPanel(mfdbkVEpicsDevName); 
     vDETPanel.setVisible(true);    
  }
  public static void showTrigger() {    
    if( trigPanel==null ) trigPanel = new GlobalTriggerPanel();
    trigPanel.setVisible(true);    
  }
  public static void showHSEQTrigger() {
    if( hSEQTrigPanel==null ) hSEQTrigPanel = new TriggerPanel(mfdbkHEpicsDevName,"SEQ");
    hSEQTrigPanel.setVisible(true);      
  }
  public static void showVSEQTrigger() {
    if( vSEQTrigPanel==null ) vSEQTrigPanel = new TriggerPanel(mfdbkVEpicsDevName,"SEQ");
    vSEQTrigPanel.setVisible(true);      
  }
  public static void showHDetPanel() {
    if( hWaveformPanel==null ) hWaveformPanel = new DETWaveformPanel(mfdbkHEpicsDevName,0);
    hWaveformPanel.setVisible(true);      
  }
  public static void showVDetPanel() {
    if( vWaveformPanel==null ) vWaveformPanel = new DETWaveformPanel(mfdbkVEpicsDevName,0);
    vWaveformPanel.setVisible(true);      
  }
  public static void showMEMTrigger() {
    if( MEMTrigPanel==null ) MEMTrigPanel = new TriggerPanel(mfdbkGEpicsDevName,"MEM");
    MEMTrigPanel.setVisible(true);      
  }
  public static void showDelayPanel() {
    if( delayPanel==null ) delayPanel = new DelayPanel();
    delayPanel.setVisible(true);      
  }
  public static void showMemoryPanel() {
    if( memoryPanel==null ) memoryPanel = new MemoryPanel();
    memoryPanel.setVisible(true);      
  }
  
  public static JComponent createLabel(String l,String unit) {
    
    JEditorPane ret = new JEditorPane();
    ret.setContentType("text/html");
    ret.setBorder(null);
    ret.setEditable(false);
    ret.setBackground(Color.LIGHT_GRAY);
    if(unit.length()>0) {
      ret.setText("<html><body><font size=\"2\" color=\"#707070\"><center><b>"+l+"</b></center><center>("+unit+")</center></body></html>");
    } else {
      ret.setText("<html><body><font size=\"2\" color=\"#707070\"><center><b>"+l+"</b></center></body></html>");
    }
    return ret;
    
  }
  
}
