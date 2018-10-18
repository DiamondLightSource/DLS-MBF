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
import fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.JSmoothLabel;
import java.awt.Color;
import java.awt.GridBagConstraints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JButton;
import javax.swing.JPanel;

/**
 *
 * @author pons
 */
public class FIRSetupPanel extends javax.swing.JFrame {

  private AttributePolledList attList;
  private String devName;
  private BunchControlPanel bunchControlPanel = null;
  
  class FIRLine {
    
    JSmoothLabel idxLabel;

    NumberScalar cycle;
    NumberScalarWheelEditor cycleEditor;
    NumberScalar size;
    NumberScalarWheelEditor sizeEditor;
    NumberScalar phase;
    NumberScalarWheelEditor phaseEditor;
    EnumScalar setup;
    EnumScalarComboEditor setupEditor;
    JButton waveformButton;
    
    FIRWaveformPanel waveformPanel = null;
    final int firIdx;
    
    FIRLine(int idx,Color background,JPanel parentPanel) {

      GridBagConstraints gbc = new GridBagConstraints();
      gbc.fill = GridBagConstraints.HORIZONTAL;
      gbc.gridy = idx+1;
      firIdx = idx;
      
      // -------------------
      idxLabel = new JSmoothLabel();
      idxLabel.setText(Integer.toString(idx));
      idxLabel.setOpaque(false);
      gbc.ipadx = 5;
      gbc.gridx = 0;
      gbc.insets.right=2;
      gbc.insets.left=2;
      parentPanel.add(idxLabel,gbc);
            
      // -------------------
      cycleEditor = new NumberScalarWheelEditor();
      cycleEditor.setOpaque(false);
      gbc.gridx = 1;
      parentPanel.add(cycleEditor,gbc);
      
      // -------------------
      sizeEditor = new NumberScalarWheelEditor();
      sizeEditor.setOpaque(false);
      gbc.gridx = 2;
      parentPanel.add(sizeEditor,gbc);
      
      // -------------------
      phaseEditor = new NumberScalarWheelEditor();
      phaseEditor.setOpaque(false);
      gbc.gridx = 3;
      parentPanel.add(phaseEditor,gbc);
      
      // -------------------      
      setupEditor = new EnumScalarComboEditor();
      gbc.gridx = 4;
      parentPanel.add(setupEditor,gbc);

      // -------------------
      waveformButton = new JButton("Waveform");
      waveformButton.addActionListener(new ActionListener(){
        public void actionPerformed(ActionEvent e) {
          if(waveformPanel==null)
            waveformPanel = new FIRWaveformPanel(devName,firIdx);
          waveformPanel.setVisible(true);
        }
      });
      gbc.gridx = 5;
      parentPanel.add(waveformButton,gbc);
              
    }
    
    
    void setModel(String devName,AttributePolledList attList,int idx) throws ConnectionException {
      
      cycle = (NumberScalar)attList.add(devName+"/FIR_"+idx+"_CYCLES_S");
      cycleEditor.setModel(cycle);
      size = (NumberScalar)attList.add(devName+"/FIR_"+idx+"_LENGTH_S");
      sizeEditor.setModel(size);
      phase = (NumberScalar)attList.add(devName+"/FIR_"+idx+"_PHASE_S");
      phaseEditor.setModel(phase);      
      setup = (EnumScalar)attList.add(devName+"/FIR_"+idx+"_USEWF_S");
      setupEditor.setEnumModel(setup);
            
    }
    
    
  }


  /**
   * Creates new form FIRSetupPanel
   */
  public FIRSetupPanel(String devName) {
    
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
      centerPanel.add(Utils.createLabel("#",""),gbc);              
      gbc.gridx = 1;
      centerPanel.add(Utils.createLabel("FIR freq","cycles"),gbc);              
      gbc.gridx = 2;
      centerPanel.add(Utils.createLabel("Size",""),gbc);              
      gbc.gridx = 3;
      centerPanel.add(Utils.createLabel("Phase","deg"),gbc);              
      gbc.gridx = 4;
      centerPanel.add(Utils.createLabel("Setup",""),gbc);              
      gbc.gridx = 5;
      centerPanel.add(Utils.createLabel("",""),gbc);              
      
      
      for(int i=0;i<4;i++) {
        FIRLine l = new FIRLine(i,getBackground(),centerPanel);
        l.setModel(devName, attList, i);
      }
            
    } catch (ConnectionException ex) {      
    }
        
    attList.setRefreshInterval(1000);
    
    setTitle("FIR Setup [" + devName + "]");
    ATKGraphicsUtils.centerFrameOnScreen(this);
    
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

    centerPanel = new javax.swing.JPanel();
    btnPanel = new javax.swing.JPanel();
    controlButton = new javax.swing.JButton();
    dismissButton = new javax.swing.JButton();

    setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);

    centerPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    centerPanel.setLayout(new java.awt.GridBagLayout());
    getContentPane().add(centerPanel, java.awt.BorderLayout.CENTER);

    btnPanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

    controlButton.setText("Bunch Control");
    controlButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        controlButtonActionPerformed(evt);
      }
    });
    btnPanel.add(controlButton);

    dismissButton.setText("Dismiss");
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

  private void controlButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_controlButtonActionPerformed
    if( bunchControlPanel==null )
      bunchControlPanel = new BunchControlPanel(devName);
    bunchControlPanel.setVisible(true);    
  }//GEN-LAST:event_controlButtonActionPerformed


  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel btnPanel;
  private javax.swing.JPanel centerPanel;
  private javax.swing.JButton controlButton;
  private javax.swing.JButton dismissButton;
  // End of variables declaration//GEN-END:variables
}
