package MBF;

import fr.esrf.tangoatk.core.AttributeList;
import fr.esrf.tangoatk.widget.jdraw.SynopticProgressListener;
import fr.esrf.tangoatk.widget.jdraw.TangoSynopticHandler;
import fr.esrf.tangoatk.widget.util.ATKDiagnostic;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.ErrorHistory;
import fr.esrf.tangoatk.widget.util.Splash;
import fr.esrf.tangoatk.widget.util.jdraw.JDMouseAdapter;
import fr.esrf.tangoatk.widget.util.jdraw.JDMouseEvent;
import fr.esrf.tangoatk.widget.util.jdraw.JDMouseListener;
import fr.esrf.tangoatk.widget.util.jdraw.JDObject;
import fr.esrf.tangoatk.widget.util.jdraw.JDSwingObject;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Vector;
import javax.swing.JButton;
import javax.swing.JOptionPane;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author pons
 */
public class MainPanel extends javax.swing.JFrame implements SynopticProgressListener {

  final static String APP_RELEASE = "1.3";

  static int NB_BUCKET;
  static String mfdbkHDevName;
  static String mfdbkVDevName;
  static String mfdbkHEpicsDevName;
  static String mfdbkVEpicsDevName;
  static String mfdbkGEpicsDevName;
  
  private AttributeList attList;
  public static ErrorHistory errWin;
  private boolean runningFromShell;

  private Splash splash; 
  

  /**
   * Creates new form MainPanel
   */
  public MainPanel(boolean runningFromShell,
          String hName,String vName,
          String epicsHNane,String epicsVNane,String epicsGNane,
          int nbBucket) {
    
    NB_BUCKET = nbBucket;
    mfdbkHDevName = hName;
    mfdbkVDevName = vName;
    mfdbkHEpicsDevName = epicsHNane;
    mfdbkVEpicsDevName = epicsVNane;
    mfdbkGEpicsDevName = epicsGNane;    
    
    this.runningFromShell = runningFromShell;
    
    // Handle windowClosing (Close from the system menu)
    addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
        exitForm();
      }
    });

    initComponents();

    errWin = new ErrorHistory();
    
    attList = new AttributeList();
    attList.addErrorListener(errWin);

    // Splash window
    
    splash = new Splash();
    splash.setTitle("Multibunch Feedback " + APP_RELEASE);
    splash.setCopyright("(c) ESRF & DLS 2018");
    splash.setMaxProgress(100);
    splash.progress(0);
    
    
    ConfigFilePanel hCfgPanel = new ConfigFilePanel("Horizontal Config File");
    hCfgPanel.setModel(mfdbkHDevName, errWin);
    upPanel.add(hCfgPanel);

    ConfigFilePanel vCfgPanel = new ConfigFilePanel("Vertical Config File");
    vCfgPanel.setModel(mfdbkVDevName, errWin);
    upPanel.add(vCfgPanel);
    
    // Loads the synoptic
    
    theSynoptic.setProgressListener(this);
    
    InputStream jdFileInStream = this.getClass().getResourceAsStream("/MBF/mbf.jdw");

    if (jdFileInStream == null) {
      splash.setVisible(false);
      JOptionPane.showMessageDialog(
              null, "Failed to get the inputStream for the synoptic file resource : mbf.jdw \n\n",
              "Resource error",
              JOptionPane.ERROR_MESSAGE);
      exitForm();
    }

    InputStreamReader inStrReader = new InputStreamReader(jdFileInStream);
    try {
      theSynoptic.setErrorHistoryWindow(errWin);
      theSynoptic.setToolTipMode(TangoSynopticHandler.TOOL_TIP_NAME);
      theSynoptic.setAutoZoom(true);
      theSynoptic.addMetaName("mfdbkHDevName",mfdbkHDevName);
      theSynoptic.addMetaName("mfdbkVDevName",mfdbkVDevName);
      theSynoptic.addMetaName("mfdbkHEpicsDevName",mfdbkHEpicsDevName);
      theSynoptic.addMetaName("mfdbkVEpicsDevName",mfdbkVEpicsDevName);
      theSynoptic.addMetaName("mfdbkGEpicsDevName",mfdbkGEpicsDevName);
      theSynoptic.loadSynopticFromStream(inStrReader);      
    } catch (IOException ioex) {
      splash.setVisible(false);
      JOptionPane.showMessageDialog(
              null, "Cannot find load the synoptic input stream reader.\n" + " Application will abort ...\n" + ioex,
              "Resource access failed",
              JOptionPane.ERROR_MESSAGE);
      exitForm();
    }
    
    JDMouseAdapter adcPanelHShower = new JDMouseAdapter() {
      public void mouseClicked(JDMouseEvent e) {
        Utils.showhADCPanel();
      }      
    };

    JDMouseAdapter adcPanelVShower = new JDMouseAdapter() {
      public void mouseClicked(JDMouseEvent e) {
        Utils.showvADCPanel();
      }      
    };
    
    JDMouseAdapter dacPanelHShower = new JDMouseAdapter() {
      public void mouseClicked(JDMouseEvent e) {
        Utils.showhDACPanel();
      }      
    };

    JDMouseAdapter dacPanelVShower = new JDMouseAdapter() {
      public void mouseClicked(JDMouseEvent e) {
        Utils.showvDACPanel();
      }      
    };
    
    JDMouseAdapter firPanelHShower = new JDMouseAdapter() {
      public void mouseClicked(JDMouseEvent e) {
        Utils.showhFIRPanel();        
      }      
    };

    JDMouseAdapter firPanelVShower = new JDMouseAdapter() {
      public void mouseClicked(JDMouseEvent e) {
        Utils.showvFIRPanel();        
      }      
    };
    
    addMouseListener(mfdbkHEpicsDevName+"/ADC_LOOPBACK_S",adcPanelHShower);
    addMouseListener(mfdbkHEpicsDevName+"/ADC_INP_OVF",adcPanelHShower);
    addMouseListener(mfdbkHEpicsDevName+"/ADC_FIR_OVF",adcPanelHShower);

    addMouseListener(mfdbkVEpicsDevName+"/ADC_LOOPBACK_S",adcPanelVShower);
    addMouseListener(mfdbkVEpicsDevName+"/ADC_INP_OVF",adcPanelVShower);
    addMouseListener(mfdbkVEpicsDevName+"/ADC_FIR_OVF",adcPanelVShower);

    addMouseListener(mfdbkHEpicsDevName+"/DAC_BUN_OVF",dacPanelHShower);
    addMouseListener(mfdbkHEpicsDevName+"/DAC_MUX_OVF",dacPanelHShower);
    addMouseListener(mfdbkHEpicsDevName+"/DAC_FIR_OVF",dacPanelHShower);
    addMouseListener(mfdbkHEpicsDevName+"/DAC_ENABLE_S",dacPanelHShower);
    
    addMouseListener(mfdbkVEpicsDevName+"/DAC_BUN_OVF",dacPanelVShower);
    addMouseListener(mfdbkVEpicsDevName+"/DAC_MUX_OVF",dacPanelVShower);
    addMouseListener(mfdbkVEpicsDevName+"/DAC_FIR_OVF",dacPanelVShower);
    addMouseListener(mfdbkVEpicsDevName+"/DAC_ENABLE_S",dacPanelVShower);
                    
    addMouseListener(mfdbkHEpicsDevName+"/FIR_OVF",firPanelHShower);
    addMouseListener(mfdbkVEpicsDevName+"/FIR_OVF",firPanelVShower);
            
    JDSwingObject btnh = (JDSwingObject)theSynoptic.getObjectsByName("HorizontalTuneChart",false).get(0);
    ((JButton) btnh.getComponent()).addActionListener(
      new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
          Utils.showHDetPanel();
        }
      }
    );
    
    JDSwingObject btnv = (JDSwingObject)theSynoptic.getObjectsByName("VerticalTuneChart",false).get(0);
    ((JButton) btnv.getComponent()).addActionListener(
      new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
          Utils.showVDetPanel();
        }
      }
    );
    
    
    attList.setRefreshInterval(1000);
    attList.startRefresher();
    
    splash.setVisible(false);
    setTitle("Multibunch Feedback " + APP_RELEASE);
    ATKGraphicsUtils.centerFrameOnScreen(this);
    setVisible(true);
    
    
  }
  
  public void addMouseListener(String objName,JDMouseListener ml) {

    Vector v = theSynoptic.getObjectsByName(objName, false);
    
    if(v.size()!=1) {
      JOptionPane.showMessageDialog(null,"Cannot find object " + objName,"Error",JOptionPane.ERROR_MESSAGE);
    } else {
      JDObject obj = (JDObject)v.get(0);
      obj.addMouseListener(ml);      
    }
    
  }
  
  public void progress(double p) {
    splash.progress((int)(p*100.0));
  }

  /**
   * Exit the application
   */
  public void exitForm() {

    if (runningFromShell) {

      System.exit(0);

    } else {

      clearModel();
      setVisible(false);
      dispose();

    }

  }

  /**
   * Clear all connections to attributes and commands
   */
  private void clearModel() {

    theSynoptic.clearSynopticFileModel();

  }
  
  
  /**
   * This method is called from within the constructor to initialize the form.
   * WARNING: Do NOT modify this code. The content of this method is always
   * regenerated by the Form Editor.
   */
  @SuppressWarnings("unchecked")
  // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
  private void initComponents() {

    centerPanel = new javax.swing.JPanel();
    theSynoptic = new fr.esrf.tangoatk.widget.jdraw.SynopticFileViewer();
    upPanel = new javax.swing.JPanel();
    jMenuBar1 = new javax.swing.JMenuBar();
    jFileMenu = new javax.swing.JMenu();
    jExitMenuItem = new javax.swing.JMenuItem();
    jViewMenu = new javax.swing.JMenu();
    hMenu = new javax.swing.JMenu();
    sequencerHMenuItem = new javax.swing.JMenuItem();
    hDetMenuItem = new javax.swing.JMenuItem();
    vMenu = new javax.swing.JMenu();
    sequencerVMenuItem = new javax.swing.JMenuItem();
    vDetMenuItem = new javax.swing.JMenuItem();
    triggerMenuItem = new javax.swing.JMenuItem();
    delayMenuItem = new javax.swing.JMenuItem();
    memoryMenuItem = new javax.swing.JMenuItem();
    jSeparator1 = new javax.swing.JPopupMenu.Separator();
    viewErrorMenuItem = new javax.swing.JMenuItem();
    viewDiagMenuItem = new javax.swing.JMenuItem();

    setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);

    centerPanel.setLayout(new java.awt.BorderLayout());
    centerPanel.add(theSynoptic, java.awt.BorderLayout.CENTER);

    getContentPane().add(centerPanel, java.awt.BorderLayout.CENTER);

    upPanel.setLayout(new java.awt.GridLayout(1, 2));
    getContentPane().add(upPanel, java.awt.BorderLayout.NORTH);

    jFileMenu.setText("File");

    jExitMenuItem.setText("Exit");
    jExitMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        jExitMenuItemActionPerformed(evt);
      }
    });
    jFileMenu.add(jExitMenuItem);

    jMenuBar1.add(jFileMenu);

    jViewMenu.setText("View");

    hMenu.setText("Horizontal");

    sequencerHMenuItem.setText("Sequencer...");
    sequencerHMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        sequencerHMenuItemActionPerformed(evt);
      }
    });
    hMenu.add(sequencerHMenuItem);

    hDetMenuItem.setText("Detectors...");
    hDetMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        hDetMenuItemActionPerformed(evt);
      }
    });
    hMenu.add(hDetMenuItem);

    jViewMenu.add(hMenu);

    vMenu.setText("Vertical");

    sequencerVMenuItem.setText("Sequencer...");
    sequencerVMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        sequencerVMenuItemActionPerformed(evt);
      }
    });
    vMenu.add(sequencerVMenuItem);

    vDetMenuItem.setText("Detectors...");
    vDetMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        vDetMenuItemActionPerformed(evt);
      }
    });
    vMenu.add(vDetMenuItem);

    jViewMenu.add(vMenu);

    triggerMenuItem.setText("Triggers...");
    triggerMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        triggerMenuItemActionPerformed(evt);
      }
    });
    jViewMenu.add(triggerMenuItem);

    delayMenuItem.setText("Delays...");
    delayMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        delayMenuItemActionPerformed(evt);
      }
    });
    jViewMenu.add(delayMenuItem);

    memoryMenuItem.setText("Memory...");
    memoryMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        memoryMenuItemActionPerformed(evt);
      }
    });
    jViewMenu.add(memoryMenuItem);
    jViewMenu.add(jSeparator1);

    viewErrorMenuItem.setText("Errors ...");
    viewErrorMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        viewErrorMenuItemActionPerformed(evt);
      }
    });
    jViewMenu.add(viewErrorMenuItem);

    viewDiagMenuItem.setText("Diagnostics ...");
    viewDiagMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        viewDiagMenuItemActionPerformed(evt);
      }
    });
    jViewMenu.add(viewDiagMenuItem);

    jMenuBar1.add(jViewMenu);

    setJMenuBar(jMenuBar1);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void viewErrorMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_viewErrorMenuItemActionPerformed
    ATKGraphicsUtils.centerFrameOnScreen(errWin);
    errWin.setVisible(true);
  }//GEN-LAST:event_viewErrorMenuItemActionPerformed

  private void viewDiagMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_viewDiagMenuItemActionPerformed
    ATKDiagnostic.showDiagnostic();
  }//GEN-LAST:event_viewDiagMenuItemActionPerformed

  private void jExitMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jExitMenuItemActionPerformed
    exitForm();
  }//GEN-LAST:event_jExitMenuItemActionPerformed

  private void sequencerHMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sequencerHMenuItemActionPerformed
    Utils.showhSEQPanel();
  }//GEN-LAST:event_sequencerHMenuItemActionPerformed

  private void sequencerVMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sequencerVMenuItemActionPerformed
    Utils.showvSEQPanel();
  }//GEN-LAST:event_sequencerVMenuItemActionPerformed

  private void triggerMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_triggerMenuItemActionPerformed
    Utils.showTrigger();
  }//GEN-LAST:event_triggerMenuItemActionPerformed

  private void delayMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_delayMenuItemActionPerformed
    Utils.showDelayPanel();
  }//GEN-LAST:event_delayMenuItemActionPerformed

  private void memoryMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_memoryMenuItemActionPerformed
    Utils.showMemoryPanel();
  }//GEN-LAST:event_memoryMenuItemActionPerformed

  private void hDetMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_hDetMenuItemActionPerformed
    Utils.showhDETPanel();
  }//GEN-LAST:event_hDetMenuItemActionPerformed

  private void vDetMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_vDetMenuItemActionPerformed
    Utils.showvDETPanel();
  }//GEN-LAST:event_vDetMenuItemActionPerformed

  /**
   * @param args the command line arguments
   */
  public static void main(String args[]) {
    
    if( args.length != 6 ) {
      
      System.out.println("Usage: jmbf devH devV bridgeH bridgeV bridgeG bucketNb");
      System.out.println("  devH: Name of the horizontal MBFControl device");
      System.out.println("  devV: Name of the vertical MBFControl device");
      System.out.println("  bridgeH: Name of the epics gateway horizontal device");
      System.out.println("  bridgeV: Name of the epics gateway vertical device");
      System.out.println("  bridgeG: Name of the epics gateway global device");
      System.out.println("  bucketNb: Bucket number of the storage ring");
      System.exit(0);
      
    }

    /* Create and display the form */
    try {
      int nb = Integer.parseInt(args[5]);    
      new MainPanel(true,args[0],args[1],args[2],args[3],args[4],nb).setVisible(true);
    } catch( NumberFormatException e) {
      System.out.println("Error: bucketNb " + e.getMessage());
    }
        
  }

  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel centerPanel;
  private javax.swing.JMenuItem delayMenuItem;
  private javax.swing.JMenuItem hDetMenuItem;
  private javax.swing.JMenu hMenu;
  private javax.swing.JMenuItem jExitMenuItem;
  private javax.swing.JMenu jFileMenu;
  private javax.swing.JMenuBar jMenuBar1;
  private javax.swing.JPopupMenu.Separator jSeparator1;
  private javax.swing.JMenu jViewMenu;
  private javax.swing.JMenuItem memoryMenuItem;
  private javax.swing.JMenuItem sequencerHMenuItem;
  private javax.swing.JMenuItem sequencerVMenuItem;
  private fr.esrf.tangoatk.widget.jdraw.SynopticFileViewer theSynoptic;
  private javax.swing.JMenuItem triggerMenuItem;
  private javax.swing.JPanel upPanel;
  private javax.swing.JMenuItem vDetMenuItem;
  private javax.swing.JMenu vMenu;
  private javax.swing.JMenuItem viewDiagMenuItem;
  private javax.swing.JMenuItem viewErrorMenuItem;
  // End of variables declaration//GEN-END:variables
}
