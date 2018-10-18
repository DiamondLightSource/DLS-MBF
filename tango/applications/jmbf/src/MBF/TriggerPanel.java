/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package MBF;

import static MBF.MainPanel.errWin;
import fr.esrf.tangoatk.core.AttributePolledList;
import fr.esrf.tangoatk.core.AttributeStateEvent;
import fr.esrf.tangoatk.core.ConnectionException;
import fr.esrf.tangoatk.core.EnumScalarEvent;
import fr.esrf.tangoatk.core.ErrorEvent;
import fr.esrf.tangoatk.core.IEnumScalarListener;
import fr.esrf.tangoatk.core.attribute.EnumScalar;
import fr.esrf.tangoatk.core.attribute.NumberScalar;
import fr.esrf.tangoatk.core.attribute.StringScalar;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import java.awt.BorderLayout;
import javax.swing.JPanel;

/**
 *
 * @author pons
 */
public class TriggerPanel extends javax.swing.JFrame implements IEnumScalarListener {

  TriggerInputPanel _inputPanel;
  private AttributePolledList attList;
  private String devName;
  private String target;
  private EnumScalar soft;
  private EnumScalar ext;
  private EnumScalar pm;
  private EnumScalar adc0;
  private EnumScalar adc1;
  private EnumScalar seq0;
  private EnumScalar seq1;
        
  /**
   * Creates new form TriggerPanel
   */
  public TriggerPanel(String devName,String target) {

    initComponents();

    attList = new AttributePolledList();
    attList.addErrorListener(errWin);
    attList.setForceRefresh(false);
    attList.setSynchronizedPeriod(true);
    this.devName = devName;
    this.target = target;

    _inputPanel = TriggerInputPanel.createPanel();
    inputPanel.add(_inputPanel,BorderLayout.CENTER);
    
    try {
      
      EnumScalar mode = (EnumScalar)attList.add(devName+"/TRG_"+target+"_MODE_S");
      modeEditor.setEnumModel(mode);
      EnumScalar trigMode = (EnumScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/TRG_MODE_S");
      trigModeEditor.setEnumModel(trigMode);
      EnumScalar status = (EnumScalar)attList.add(devName+"/TRG_"+target+"_STATUS");
      statusViewer.setModel(status);
      statusViewer.setHorizontalAlignment(0);
      EnumScalar trigStatus = (EnumScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/TRG_STATUS");
      trigStatusViewer.setModel(trigStatus);
      trigStatusViewer.setHorizontalAlignment(0);
      StringScalar trigShared = (StringScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/TRG_SHARED");
      trigSharedViewer.setModel(trigShared);
      trigSharedViewer.setHorizontalAlignment(0);
      EnumScalar scan = (EnumScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/TRG_SOFT_S");
      scanEditor.setEnumModel(scan);
      NumberScalar trigDelay = (NumberScalar)attList.add(devName+"/TRG_"+target+"_DELAY_S");
      triggerDelayEditor.setModel(trigDelay);      

      EnumScalar softEna = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SOFT_EN_S");
      softEnaEditor.setEnumModel(softEna);
      EnumScalar softBlanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SOFT_BL_S");
      softBlankingEditor.setEnumModel(softBlanking);

      EnumScalar extEna = (EnumScalar)attList.add(devName+"/TRG_"+target+"_EXT_EN_S");
      extEnaEditor.setEnumModel(extEna);
      EnumScalar extBlanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_EXT_BL_S");
      extBlankingEditor.setEnumModel(extBlanking);

      EnumScalar pmEna = (EnumScalar)attList.add(devName+"/TRG_"+target+"_PM_EN_S");
      pmEnaEditor.setEnumModel(pmEna);
      EnumScalar pmBlanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_PM_BL_S");
      pmBlankingEditor.setEnumModel(pmBlanking);

      EnumScalar adc0Ena = (EnumScalar)attList.add(devName+"/TRG_"+target+"_ADC0_EN_S");
      adc0EnaEditor.setEnumModel(adc0Ena);
      EnumScalar adc0Blanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_ADC0_BL_S");
      adc0BlankingEditor.setEnumModel(adc0Blanking);

      EnumScalar adc1Ena = (EnumScalar)attList.add(devName+"/TRG_"+target+"_ADC1_EN_S");
      adc1EnaEditor.setEnumModel(adc1Ena);
      EnumScalar adc1Blanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_ADC1_BL_S");
      adc1BlankingEditor.setEnumModel(adc1Blanking);

      EnumScalar seq0Ena = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SEQ0_EN_S");
      seq0EnaEditor.setEnumModel(seq0Ena);
      EnumScalar seq0Blanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SEQ0_BL_S");
      seq0BlankingEditor.setEnumModel(seq0Blanking);

      EnumScalar seq1Ena = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SEQ1_EN_S");
      seq1EnaEditor.setEnumModel(seq1Ena);
      EnumScalar seq1Blanking = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SEQ1_BL_S");
      seq1BlankingEditor.setEnumModel(seq1Blanking);
      
      soft = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SOFT_HIT");
      ext = (EnumScalar)attList.add(devName+"/TRG_"+target+"_EXT_HIT");
      pm = (EnumScalar)attList.add(devName+"/TRG_"+target+"_PM_HIT");
      adc0 = (EnumScalar)attList.add(devName+"/TRG_"+target+"_ADC0_HIT");
      adc1 = (EnumScalar)attList.add(devName+"/TRG_"+target+"_ADC1_HIT");
      seq0 = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SEQ0_HIT");
      seq1 = (EnumScalar)attList.add(devName+"/TRG_"+target+"_SEQ1_HIT");

    } catch (ConnectionException ex) {      
    }

    soft.addEnumScalarListener(this);
    ext.addEnumScalarListener(this);
    pm.addEnumScalarListener(this);
    adc0.addEnumScalarListener(this);
    adc1.addEnumScalarListener(this);
    seq0.addEnumScalarListener(this);
    seq1.addEnumScalarListener(this);
    
    attList.setRefreshInterval(1000);
    setTitle("Trigger Setup " + target + "[" + devName + "]");
    ATKGraphicsUtils.centerFrameOnScreen(this);
    
  }

  public void setVisible(boolean visible) {
    
    if(visible)
      attList.startRefresher();
    else
      attList.stopRefresher();    
    
    // Update visibility of the inputPanel is order to update its refresher
    _inputPanel.visible(visible);
    
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

    armingPanel = new javax.swing.JPanel();
    modeEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    armButton = new javax.swing.JButton();
    disarmButton = new javax.swing.JButton();
    jSmoothLabel1 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    trigModeEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    jSmoothLabel2 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    trigStatusViewer = new fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer();
    statusViewer = new fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer();
    trigSharedViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    sourcesPanel = new javax.swing.JPanel();
    softPanel = new javax.swing.JPanel();
    extPanel = new javax.swing.JPanel();
    pmPanel = new javax.swing.JPanel();
    adc0Panel = new javax.swing.JPanel();
    adc1Panel = new javax.swing.JPanel();
    seq0Panel = new javax.swing.JPanel();
    seq1Panel = new javax.swing.JPanel();
    softEnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    softBlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    extEnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    extBlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    pmEnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    pmBlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    adc0EnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    adc0BlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    adc1EnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    adc1BlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    seq0EnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    seq0BlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    seq1EnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    seq1BlankingEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    jPanel1 = new javax.swing.JPanel();
    inputPanel = new javax.swing.JPanel();
    delayPanel = new javax.swing.JPanel();
    triggerDelayEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSmoothLabel3 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    btnPanel = new javax.swing.JPanel();
    dismissButton = new javax.swing.JButton();
    softTrigPanel = new javax.swing.JPanel();
    softButton = new javax.swing.JButton();
    scanEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();

    getContentPane().setLayout(new java.awt.GridBagLayout());

    armingPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Arming"));
    armingPanel.setLayout(new java.awt.GridBagLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(modeEditor, gridBagConstraints);

    armButton.setText("Arm");
    armButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        armButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(armButton, gridBagConstraints);

    disarmButton.setText("Disarm");
    disarmButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        disarmButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(disarmButton, gridBagConstraints);

    jSmoothLabel1.setOpaque(false);
    jSmoothLabel1.setText("Shared control");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(jSmoothLabel1, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(trigModeEditor, gridBagConstraints);

    jSmoothLabel2.setOpaque(false);
    jSmoothLabel2.setText("Shared targets");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(jSmoothLabel2, gridBagConstraints);

    trigStatusViewer.setBorder(null);
    trigStatusViewer.setText("-----");
    trigStatusViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(trigStatusViewer, gridBagConstraints);

    statusViewer.setBorder(null);
    statusViewer.setText("-----");
    statusViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(statusViewer, gridBagConstraints);

    trigSharedViewer.setBorder(null);
    trigSharedViewer.setText("-----");
    trigSharedViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.gridwidth = 3;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    armingPanel.add(trigSharedViewer, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(armingPanel, gridBagConstraints);

    sourcesPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Sources"));
    sourcesPanel.setLayout(new java.awt.GridBagLayout());

    softPanel.setBackground(new java.awt.Color(128, 128, 128));
    softPanel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    softPanel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout softPanelLayout = new javax.swing.GroupLayout(softPanel);
    softPanel.setLayout(softPanelLayout);
    softPanelLayout.setHorizontalGroup(
      softPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    softPanelLayout.setVerticalGroup(
      softPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(softPanel, gridBagConstraints);

    extPanel.setBackground(new java.awt.Color(128, 128, 128));
    extPanel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    extPanel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout extPanelLayout = new javax.swing.GroupLayout(extPanel);
    extPanel.setLayout(extPanelLayout);
    extPanelLayout.setHorizontalGroup(
      extPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    extPanelLayout.setVerticalGroup(
      extPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(extPanel, gridBagConstraints);

    pmPanel.setBackground(new java.awt.Color(128, 128, 128));
    pmPanel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    pmPanel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout pmPanelLayout = new javax.swing.GroupLayout(pmPanel);
    pmPanel.setLayout(pmPanelLayout);
    pmPanelLayout.setHorizontalGroup(
      pmPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    pmPanelLayout.setVerticalGroup(
      pmPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(pmPanel, gridBagConstraints);

    adc0Panel.setBackground(new java.awt.Color(128, 128, 128));
    adc0Panel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    adc0Panel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout adc0PanelLayout = new javax.swing.GroupLayout(adc0Panel);
    adc0Panel.setLayout(adc0PanelLayout);
    adc0PanelLayout.setHorizontalGroup(
      adc0PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    adc0PanelLayout.setVerticalGroup(
      adc0PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(adc0Panel, gridBagConstraints);

    adc1Panel.setBackground(new java.awt.Color(128, 128, 128));
    adc1Panel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    adc1Panel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout adc1PanelLayout = new javax.swing.GroupLayout(adc1Panel);
    adc1Panel.setLayout(adc1PanelLayout);
    adc1PanelLayout.setHorizontalGroup(
      adc1PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    adc1PanelLayout.setVerticalGroup(
      adc1PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(adc1Panel, gridBagConstraints);

    seq0Panel.setBackground(new java.awt.Color(128, 128, 128));
    seq0Panel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    seq0Panel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout seq0PanelLayout = new javax.swing.GroupLayout(seq0Panel);
    seq0Panel.setLayout(seq0PanelLayout);
    seq0PanelLayout.setHorizontalGroup(
      seq0PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    seq0PanelLayout.setVerticalGroup(
      seq0PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 5;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(seq0Panel, gridBagConstraints);

    seq1Panel.setBackground(new java.awt.Color(128, 128, 128));
    seq1Panel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    seq1Panel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout seq1PanelLayout = new javax.swing.GroupLayout(seq1Panel);
    seq1Panel.setLayout(seq1PanelLayout);
    seq1PanelLayout.setHorizontalGroup(
      seq1PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 23, Short.MAX_VALUE)
    );
    seq1PanelLayout.setVerticalGroup(
      seq1PanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 22, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 6;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(seq1Panel, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(softEnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(softBlankingEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(extEnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(extBlankingEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(pmEnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(pmBlankingEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(adc0EnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(adc0BlankingEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(adc1EnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 4;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(adc1BlankingEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 5;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(seq0EnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 5;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(seq0BlankingEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 6;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(seq1EnaEditor, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 6;
    gridBagConstraints.ipadx = 10;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    sourcesPanel.add(seq1BlankingEditor, gridBagConstraints);

    javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
    jPanel1.setLayout(jPanel1Layout);
    jPanel1Layout.setHorizontalGroup(
      jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 0, Short.MAX_VALUE)
    );
    jPanel1Layout.setVerticalGroup(
      jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 0, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 3;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.weightx = 1.0;
    sourcesPanel.add(jPanel1, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    getContentPane().add(sourcesPanel, gridBagConstraints);

    inputPanel.setLayout(new java.awt.BorderLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    getContentPane().add(inputPanel, gridBagConstraints);

    delayPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Trigger delay"));
    delayPanel.setLayout(new java.awt.GridBagLayout());

    triggerDelayEditor.setOpaque(false);
    delayPanel.add(triggerDelayEditor, new java.awt.GridBagConstraints());

    jSmoothLabel3.setOpaque(false);
    jSmoothLabel3.setText("turns");
    delayPanel.add(jSmoothLabel3, new java.awt.GridBagConstraints());

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weighty = 1.0;
    getContentPane().add(delayPanel, gridBagConstraints);

    btnPanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

    dismissButton.setText("Dismiss");
    dismissButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        dismissButtonActionPerformed(evt);
      }
    });
    btnPanel.add(dismissButton);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    getContentPane().add(btnPanel, gridBagConstraints);

    softTrigPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Soft Trig"));
    softTrigPanel.setLayout(new java.awt.GridBagLayout());

    softButton.setText("Soft");
    softButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        softButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 7;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 0, 2, 0);
    softTrigPanel.add(softButton, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 8;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 0, 2, 0);
    softTrigPanel.add(scanEditor, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    getContentPane().add(softTrigPanel, gridBagConstraints);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void dismissButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_dismissButtonActionPerformed
    setVisible(false);    
  }//GEN-LAST:event_dismissButtonActionPerformed

  private void softButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_softButtonActionPerformed
    Utils.execCommand(MainPanel.mfdbkGEpicsDevName, "TRG_SOFT_CMD");
  }//GEN-LAST:event_softButtonActionPerformed

  private void armButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_armButtonActionPerformed
    Utils.execCommand(devName, "TRG_"+target+"_ARM_S");    
  }//GEN-LAST:event_armButtonActionPerformed

  private void disarmButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_disarmButtonActionPerformed
    Utils.execCommand(devName, "TRG_"+target+"_DISARM_S");
  }//GEN-LAST:event_disarmButtonActionPerformed


  // Variables declaration - do not modify//GEN-BEGIN:variables
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor adc0BlankingEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor adc0EnaEditor;
  private javax.swing.JPanel adc0Panel;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor adc1BlankingEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor adc1EnaEditor;
  private javax.swing.JPanel adc1Panel;
  private javax.swing.JButton armButton;
  private javax.swing.JPanel armingPanel;
  private javax.swing.JPanel btnPanel;
  private javax.swing.JPanel delayPanel;
  private javax.swing.JButton disarmButton;
  private javax.swing.JButton dismissButton;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor extBlankingEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor extEnaEditor;
  private javax.swing.JPanel extPanel;
  private javax.swing.JPanel inputPanel;
  private javax.swing.JPanel jPanel1;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel1;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel2;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel3;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor modeEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor pmBlankingEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor pmEnaEditor;
  private javax.swing.JPanel pmPanel;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor scanEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor seq0BlankingEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor seq0EnaEditor;
  private javax.swing.JPanel seq0Panel;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor seq1BlankingEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor seq1EnaEditor;
  private javax.swing.JPanel seq1Panel;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor softBlankingEditor;
  private javax.swing.JButton softButton;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor softEnaEditor;
  private javax.swing.JPanel softPanel;
  private javax.swing.JPanel softTrigPanel;
  private javax.swing.JPanel sourcesPanel;
  private fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer statusViewer;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor trigModeEditor;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer trigSharedViewer;
  private fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer trigStatusViewer;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor triggerDelayEditor;
  // End of variables declaration//GEN-END:variables

  private void setColor(JPanel panel,String value) {
    
    if(value.equalsIgnoreCase("Yes")) {
      panel.setBackground(ATKConstant.getColor4State("ON"));
    } else if(value.equalsIgnoreCase("No")) {
      panel.setBackground(ATKConstant.getColor4State("OFF"));
    } else {
      panel.setBackground(ATKConstant.getColor4State("UNKNOWN"));
    }
    
  }

  @Override
  public void enumScalarChange(EnumScalarEvent ese) {
    Object src =ese.getSource();
    String value = ese.getValue();    
    if(src==soft) {
      setColor(softPanel,value);
    } else if(src==ext) {
      setColor(extPanel,value);      
    } else if(src==pm) {
      setColor(pmPanel,value);            
    } else if(src==adc0) {
      setColor(adc0Panel,value);      
    } else if(src==adc1) {
      setColor(adc1Panel,value);            
    } else if(src==seq0) {
      setColor(seq0Panel,value);                  
    } else if(src==seq1) {
      setColor(seq1Panel,value);      
    }
  }

  @Override
  public void stateChange(AttributeStateEvent ase) {
  }

  @Override
  public void errorChange(ErrorEvent ee) {
    Object src =ee.getSource();
    if(src==soft) {
      setColor(softPanel,"");
    } else if(src==ext) {
      setColor(extPanel,"");      
    } else if(src==pm) {
      setColor(pmPanel,"");            
    } else if(src==adc0) {
      setColor(adc0Panel,"");      
    } else if(src==adc1) {
      setColor(adc1Panel,"");            
    } else if(src==seq0) {
      setColor(seq0Panel,"");                  
    } else if(src==seq1) {
      setColor(seq1Panel,"");      
    }
  }
  
}
