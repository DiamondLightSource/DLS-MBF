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
import fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor;
import fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer;
import fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.JSmoothLabel;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JPanel;

/**
 *
 * @author pons
 */
public class DETSetupPanel extends javax.swing.JFrame implements IEnumScalarListener {

  private AttributePolledList attList;
  private String devName;
  private EnumScalar underrun;
  
  
  class DETLine implements IEnumScalarListener {
    
    JSmoothLabel idxLabel;
    
    
    EnumScalar enable;
    EnumScalarComboEditor enableEditor;
    EnumScalar scaling;
    EnumScalarComboEditor scalingEditor;
    NumberScalar count;
    SimpleScalarViewer countViewer;
    NumberScalar maxPower;
    SimpleScalarViewer maxPowerViewer;
    EnumScalar overflow;
    SimpleEnumScalarViewer overflowViewer;
    JPanel overflowPanel;    
    JButton waveformsButton;
    JButton bunchesButton;
    
    final int detIdx;
    private DETWaveformPanel waveformPanel = null; 
    private PatternEditorFrame bunchSelectPanel = null;
    
    DETLine(int idx,Color background,JPanel parentPanel) {

      GridBagConstraints gbc = new GridBagConstraints();
      gbc.fill = GridBagConstraints.HORIZONTAL;
      gbc.gridy = idx+1;
      detIdx = idx;
      
      // -------------------
      idxLabel = new JSmoothLabel();
      idxLabel.setText("#"+Integer.toString(idx));
      idxLabel.setOpaque(false);
      gbc.ipadx = 5;
      gbc.gridx = 0;
      gbc.insets.right=2;
      gbc.insets.left=2;
      parentPanel.add(idxLabel,gbc);
            
      // -------------------
      enableEditor = new EnumScalarComboEditor();
      gbc.gridx = 1;
      parentPanel.add(enableEditor,gbc);

      // -------------------
      scalingEditor = new EnumScalarComboEditor();
      gbc.gridx = 2;
      parentPanel.add(scalingEditor,gbc);
      
      // -------------------
      countViewer = new SimpleScalarViewer();
      countViewer.setOpaque(false);
      countViewer.setBorder(null);
      gbc.gridx = 3;
      parentPanel.add(countViewer,gbc);
      
      // -------------------
      maxPowerViewer = new SimpleScalarViewer();
      maxPowerViewer.setOpaque(false);
      maxPowerViewer.setBorder(null);
      gbc.gridx = 4;
      parentPanel.add(maxPowerViewer,gbc);
      
      
      // -------------------
      overflowPanel = new JPanel();
      overflowPanel.setBorder(BorderFactory.createLineBorder(Color.BLACK));
      overflowPanel.setBackground(ATKConstant.getColor4State("UNKNOWN"));
      overflowPanel.setPreferredSize(new Dimension(20,20));
      gbc.gridx = 5;
      parentPanel.add(overflowPanel,gbc);
      
      // -------------------
      overflowViewer = new SimpleEnumScalarViewer();
      overflowViewer.setOpaque(false);
      overflowViewer.setBorder(null);
      overflowViewer.setHorizontalAlignment(SimpleEnumScalarViewer.LEFT_ALIGNMENT);
      gbc.ipadx = 40;
      gbc.gridx = 6;
      parentPanel.add(overflowViewer,gbc);
      gbc.ipadx = 0;

      // -------------------
      waveformsButton = new JButton("Waveforms");
      waveformsButton.addActionListener(new ActionListener(){
        public void actionPerformed(ActionEvent e) {
          if( waveformPanel==null )
            waveformPanel = new DETWaveformPanel(devName,detIdx);
          waveformPanel.setVisible(true);
        }
      });
      gbc.gridx = 7;
      parentPanel.add(waveformsButton,gbc);
      
      // -------------------
      bunchesButton = new JButton("Bunches");
      bunchesButton.addActionListener(new ActionListener(){
        public void actionPerformed(ActionEvent e) {
          if( bunchSelectPanel==null ) {
            bunchSelectPanel = new PatternEditorFrame(PatternEditorFrame.INT_TYPE,devName+"/DET_"+detIdx+"_BUNCHES_S");
            bunchSelectPanel.setVisible(true);
          } else {
            bunchSelectPanel.refresh();
            bunchSelectPanel.setVisible(true);
          }
        }
      });
      gbc.gridx = 8;
      parentPanel.add(bunchesButton,gbc);
              
    }
    
    
    void setModel(String devName,AttributePolledList attList,int idx) throws ConnectionException {
      
      enable = (EnumScalar)attList.add(devName+"/DET_"+idx+"_ENABLE_S");
      enableEditor.setEnumModel(enable);
      scaling = (EnumScalar)attList.add(devName+"/DET_"+idx+"_SCALING_S");
      scalingEditor.setEnumModel(scaling);      
      count = (NumberScalar)attList.add(devName+"/DET_"+idx+"_COUNT");
      countViewer.setModel(count);
      maxPower = (NumberScalar)attList.add(devName+"/DET_"+idx+"_MAX_POWER");
      maxPowerViewer.setModel(maxPower);      
      overflow = (EnumScalar)attList.add(devName+"/DET_"+idx+"_OUT_OVF");
      overflowViewer.setModel(overflow);
      overflow.addEnumScalarListener(this);
            
    }

    @Override
    public void enumScalarChange(EnumScalarEvent ese) {
      int value = overflow.getShortValueFromEnumScalar(ese.getValue());
      if(value==0)
        overflowPanel.setBackground(ATKConstant.getColor4State("ON"));
      else
        overflowPanel.setBackground(ATKConstant.getColor4State("FAULT"));      
    }

    @Override
    public void stateChange(AttributeStateEvent ase) {
    }

    @Override
    public void errorChange(ErrorEvent ee) {
      overflowPanel.setBackground(ATKConstant.getColor4State("UNKNOWN"));              
    }    
    
  }
  
  /**
   * Creates new form DetectorPanel
   */
  public DETSetupPanel(String devName) {

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
      detectorPanel.add(Utils.createLabel("#",""),gbc);              
      gbc.gridx = 1;
      detectorPanel.add(Utils.createLabel("Enable",""),gbc);              
      gbc.gridx = 2;
      detectorPanel.add(Utils.createLabel("Gain",""),gbc);              
      gbc.gridx = 3;
      detectorPanel.add(Utils.createLabel("Count",""),gbc);              
      gbc.gridx = 4;
      detectorPanel.add(Utils.createLabel("Max power",""),gbc);              
      gbc.gridx = 5;
      gbc.gridwidth = 2;
      detectorPanel.add(Utils.createLabel("Overflow",""),gbc);              
      gbc.gridx = 7;
      gbc.gridwidth = 1;
      detectorPanel.add(Utils.createLabel("",""),gbc);              
      gbc.gridx = 8;
      detectorPanel.add(Utils.createLabel("",""),gbc);              
      
      
      for(int i=0;i<4;i++) {
        DETLine l = new DETLine(i,getBackground(),detectorPanel);
        l.setModel(devName, attList, i);
      }
      
      EnumScalar source = (EnumScalar)attList.add(devName+"/DET_SELECT_S");
      sourceEditor.setEnumModel(source);
      EnumScalar waveform = (EnumScalar)attList.add(devName+"/DET_FILL_WAVEFORM_S");
      waveformEditor.setEnumModel(waveform);
      NumberScalar firDelay = (NumberScalar)attList.add(devName+"/DET_FIR_DELAY_S");
      firDelayEditor.setModel(firDelay);
      NumberScalar captured = (NumberScalar)attList.add(devName+"/DET_SAMPLES");
      capturedViewer.setModel(captured);
      underrun = (EnumScalar)attList.add(devName+"/DET_UNDERRUN");
      underrunViewer.setModel(underrun);
      underrun.addEnumScalarListener(this);      
      
    } catch (ConnectionException ex) {      
    }
        
    attList.setRefreshInterval(1000);
    
    setTitle("Detector Setup [" + devName + "]");
    ATKGraphicsUtils.centerFrameOnScreen(this);
    
  }
  
  
  public void setVisible(boolean visible) {
    if(visible)
      attList.startRefresher();
    else
      attList.stopRefresher();    
    super.setVisible(visible);
  }
  
  @Override
  public void enumScalarChange(EnumScalarEvent ese) {
      int value = underrun.getShortValueFromEnumScalar(ese.getValue());
      if(value==0)
        underrunPanel.setBackground(ATKConstant.getColor4State("ON"));
      else
        underrunPanel.setBackground(ATKConstant.getColor4State("FAULT"));      
  }

  @Override
  public void stateChange(AttributeStateEvent ase) {
  }

  @Override
  public void errorChange(ErrorEvent ee) {
        underrunPanel.setBackground(ATKConstant.getColor4State("UNKNOWN"));
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

    detectorPanel = new javax.swing.JPanel();
    setupPanel = new javax.swing.JPanel();
    jSmoothLabel1 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    sourceEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    jSmoothLabel2 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    firDelayEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSmoothLabel3 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    jSmoothLabel4 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    capturedViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel5 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    jSmoothLabel6 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    waveformEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    uderrunGroupPanel = new javax.swing.JPanel();
    underrunPanel = new javax.swing.JPanel();
    underrunViewer = new fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer();
    btnPanel = new javax.swing.JPanel();
    dismissButton = new javax.swing.JButton();

    getContentPane().setLayout(new java.awt.GridBagLayout());

    detectorPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Detectors"));
    detectorPanel.setLayout(new java.awt.GridBagLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(detectorPanel, gridBagConstraints);

    setupPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Setup"));
    setupPanel.setLayout(new java.awt.GridBagLayout());

    jSmoothLabel1.setHorizontalAlignment(0);
    jSmoothLabel1.setOpaque(false);
    jSmoothLabel1.setText("Source");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    setupPanel.add(jSmoothLabel1, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    setupPanel.add(sourceEditor, gridBagConstraints);

    jSmoothLabel2.setOpaque(false);
    jSmoothLabel2.setText("FIR delay");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridheight = 2;
    gridBagConstraints.insets = new java.awt.Insets(0, 4, 0, 0);
    setupPanel.add(jSmoothLabel2, gridBagConstraints);

    firDelayEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridheight = 2;
    setupPanel.add(firDelayEditor, gridBagConstraints);

    jSmoothLabel3.setOpaque(false);
    jSmoothLabel3.setText("turns");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridheight = 2;
    setupPanel.add(jSmoothLabel3, gridBagConstraints);

    jSmoothLabel4.setOpaque(false);
    jSmoothLabel4.setText("Captured");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 5;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.gridheight = 2;
    gridBagConstraints.insets = new java.awt.Insets(0, 4, 0, 0);
    setupPanel.add(jSmoothLabel4, gridBagConstraints);

    capturedViewer.setBorder(null);
    capturedViewer.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
    capturedViewer.setText("-----");
    capturedViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 6;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.gridheight = 2;
    gridBagConstraints.ipadx = 30;
    setupPanel.add(capturedViewer, gridBagConstraints);

    jSmoothLabel5.setOpaque(false);
    jSmoothLabel5.setText("Underrun");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 7;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.gridheight = 2;
    gridBagConstraints.insets = new java.awt.Insets(0, 4, 0, 0);
    setupPanel.add(jSmoothLabel5, gridBagConstraints);

    jSmoothLabel6.setHorizontalAlignment(0);
    jSmoothLabel6.setOpaque(false);
    jSmoothLabel6.setText("Waveforms");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    setupPanel.add(jSmoothLabel6, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    setupPanel.add(waveformEditor, gridBagConstraints);

    uderrunGroupPanel.setLayout(new java.awt.GridBagLayout());

    underrunPanel.setBackground(new java.awt.Color(153, 153, 153));
    underrunPanel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    underrunPanel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout underrunPanelLayout = new javax.swing.GroupLayout(underrunPanel);
    underrunPanel.setLayout(underrunPanelLayout);
    underrunPanelLayout.setHorizontalGroup(
      underrunPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 0, Short.MAX_VALUE)
    );
    underrunPanelLayout.setVerticalGroup(
      underrunPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 16, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    uderrunGroupPanel.add(underrunPanel, gridBagConstraints);

    underrunViewer.setBorder(null);
    underrunViewer.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
    underrunViewer.setText("-----");
    underrunViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.insets = new java.awt.Insets(0, 4, 0, 0);
    uderrunGroupPanel.add(underrunViewer, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 8;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.gridheight = 2;
    setupPanel.add(uderrunGroupPanel, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(setupPanel, gridBagConstraints);

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
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(btnPanel, gridBagConstraints);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void dismissButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_dismissButtonActionPerformed
    setVisible(false);
  }//GEN-LAST:event_dismissButtonActionPerformed

  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel btnPanel;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer capturedViewer;
  private javax.swing.JPanel detectorPanel;
  private javax.swing.JButton dismissButton;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor firDelayEditor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel1;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel2;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel3;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel4;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel5;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel6;
  private javax.swing.JPanel setupPanel;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor sourceEditor;
  private javax.swing.JPanel uderrunGroupPanel;
  private javax.swing.JPanel underrunPanel;
  private fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer underrunViewer;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor waveformEditor;
  // End of variables declaration//GEN-END:variables
}
