/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package MBF;

import static MBF.MainPanel.errWin;
import fr.esrf.tangoatk.core.AttributePolledList;
import fr.esrf.tangoatk.core.ConnectionException;
import fr.esrf.tangoatk.core.attribute.EnumScalar;
import fr.esrf.tangoatk.core.attribute.NumberScalar;
import fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor;
import fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.JSmoothLabel;
import java.awt.Color;
import java.awt.GridBagConstraints;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JButton;
import javax.swing.JPanel;

/**
 *
 * @author pons
 */
public class SEQSetupPanel extends javax.swing.JFrame {

  static Insets noMargin = new Insets(0,0,0,0);
  private AttributePolledList attList;
  private String devName;
  static SettingFrame instance = null;
  private SEQWindowPanel seqWindowPanel = null;
  private SuperSEQPanel superSeqPanel = null;
          
  class SeqLine {
    
    JSmoothLabel idxLabel;

    NumberScalar sweepStart;
    SimpleScalarViewer sweepStartViewer;
    JButton sweepStartBtn;
    NumberScalar sweepStep;
    SimpleScalarViewer sweepStepViewer;
    JButton sweepStepBtn;
    NumberScalar sweepEnd;
    SimpleScalarViewer sweepEndViewer;
    JButton sweepEndBtn;
    NumberScalar capture;
    SimpleScalarViewer captureViewer;
    JButton captureBtn;
    NumberScalar holdoff;
    SimpleScalarViewer holdoffViewer;
    JButton holdoffBtn;
    NumberScalar dwellTime;
    SimpleScalarViewer dwellTimeViewer;
    JButton dwellTimeBtn;
    EnumScalar magnitude;
    EnumScalarComboEditor magnitudeEditor;
    EnumScalar magnitudeEna;
    EnumScalarComboEditor magnitudeEnaEditor;
    EnumScalar bunchBank;
    EnumScalarComboEditor bunchBankEditor;
    EnumScalar blanking;
    EnumScalarComboEditor blankingEditor;
    EnumScalar dataWindow;
    EnumScalarComboEditor dataWindowEditor;
    EnumScalar dataCapture;
    EnumScalarComboEditor dataCaptureEditor;
    
    SeqLine(int idx,Color background,JPanel parentPanel) {

      GridBagConstraints gbc = new GridBagConstraints();
      gbc.fill = GridBagConstraints.BOTH;
      gbc.gridy = idx;
      
      // -------------------
      idxLabel = new JSmoothLabel();
      idxLabel.setText(Integer.toString(idx));
      idxLabel.setOpaque(false);
      gbc.ipadx = 5;
      gbc.gridx = 0;
      parentPanel.add(idxLabel,gbc);
            
      // -------------------
      sweepStartViewer = new SimpleScalarViewer();
      sweepStartViewer.setText("-----");
      sweepStartViewer.setBackgroundColor(background);
      sweepStartViewer.setUnitVisible(false);
      gbc.ipadx = 10;
      gbc.insets.left = 5;
      gbc.gridx = 1;
      parentPanel.add(sweepStartViewer,gbc);
      
      sweepStartBtn = new JButton("...");
      sweepStartBtn.setMargin(noMargin);
      sweepStartBtn.setFont(ATKConstant.labelFont);
      sweepStartBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          showSetter(sweepStart);
        }
      });      
      gbc.ipadx = 0;
      gbc.insets.left = 0;
      gbc.gridx = 2;
      parentPanel.add(sweepStartBtn,gbc);

      // -------------------
      sweepStepViewer = new SimpleScalarViewer();
      sweepStepViewer.setText("-----");
      sweepStepViewer.setBackgroundColor(background);
      sweepStepViewer.setUnitVisible(false);
      gbc.ipadx = 10;
      gbc.insets.left = 5;
      gbc.gridx = 3;
      parentPanel.add(sweepStepViewer,gbc);
      
      sweepStepBtn = new JButton("...");
      sweepStepBtn.setMargin(noMargin);
      sweepStepBtn.setFont(ATKConstant.labelFont);      
      sweepStepBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          showSetter(sweepStep);
        }
      });      
      gbc.ipadx = 0;
      gbc.insets.left = 0;
      gbc.gridx = 4;
      parentPanel.add(sweepStepBtn,gbc);
      
      // -------------------
      sweepEndViewer = new SimpleScalarViewer();
      sweepEndViewer.setText("-----");
      sweepEndViewer.setBackgroundColor(background);
      sweepEndViewer.setUnitVisible(false);
      gbc.ipadx = 10;
      gbc.insets.left = 5;
      gbc.gridx = 5;
      parentPanel.add(sweepEndViewer,gbc);
      
      sweepEndBtn = new JButton("...");
      sweepEndBtn.setMargin(noMargin);
      sweepEndBtn.setFont(ATKConstant.labelFont);      
      sweepEndBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          showSetter(sweepEnd);
        }
      });      
      gbc.ipadx = 0;
      gbc.insets.left = 0;
      gbc.gridx = 6;
      parentPanel.add(sweepEndBtn,gbc);
      
      // -------------------
      captureViewer = new SimpleScalarViewer();
      captureViewer.setText("-----");
      captureViewer.setBackgroundColor(background);
      gbc.ipadx = 10;
      gbc.insets.left = 5;
      gbc.gridx = 7;
      parentPanel.add(captureViewer,gbc);
      
      captureBtn = new JButton("...");
      captureBtn.setMargin(noMargin);
      captureBtn.setFont(ATKConstant.labelFont);
      captureBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          showSetter(capture);
        }
      });      

      gbc.ipadx = 0;
      gbc.insets.left = 0;
      gbc.gridx = 8;
      parentPanel.add(captureBtn,gbc);

      // -------------------
      holdoffViewer = new SimpleScalarViewer();
      holdoffViewer.setText("-----");
      holdoffViewer.setBackgroundColor(background);
      gbc.ipadx = 20;
      gbc.insets.left = 5;
      gbc.gridx = 9;
      parentPanel.add(holdoffViewer,gbc);
      
      holdoffBtn = new JButton("...");
      holdoffBtn.setMargin(noMargin);
      holdoffBtn.setFont(ATKConstant.labelFont);      
      holdoffBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          showSetter(holdoff);
        }
      });      
      gbc.ipadx = 0;
      gbc.insets.left = 0;
      gbc.gridx = 10;
      parentPanel.add(holdoffBtn,gbc);
      
      // -------------------
      
      dwellTimeViewer = new SimpleScalarViewer();
      dwellTimeViewer.setText("-----");
      dwellTimeViewer.setBackgroundColor(background);
      dwellTimeViewer.setUnitVisible(false);
      gbc.ipadx = 20;
      gbc.insets.left = 5;
      gbc.gridx = 11;
      parentPanel.add(dwellTimeViewer,gbc);
      
      dwellTimeBtn = new JButton("...");
      dwellTimeBtn.setMargin(noMargin);
      dwellTimeBtn.setFont(ATKConstant.labelFont);      
      dwellTimeBtn.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
          showSetter(dwellTime);
        }
      });      
      gbc.ipadx = 0;
      gbc.insets.left = 0;
      gbc.gridx = 12;
      parentPanel.add(dwellTimeBtn,gbc);
      
      // -------------------
      gbc.ipadx = 5;
      gbc.insets.left = 5;
      
      magnitudeEditor = new EnumScalarComboEditor();
      magnitudeEditor.setFont(ATKConstant.labelFont);
      gbc.gridx = 13;
      parentPanel.add(magnitudeEditor,gbc);

      // -------------------
      magnitudeEnaEditor = new EnumScalarComboEditor();
      magnitudeEnaEditor.setFont(ATKConstant.labelFont);      
      gbc.gridx = 14;
      parentPanel.add(magnitudeEnaEditor,gbc);

      // -------------------
      bunchBankEditor = new EnumScalarComboEditor();
      bunchBankEditor.setFont(ATKConstant.labelFont);
      gbc.gridx = 15;
      parentPanel.add(bunchBankEditor,gbc);

      // -------------------
      blankingEditor = new EnumScalarComboEditor();
      blankingEditor.setFont(ATKConstant.labelFont);
      gbc.gridx = 16;
      parentPanel.add(blankingEditor,gbc);

      // -------------------
      dataWindowEditor = new EnumScalarComboEditor();
      dataWindowEditor.setFont(ATKConstant.labelFont);
      gbc.gridx = 17;
      parentPanel.add(dataWindowEditor,gbc);

      // -------------------
      dataCaptureEditor = new EnumScalarComboEditor();
      dataCaptureEditor.setFont(ATKConstant.labelFont);
      gbc.insets.right = 5;
      gbc.gridx = 18;
      parentPanel.add(dataCaptureEditor,gbc);
      
        
    }
    
    
    void setModel(String devName,String gDevName,AttributePolledList attList,int idx) throws ConnectionException {
      
      sweepStart = (NumberScalar)attList.add(devName+"/SEQ_"+idx+"_START_FREQ_S");
      sweepStartViewer.setModel(sweepStart);
      sweepStep = (NumberScalar)attList.add(devName+"/SEQ_"+idx+"_STEP_FREQ_S");
      sweepStepViewer.setModel(sweepStep);
      sweepEnd = (NumberScalar)attList.add(devName+"/SEQ_"+idx+"_END_FREQ_S");
      sweepEndViewer.setModel(sweepEnd);
      capture = (NumberScalar)attList.add(devName+"/SEQ_"+idx+"_COUNT_S");
      captureViewer.setModel(capture);
      holdoff = (NumberScalar)attList.add(devName+"/SEQ_"+idx+"_HOLDOFF_S");
      holdoffViewer.setModel(holdoff);

      if(idx==1 )      
        // Pass via the high level class (this param is saved in config file)
        dwellTime = (NumberScalar)attList.add(gDevName+"/SweepDwellTime");
      else
        dwellTime = (NumberScalar)attList.add(devName+"/SEQ_"+idx+"_DWELL_S");

      dwellTimeViewer.setModel(dwellTime);

      if(idx==1 )      
        // Pass via the high level class (this param is saved in config file)
        magnitude = (EnumScalar)attList.add(gDevName+"/SweepGain");
      else
        magnitude = (EnumScalar)attList.add(devName+"/SEQ_"+idx+"_GAIN_S");

      magnitudeEditor.setEnumModel(magnitude);
      magnitudeEna = (EnumScalar)attList.add(devName+"/SEQ_"+idx+"_ENABLE_S");
      magnitudeEnaEditor.setEnumModel(magnitudeEna);
      bunchBank = (EnumScalar)attList.add(devName+"/SEQ_"+idx+"_BANK_S");
      bunchBankEditor.setEnumModel(bunchBank);
      blanking = (EnumScalar)attList.add(devName+"/SEQ_"+idx+"_BLANK_S");
      blankingEditor.setEnumModel(blanking);
      dataWindow = (EnumScalar)attList.add(devName+"/SEQ_"+idx+"_ENWIN_S");
      dataWindowEditor.setEnumModel(dataWindow);
      dataCapture = (EnumScalar)attList.add(devName+"/SEQ_"+idx+"_CAPTURE_S");
      dataCaptureEditor.setEnumModel(dataCapture);
      
      
    }
    
    
  }

  /**
   * Creates new form FIRSetupPanel
   */
  public SEQSetupPanel(String devName,String gDevName) {
    
    initComponents();
    
    this.devName = devName;
    attList = new AttributePolledList();
    attList.addErrorListener(errWin);

    try {
      
      GridBagConstraints gbc = new GridBagConstraints();
      gbc.fill = GridBagConstraints.BOTH;
      gbc.gridy = 0;
      gbc.ipadx = 5;
      
      gbc.gridx = 0;
      gbc.gridwidth = 1;
      tablePanel.add(Utils.createLabel("#",""),gbc);              
      gbc.gridwidth = 2;
      gbc.gridx = 1;
      tablePanel.add(Utils.createLabel("Sweep Start","tune"),gbc);              
      gbc.gridx = 3;
      tablePanel.add(Utils.createLabel("Sweep Step","tune"),gbc);              
      gbc.gridx = 5;
      tablePanel.add(Utils.createLabel("Sweep End","tune"),gbc);              
      gbc.gridx = 7;
      tablePanel.add(Utils.createLabel("Capture",""),gbc);              
      gbc.gridx = 9;
      tablePanel.add(Utils.createLabel("Holdoff", ""),gbc);              
      gbc.gridx = 11;
      tablePanel.add(Utils.createLabel("Dwell Time", "turns"),gbc);              
      gbc.gridwidth = 1;
      gbc.gridx = 13;
      tablePanel.add(Utils.createLabel("Magnitude", ""),gbc);              
      gbc.gridx = 14;
      tablePanel.add(Utils.createLabel("Enable", ""),gbc);              
      gbc.gridx = 15;
      tablePanel.add(Utils.createLabel("Bunch Bank", ""),gbc);              
      gbc.gridx = 16;
      tablePanel.add(Utils.createLabel("Blanking", ""),gbc);              
      gbc.gridx = 17;
      tablePanel.add(Utils.createLabel("Window", ""),gbc);              
      gbc.gridx = 18;
      tablePanel.add(Utils.createLabel("Data Capture", ""),gbc);              
      
      
      for(int i=1;i<8;i++) {
        SeqLine l = new SeqLine(i,getBackground(),tablePanel);
        l.setModel(devName,gDevName, attList, i);
      }
      
      NumberScalar startW = (NumberScalar)attList.add(devName+"/SEQ_PC_S");
      startEditor.setModel(startW);
      NumberScalar startR = (NumberScalar)attList.add(devName+"/SEQ_PC");      
      startViewer.setModel(startR);
      startViewer.setBackgroundColor(getBackground());

      NumberScalar superW = (NumberScalar)attList.add(devName+"/SEQ_SUPER_COUNT_S");
      superEditor.setModel(superW);
      NumberScalar superR = (NumberScalar)attList.add(devName+"/SEQ_SUPER_COUNT");      
      superViewer.setModel(superR);
      superViewer.setBackgroundColor(getBackground());
      
      NumberScalar captureR = (NumberScalar)attList.add(devName+"/SEQ_TOTAL_LENGTH");      
      captureViewer.setModel(captureR);
      captureViewer.setBackgroundColor(getBackground());
      
      NumberScalar durationR = (NumberScalar)attList.add(devName+"/SEQ_TOTAL_DURATION_S");      
      durationViewer.setModel(durationR);
      durationViewer.setBackgroundColor(getBackground());

      //NumberScalar offsetR = (NumberScalar)attList.add(devName+"/SEQ_SUPER_OFFSET_S");      
      //offsetViewer.setModel(offsetR);
      offsetViewer.setBackground(getBackground());
      offsetViewer.setBackgroundColor(getBackground());

      NumberScalar eventW = (NumberScalar)attList.add(devName+"/SEQ_TRIGGER_S");      
      eventEditor.setModel(eventW);
      
      EnumScalar steadyState = (EnumScalar)attList.add(devName+"/SEQ_0_BANK_S");
      steadyStateEditor.setEnumModel(steadyState);
      
      
    } catch (ConnectionException ex) {      
    }
        
    attList.setRefreshInterval(1000);
    
    setTitle("Sequencer Setup [" + devName + "]");
    ATKGraphicsUtils.centerFrameOnScreen(this);
  }

  public static void showSetter(NumberScalar model) {
    
    if( instance==null )
      instance = new SettingFrame();
    instance.title.setText(model.getDeviceName());
    instance.setPanel.setAttModel(model);
    if(!instance.isVisible())
      ATKGraphicsUtils.centerFrameOnScreen(instance);
    instance.setVisible(true);
    
  }
  
  
  public void setVisible(boolean visible) {
    if(visible)
      attList.startRefresher();
    else
      attList.stopRefresher();    
    super.setVisible(visible);
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

    seqPanel = new javax.swing.JPanel();
    jSmoothLabel12 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    steadyStateEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    jSmoothLabel13 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    startEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    startViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel14 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    superEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    superViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    tablePanel = new javax.swing.JPanel();
    freePanel = new javax.swing.JPanel();
    stopButton = new javax.swing.JButton();
    jSmoothLabel15 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    durationViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel4 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    captureViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel17 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    offsetViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel16 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    eventEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    btnPanel = new javax.swing.JPanel();
    trigButton = new javax.swing.JButton();
    superButton = new javax.swing.JButton();
    windowButton = new javax.swing.JButton();
    dismissButton = new javax.swing.JButton();

    seqPanel.setLayout(new java.awt.GridBagLayout());

    jSmoothLabel12.setFocusable(false);
    jSmoothLabel12.setHorizontalAlignment(0);
    jSmoothLabel12.setOpaque(false);
    jSmoothLabel12.setText("Steady State");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 14;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 10, 0, 0);
    seqPanel.add(jSmoothLabel12, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 15;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 20;
    seqPanel.add(steadyStateEditor, gridBagConstraints);

    jSmoothLabel13.setFocusable(false);
    jSmoothLabel13.setHorizontalAlignment(0);
    jSmoothLabel13.setOpaque(false);
    jSmoothLabel13.setText("Start");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(jSmoothLabel13, gridBagConstraints);

    startEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    seqPanel.add(startEditor, gridBagConstraints);

    startViewer.setBorder(null);
    startViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 20;
    seqPanel.add(startViewer, gridBagConstraints);

    jSmoothLabel14.setFocusable(false);
    jSmoothLabel14.setHorizontalAlignment(0);
    jSmoothLabel14.setOpaque(false);
    jSmoothLabel14.setText("Super");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 3;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(jSmoothLabel14, gridBagConstraints);

    superEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 4;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    seqPanel.add(superEditor, gridBagConstraints);

    superViewer.setBorder(null);
    superViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 5;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 20;
    seqPanel.add(superViewer, gridBagConstraints);

    tablePanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    tablePanel.setLayout(new java.awt.GridBagLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.gridwidth = 18;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 1.0;
    seqPanel.add(tablePanel, gridBagConstraints);

    javax.swing.GroupLayout freePanelLayout = new javax.swing.GroupLayout(freePanel);
    freePanel.setLayout(freePanelLayout);
    freePanelLayout.setHorizontalGroup(
      freePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 0, Short.MAX_VALUE)
    );
    freePanelLayout.setVerticalGroup(
      freePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 0, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 17;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.weightx = 1.0;
    seqPanel.add(freePanel, gridBagConstraints);

    stopButton.setText("Stop");
    stopButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        stopButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 16;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(stopButton, gridBagConstraints);

    jSmoothLabel15.setFocusable(false);
    jSmoothLabel15.setHorizontalAlignment(0);
    jSmoothLabel15.setOpaque(false);
    jSmoothLabel15.setText("Duration");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 8;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(jSmoothLabel15, gridBagConstraints);

    durationViewer.setBorder(null);
    durationViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 9;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 10;
    seqPanel.add(durationViewer, gridBagConstraints);

    jSmoothLabel4.setFocusable(false);
    jSmoothLabel4.setHorizontalAlignment(0);
    jSmoothLabel4.setOpaque(false);
    jSmoothLabel4.setText("Capture");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 10;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(jSmoothLabel4, gridBagConstraints);

    captureViewer.setBorder(null);
    captureViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 11;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 10;
    seqPanel.add(captureViewer, gridBagConstraints);

    jSmoothLabel17.setFocusable(false);
    jSmoothLabel17.setHorizontalAlignment(0);
    jSmoothLabel17.setOpaque(false);
    jSmoothLabel17.setText("Offset");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 12;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(jSmoothLabel17, gridBagConstraints);

    offsetViewer.setBorder(null);
    offsetViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 13;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 10;
    seqPanel.add(offsetViewer, gridBagConstraints);

    jSmoothLabel16.setFocusable(false);
    jSmoothLabel16.setHorizontalAlignment(0);
    jSmoothLabel16.setOpaque(false);
    jSmoothLabel16.setText("Event");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 6;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.weighty = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(0, 5, 0, 0);
    seqPanel.add(jSmoothLabel16, gridBagConstraints);

    eventEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 7;
    gridBagConstraints.gridy = 1;
    seqPanel.add(eventEditor, gridBagConstraints);

    getContentPane().add(seqPanel, java.awt.BorderLayout.CENTER);

    btnPanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

    trigButton.setText("Trigger...");
    trigButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        trigButtonActionPerformed(evt);
      }
    });
    btnPanel.add(trigButton);

    superButton.setText("Super Sequencer...");
    superButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        superButtonActionPerformed(evt);
      }
    });
    btnPanel.add(superButton);

    windowButton.setText("Window...");
    windowButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        windowButtonActionPerformed(evt);
      }
    });
    btnPanel.add(windowButton);

    dismissButton.setLabel("Dismiss");
    dismissButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        dismissButtonActionPerformed(evt);
      }
    });
    btnPanel.add(dismissButton);

    getContentPane().add(btnPanel, java.awt.BorderLayout.SOUTH);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void dismissButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_dismissButtonActionPerformed
    setVisible(false);
  }//GEN-LAST:event_dismissButtonActionPerformed

  private void stopButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_stopButtonActionPerformed
    Utils.execCommand(devName, "SEQ_RESET_S");
  }//GEN-LAST:event_stopButtonActionPerformed

  private void windowButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_windowButtonActionPerformed
    // TODO add your handling code here:
    if( seqWindowPanel==null )
      seqWindowPanel = new SEQWindowPanel(devName);
    seqWindowPanel.setVisible(true);
  }//GEN-LAST:event_windowButtonActionPerformed

  private void trigButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_trigButtonActionPerformed

    if(devName.toLowerCase().contains("horizontal"))
      Utils.showHSEQTrigger();
    else
      Utils.showVSEQTrigger();
    
  }//GEN-LAST:event_trigButtonActionPerformed

  private void superButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_superButtonActionPerformed
    if( superSeqPanel==null )
      superSeqPanel = new SuperSEQPanel(devName);
    superSeqPanel.setVisible(true);    
  }//GEN-LAST:event_superButtonActionPerformed


  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel btnPanel;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer captureViewer;
  private javax.swing.JButton dismissButton;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer durationViewer;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor eventEditor;
  private javax.swing.JPanel freePanel;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel12;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel13;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel14;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel15;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel16;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel17;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel4;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer offsetViewer;
  private javax.swing.JPanel seqPanel;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor startEditor;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer startViewer;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor steadyStateEditor;
  private javax.swing.JButton stopButton;
  private javax.swing.JButton superButton;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor superEditor;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer superViewer;
  private javax.swing.JPanel tablePanel;
  private javax.swing.JButton trigButton;
  private javax.swing.JButton windowButton;
  // End of variables declaration//GEN-END:variables
}
