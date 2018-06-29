/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package CLEANING;

import fr.esrf.Tango.DevFailed;
import fr.esrf.TangoApi.ApiUtil;
import fr.esrf.TangoApi.Database;
import fr.esrf.TangoApi.DbDatum;
import fr.esrf.tangoatk.core.AttributeList;
import fr.esrf.tangoatk.core.AttributeStateEvent;
import fr.esrf.tangoatk.core.CommandList;
import fr.esrf.tangoatk.core.ConnectionException;
import fr.esrf.tangoatk.core.DevStateScalarEvent;
import fr.esrf.tangoatk.core.DeviceFactory;
import fr.esrf.tangoatk.core.EnumScalarEvent;
import fr.esrf.tangoatk.core.ErrorEvent;
import fr.esrf.tangoatk.core.IDevStateScalarListener;
import fr.esrf.tangoatk.core.IDevice;
import fr.esrf.tangoatk.core.IEnumScalarListener;
import fr.esrf.tangoatk.core.attribute.BooleanScalar;
import fr.esrf.tangoatk.core.attribute.DevStateScalar;
import fr.esrf.tangoatk.core.attribute.EnumScalar;
import fr.esrf.tangoatk.core.attribute.NumberScalar;
import fr.esrf.tangoatk.core.attribute.StringScalar;
import fr.esrf.tangoatk.core.command.VoidVoidCommand;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.ErrorHistory;
import fr.esrf.tangoatk.widget.util.ErrorPane;
import fr.esrf.tangoatk.widget.util.ErrorPopup;
import fr.esrf.tangoatk.widget.util.Splash;
import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import jpll.PllFrame;

/**
 *
 * @author pons
 */
public class MainPanel extends javax.swing.JFrame implements IEnumScalarListener,IDevStateScalarListener {
  
  final static String APP_RELEASE = "1.0";
  final static String cleaningDevName = "sr/d-mfdbk/cleaning";
  final static String upp5DevName = "sr/d-scr/c5-up";
  final static String low5DevName = "sr/d-scr/c5-low";
  final static String upp25DevName = "sr/d-scr/c25-up";
  final static String low25DevName = "sr/d-scr/c25-low";
  final static String upp22DevName = "sr/d-scr/c22-up";
  final static String pllDevName = "sr/d-mfdbk/pll";
    
  private AttributeList attList;
  private CommandList cmdList;
  public static ErrorHistory errWin;
  private boolean runningFromShell;
  
  private ScraperPanel upp5Panel;
  private ScraperPanel low5Panel;
  private ScraperPanel upp25Panel;
  private ScraperPanel low25Panel;
  private ScraperPanel upp22Panel;

  private Splash splash; 
  private String lastScraper="";
  private JFrame extShakerFrame = null;
  private ConfigFilePanel configPanel;
  private PllFrame        pllFrame=null;
        
  /**
   * Creates new form MainPanel
   */
  public MainPanel(boolean runningFromShell) {
    
    this.runningFromShell = runningFromShell;
    
    // Handle windowClosing (Close from the system menu)
    addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
        exitForm();
      }
    });

    // Splash window

    int nbDevice = 0;
    splash = new Splash();
    splash.setTitle("Cleaning " + APP_RELEASE);
    splash.setCopyright("(c) ESRF & DLS 2018");
    splash.setMaxProgress(25);
    splash.progress(0);

    initComponents();

    errWin = new ErrorHistory();
    
    attList = new AttributeList();
    attList.addErrorListener(errWin);
    attList.addSetErrorListener(ErrorPopup.getInstance());
    
    cmdList = new CommandList();
    cmdList.addErrorListener(errWin);
    cmdList.addErrorListener(ErrorPopup.getInstance());    
    
    // Scraper Panels
    splash.progress(nbDevice++);
    upp5Panel = new ScraperPanel(upp5DevName);
    upp5Panel.setBounds(5,20,235,120);
    scraperPanel.add(upp5Panel);
    splash.progress(nbDevice++);
    low5Panel = new ScraperPanel(low5DevName);
    low5Panel.setBounds(240,20,235,120);
    scraperPanel.add(low5Panel);    

    splash.progress(nbDevice++);
    upp25Panel = new ScraperPanel(upp25DevName);
    upp25Panel.setBounds(5,20,235,120);
    scraperPanel.add(upp25Panel);
    splash.progress(nbDevice++);
    low25Panel = new ScraperPanel(low25DevName);
    low25Panel.setBounds(240,20,235,120);
    scraperPanel.add(low25Panel);    
    
    splash.progress(nbDevice++);
    upp22Panel = new ScraperPanel(upp22DevName);
    upp22Panel.setBounds(5,20,235,120);
    scraperPanel.add(upp22Panel);
        
    // Init models
    
    try {
            
      NumberScalar upp5 = (NumberScalar)attList.add(cleaningDevName+"/Upp5");
      upp5Editor.setModel(upp5);
      splash.progress(nbDevice++);
      
      NumberScalar low5 = (NumberScalar)attList.add(cleaningDevName+"/Low5");
      low5Editor.setModel(low5);
      splash.progress(nbDevice++);
      
      NumberScalar upp25 = (NumberScalar)attList.add(cleaningDevName+"/Upp25");
      upp25Editor.setModel(upp25);
      splash.progress(nbDevice++);
      
      NumberScalar low25 = (NumberScalar)attList.add(cleaningDevName+"/Low25");
      low25Editor.setModel(low25);
      splash.progress(nbDevice++);

      NumberScalar upp22 = (NumberScalar)attList.add(cleaningDevName+"/Upp22");
      upp22Editor.setModel(upp22);
      splash.progress(nbDevice++);
      
      EnumScalar mode = (EnumScalar)attList.add(cleaningDevName+"/Scrapers");
      mode.addEnumScalarListener(this);
      scraperModeEditor.setEnumModel(mode);
      mode.refresh();
      splash.progress(nbDevice++);
      
      NumberScalar freqMin = (NumberScalar)attList.add(cleaningDevName+"/FreqMin");
      freqMinEditor.setModel(freqMin);
      splash.progress(nbDevice++);
      
      NumberScalar freqMax = (NumberScalar)attList.add(cleaningDevName+"/FreqMax");
      freqMaxEditor.setModel(freqMax);
      splash.progress(nbDevice++);
      
      NumberScalar sweepTime = (NumberScalar)attList.add(cleaningDevName+"/SweepTime");
      sweepTimeEditor.setModel(sweepTime);
      splash.progress(nbDevice++);

      NumberScalar gain = (NumberScalar)attList.add(cleaningDevName+"/Gain");
      gainEditor.setModel(gain);
      splash.progress(nbDevice++);
      
      BooleanScalar extSweep = (BooleanScalar)attList.add(cleaningDevName+"/ExternalSweep");
      externalSweepEditor.setAttModel(extSweep);
      splash.progress(nbDevice++);
      
      DevStateScalar pllState = (DevStateScalar)attList.add(pllDevName+"/State");
      pllStateViewer.setModel(pllState);
      splash.progress(nbDevice++);
      
      StringScalar pllStatus = (StringScalar)attList.add(pllDevName+"/Status");
      pllStatusViewer.setModel(pllStatus);
      splash.progress(nbDevice++);

      StringScalar cleaningStatus = (StringScalar)attList.add(cleaningDevName+"/Status");
      cleaningStatusViewer.setModel(cleaningStatus);
      splash.progress(nbDevice++);
      
      VoidVoidCommand clean = (VoidVoidCommand)cmdList.add(cleaningDevName+"/StartCleaning");
      cleanCommand.setModel(clean);
      cleanCommand.setText("Clean");
      splash.progress(nbDevice++);

      VoidVoidCommand sweep = (VoidVoidCommand)cmdList.add(cleaningDevName+"/Sweep");
      sweepCommand.setModel(sweep);
      sweepCommand.setText("Sweep");
      splash.progress(nbDevice++);

      VoidVoidCommand done = (VoidVoidCommand)cmdList.add(cleaningDevName+"/EndCleaning");
      doneCommand.setModel(done);
      doneCommand.setText("Done");
      splash.progress(nbDevice++);

      VoidVoidCommand doAll = (VoidVoidCommand)cmdList.add(cleaningDevName+"/DoAll");
      doAllCommand.setModel(doAll);
      doAllCommand.setText("Do All");
      splash.progress(nbDevice++);

      VoidVoidCommand stop = (VoidVoidCommand)cmdList.add(cleaningDevName+"/Stop");
      stopCommand.setModel(stop);
      stopCommand.setText("Abort");
      splash.progress(nbDevice++);
      
      DevStateScalar state = (DevStateScalar)attList.add(cleaningDevName+"/State");
      state.addDevStateScalarListener(this);
      splash.progress(nbDevice++);
      state.refresh();
            
    } catch (ConnectionException e) {
      
    }
    
    pllStateViewer.addMouseListener(new MouseAdapter() {
      public void mouseClicked(MouseEvent e) {
        if(pllFrame==null)
          pllFrame = new PllFrame(false);
        pllFrame.setVisible(true);      
      }      
    });
    
    configPanel = new ConfigFilePanel("Configuration File");
    configPanel.setModel(cleaningDevName,errWin);
    configFileContainer.add(configPanel,BorderLayout.CENTER);
    
    pllStatusViewer.setBorder(null);
    cleaningStatusViewer.setBorder(null);
    attList.setRefreshInterval(1000);
    attList.startRefresher();
    DeviceFactory.getInstance().stopRefresher();
    splash.setVisible(false);
    setTitle("SR Cleaning [" + APP_RELEASE + "]");
    innerPanel.setPreferredSize(new Dimension(480,640));
    ATKGraphicsUtils.centerFrameOnScreen(this);
    
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


  }
  
  private void createShakerFrame() {

    if( extShakerFrame!=null )
      return;

    try {

      Database db = ApiUtil.get_db_obj();
      DbDatum dd = db.get_device_property(cleaningDevName, "ExternalShakerDevice");
      String shaker = dd.extractString();

      extShakerFrame = new JFrame(shaker);

      JPanel innerPanel = new JPanel();
      innerPanel.setLayout(new BorderLayout());

      WaveformPanel wPanel = new WaveformPanel(shaker, errWin);
      innerPanel.add(wPanel, BorderLayout.CENTER);

      JPanel downPanel = new JPanel();
      downPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
      innerPanel.add(downPanel, BorderLayout.SOUTH);

      JButton dismissBtn = new JButton("Dismiss");
      dismissBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          extShakerFrame.setVisible(false);
        }
      });

      extShakerFrame.setContentPane(innerPanel);
      extShakerFrame.setTitle("External shaker [" + shaker + "]");

    } catch (DevFailed ex) {
      ErrorPane.showErrorMessage(this, cleaningDevName, ex);
    }

  }

  @Override
  public void enumScalarChange(EnumScalarEvent ese) {
    
    String scraper = ese.getValue();
    
    if( !lastScraper.equalsIgnoreCase(scraper) ) {

      lastScraper = scraper;
      
      boolean m5 = lastScraper.equalsIgnoreCase("Use Upp5 and Low5");
      boolean m25 = lastScraper.equalsIgnoreCase("Use Upp25 and Low25");
      boolean m22 = lastScraper.equalsIgnoreCase("Use Upp22");
        
      upp5Panel.setVisible(m5);
      low5Panel.setVisible(m5);
      upp5Editor.setEnabled(m5);
      low5Editor.setEnabled(m5);
      
      upp25Panel.setVisible(m25);
      low25Panel.setVisible(m25);      
      upp25Editor.setEnabled(m25);
      low25Editor.setEnabled(m25);
      
      upp22Panel.setVisible(m22);
      upp22Editor.setEnabled(m22);

    }
    
  }
  
  @Override
  public void devStateScalarChange(DevStateScalarEvent dsse) {

    String state = dsse.getValue();

    if( state.compareToIgnoreCase(IDevice.ON)==0 ) {
      // Ready to sweep (scrapper are positioned)
      cleanCommand.setEnabled(false);
      sweepCommand.setEnabled(true);
      doneCommand.setEnabled(true);
      doAllCommand.setEnabled(false);
    } else if ( state.compareToIgnoreCase(IDevice.OFF)==0 ) {
      cleanCommand.setEnabled(true);
      sweepCommand.setEnabled(false);
      doneCommand.setEnabled(false);
      doAllCommand.setEnabled(true);
    } else {
      cleanCommand.setEnabled(false);
      sweepCommand.setEnabled(false);
      doneCommand.setEnabled(false);
      doAllCommand.setEnabled(false);
    }
    
  }

  @Override
  public void stateChange(AttributeStateEvent ase) {
  }

  @Override
  public void errorChange(ErrorEvent ee) {
  }

  /**
   * This method is called from within the constructor to initialize the form.
   * WARNING: Do NOT modify this code. The content of this method is always
   * regenerated by the Form Editor.
   */
  @SuppressWarnings("unchecked")
  // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
  private void initComponents() {
    java.awt.GridBagConstraints gridBagConstraints;

    innerPanel = new javax.swing.JPanel();
    scraperPanel = new javax.swing.JPanel();
    scraperSettingsPanel = new javax.swing.JPanel();
    scraperModeEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    upp5Label = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    upp5Editor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    low5Label = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    low5Editor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSeparator1 = new javax.swing.JSeparator();
    upp25Label = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    upp25Editor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    low25Label = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    low25Editor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSeparator2 = new javax.swing.JSeparator();
    upp22Label = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    upp22Editor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    shakerSettingsPanel = new javax.swing.JPanel();
    freqMinLabel = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    freqMinEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    freqMaxLabel = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    freqMaxEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    sweepTimeLabel = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    sweepTimeEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    gainLabel = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    gainEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    externalSweepEditor = new fr.esrf.tangoatk.widget.attribute.BooleanScalarCheckBoxViewer();
    shakerButton = new javax.swing.JButton();
    pllPanel = new javax.swing.JPanel();
    pllStateViewer = new fr.esrf.tangoatk.widget.attribute.StateViewer();
    pllStatusViewer = new fr.esrf.tangoatk.widget.attribute.StatusViewer();
    commandPanel = new javax.swing.JPanel();
    cleaningStatusViewer = new fr.esrf.tangoatk.widget.attribute.StatusViewer();
    btnPanel = new javax.swing.JPanel();
    cleanCommand = new fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer();
    sweepCommand = new fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer();
    doneCommand = new fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer();
    doAllCommand = new fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer();
    stopCommand = new fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer();
    configFileContainer = new javax.swing.JPanel();
    jMenuBar1 = new javax.swing.JMenuBar();
    fileMenu = new javax.swing.JMenu();
    exitMenuItem = new javax.swing.JMenuItem();
    viewMenu = new javax.swing.JMenu();
    errorMenuItem = new javax.swing.JMenuItem();
    diagMenuItem = new javax.swing.JMenuItem();

    setDefaultCloseOperation(javax.swing.WindowConstants.DO_NOTHING_ON_CLOSE);

    innerPanel.setLayout(new java.awt.GridBagLayout());

    scraperPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Scraper Positions"));
    scraperPanel.setMinimumSize(new java.awt.Dimension(460, 150));
    scraperPanel.setPreferredSize(new java.awt.Dimension(460, 150));
    scraperPanel.setLayout(null);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    innerPanel.add(scraperPanel, gridBagConstraints);

    scraperSettingsPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Sraper Settings"));
    scraperSettingsPanel.setLayout(new java.awt.GridBagLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 3, 5, 3);
    scraperSettingsPanel.add(scraperModeEditor, gridBagConstraints);

    upp5Label.setHorizontalAlignment(0);
    upp5Label.setOpaque(false);
    upp5Label.setText("Upp5 (mm)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    scraperSettingsPanel.add(upp5Label, gridBagConstraints);

    upp5Editor.setBackground(java.awt.SystemColor.controlHighlight);
    upp5Editor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 3);
    scraperSettingsPanel.add(upp5Editor, gridBagConstraints);

    low5Label.setHorizontalAlignment(0);
    low5Label.setOpaque(false);
    low5Label.setText("Low5 (mm)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    scraperSettingsPanel.add(low5Label, gridBagConstraints);

    low5Editor.setBackground(java.awt.SystemColor.controlHighlight);
    low5Editor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 3);
    scraperSettingsPanel.add(low5Editor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(10, 0, 10, 0);
    scraperSettingsPanel.add(jSeparator1, gridBagConstraints);

    upp25Label.setHorizontalAlignment(0);
    upp25Label.setOpaque(false);
    upp25Label.setText("Upp25 (mm)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    scraperSettingsPanel.add(upp25Label, gridBagConstraints);

    upp25Editor.setBackground(java.awt.SystemColor.controlHighlight);
    upp25Editor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 3);
    scraperSettingsPanel.add(upp25Editor, gridBagConstraints);

    low25Label.setHorizontalAlignment(0);
    low25Label.setOpaque(false);
    low25Label.setText("Low25 (mm)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 5;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    scraperSettingsPanel.add(low25Label, gridBagConstraints);

    low25Editor.setBackground(java.awt.SystemColor.controlHighlight);
    low25Editor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 5;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 3);
    scraperSettingsPanel.add(low25Editor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 6;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(10, 0, 10, 0);
    scraperSettingsPanel.add(jSeparator2, gridBagConstraints);

    upp22Label.setHorizontalAlignment(0);
    upp22Label.setOpaque(false);
    upp22Label.setText("Upp22 (mm)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 7;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    scraperSettingsPanel.add(upp22Label, gridBagConstraints);

    upp22Editor.setBackground(java.awt.SystemColor.controlHighlight);
    upp22Editor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 7;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 0, 5, 3);
    scraperSettingsPanel.add(upp22Editor, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.gridheight = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    innerPanel.add(scraperSettingsPanel, gridBagConstraints);

    shakerSettingsPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Shaker Settings"));
    shakerSettingsPanel.setLayout(new java.awt.GridBagLayout());

    freqMinLabel.setHorizontalAlignment(0);
    freqMinLabel.setOpaque(false);
    freqMinLabel.setText("FreqMin (tune)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    shakerSettingsPanel.add(freqMinLabel, gridBagConstraints);

    freqMinEditor.setBackground(java.awt.SystemColor.controlHighlight);
    freqMinEditor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    shakerSettingsPanel.add(freqMinEditor, gridBagConstraints);

    freqMaxLabel.setHorizontalAlignment(0);
    freqMaxLabel.setOpaque(false);
    freqMaxLabel.setText("FreqMax (tune)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    shakerSettingsPanel.add(freqMaxLabel, gridBagConstraints);

    freqMaxEditor.setBackground(java.awt.SystemColor.controlHighlight);
    freqMaxEditor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    shakerSettingsPanel.add(freqMaxEditor, gridBagConstraints);

    sweepTimeLabel.setHorizontalAlignment(0);
    sweepTimeLabel.setOpaque(false);
    sweepTimeLabel.setText("SweepTime (sec)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    shakerSettingsPanel.add(sweepTimeLabel, gridBagConstraints);

    sweepTimeEditor.setBackground(java.awt.SystemColor.controlHighlight);
    sweepTimeEditor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    shakerSettingsPanel.add(sweepTimeEditor, gridBagConstraints);

    gainLabel.setHorizontalAlignment(0);
    gainLabel.setOpaque(false);
    gainLabel.setText("Gain (%)");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    shakerSettingsPanel.add(gainLabel, gridBagConstraints);

    gainEditor.setBackground(java.awt.SystemColor.controlHighlight);
    gainEditor.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
    shakerSettingsPanel.add(gainEditor, gridBagConstraints);

    externalSweepEditor.setBorder(null);
    externalSweepEditor.setText("External Sweep");
    externalSweepEditor.setFont(new java.awt.Font("Dialog", 0, 12)); // NOI18N
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    shakerSettingsPanel.add(externalSweepEditor, gridBagConstraints);

    shakerButton.setText("External Shaker");
    shakerButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        shakerButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    shakerSettingsPanel.add(shakerButton, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    innerPanel.add(shakerSettingsPanel, gridBagConstraints);

    pllPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("PLL"));
    pllPanel.setLayout(new java.awt.GridBagLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 5, 0);
    pllPanel.add(pllStateViewer, gridBagConstraints);

    pllStatusViewer.setBorder(null);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    pllPanel.add(pllStatusViewer, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    innerPanel.add(pllPanel, gridBagConstraints);

    commandPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Command"));
    commandPanel.setLayout(new java.awt.GridBagLayout());

    cleaningStatusViewer.setBorder(null);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 5);
    commandPanel.add(cleaningStatusViewer, gridBagConstraints);

    btnPanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

    cleanCommand.setText("Clean");
    btnPanel.add(cleanCommand);

    sweepCommand.setText("Sweep");
    btnPanel.add(sweepCommand);

    doneCommand.setText("Done");
    btnPanel.add(doneCommand);

    doAllCommand.setText("Do All");
    btnPanel.add(doAllCommand);

    stopCommand.setLabel("Stop");
    btnPanel.add(stopCommand);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    commandPanel.add(btnPanel, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipady = 20;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 1.0;
    innerPanel.add(commandPanel, gridBagConstraints);

    configFileContainer.setLayout(new java.awt.BorderLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    innerPanel.add(configFileContainer, gridBagConstraints);

    getContentPane().add(innerPanel, java.awt.BorderLayout.CENTER);

    fileMenu.setText("File");

    exitMenuItem.setText("Exit");
    exitMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        exitMenuItemActionPerformed(evt);
      }
    });
    fileMenu.add(exitMenuItem);

    jMenuBar1.add(fileMenu);

    viewMenu.setText("Edit");

    errorMenuItem.setText("Errors...");
    errorMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        errorMenuItemActionPerformed(evt);
      }
    });
    viewMenu.add(errorMenuItem);

    diagMenuItem.setText("Diagnostics...");
    diagMenuItem.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        diagMenuItemActionPerformed(evt);
      }
    });
    viewMenu.add(diagMenuItem);

    jMenuBar1.add(viewMenu);

    setJMenuBar(jMenuBar1);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void exitMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_exitMenuItemActionPerformed
    exitForm();
  }//GEN-LAST:event_exitMenuItemActionPerformed

  private void shakerButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_shakerButtonActionPerformed
    createShakerFrame();
    if(extShakerFrame!=null) {
      ATKGraphicsUtils.centerFrameOnScreen(extShakerFrame);
      extShakerFrame.setVisible(true);
    }    
  }//GEN-LAST:event_shakerButtonActionPerformed

  private void errorMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_errorMenuItemActionPerformed
    ATKGraphicsUtils.centerFrameOnScreen(errWin);
    errWin.setVisible(true);
  }//GEN-LAST:event_errorMenuItemActionPerformed

  private void diagMenuItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_diagMenuItemActionPerformed
    fr.esrf.tangoatk.widget.util.ATKDiagnostic.showDiagnostic();
  }//GEN-LAST:event_diagMenuItemActionPerformed

  /**
   * @param args the command line arguments
   */
  public static void main(String args[]) {
    new MainPanel(true).setVisible(true);
  }

  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel btnPanel;
  private fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer cleanCommand;
  private fr.esrf.tangoatk.widget.attribute.StatusViewer cleaningStatusViewer;
  private javax.swing.JPanel commandPanel;
  private javax.swing.JPanel configFileContainer;
  private javax.swing.JMenuItem diagMenuItem;
  private fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer doAllCommand;
  private fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer doneCommand;
  private javax.swing.JMenuItem errorMenuItem;
  private javax.swing.JMenuItem exitMenuItem;
  private fr.esrf.tangoatk.widget.attribute.BooleanScalarCheckBoxViewer externalSweepEditor;
  private javax.swing.JMenu fileMenu;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor freqMaxEditor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel freqMaxLabel;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor freqMinEditor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel freqMinLabel;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor gainEditor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel gainLabel;
  private javax.swing.JPanel innerPanel;
  private javax.swing.JMenuBar jMenuBar1;
  private javax.swing.JSeparator jSeparator1;
  private javax.swing.JSeparator jSeparator2;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor low25Editor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel low25Label;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor low5Editor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel low5Label;
  private javax.swing.JPanel pllPanel;
  private fr.esrf.tangoatk.widget.attribute.StateViewer pllStateViewer;
  private fr.esrf.tangoatk.widget.attribute.StatusViewer pllStatusViewer;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor scraperModeEditor;
  private javax.swing.JPanel scraperPanel;
  private javax.swing.JPanel scraperSettingsPanel;
  private javax.swing.JButton shakerButton;
  private javax.swing.JPanel shakerSettingsPanel;
  private fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer stopCommand;
  private fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer sweepCommand;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor sweepTimeEditor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel sweepTimeLabel;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor upp22Editor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel upp22Label;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor upp25Editor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel upp25Label;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor upp5Editor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel upp5Label;
  private javax.swing.JMenu viewMenu;
  // End of variables declaration//GEN-END:variables
  
}
