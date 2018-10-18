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
import fr.esrf.tangoatk.core.attribute.StringScalar;
import fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer;
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
public class BunchControlPanel extends javax.swing.JFrame {

  private AttributePolledList attList;
  private String devName;

  class BankLine {
    
    JSmoothLabel idxLabel;

    StringScalar bunchState;
    SimpleScalarViewer bunchStateViewer;
    StringScalar dacOutState;
    SimpleScalarViewer dacOutStateViewer;
    StringScalar dacGainState;
    SimpleScalarViewer dacGainStateViewer;    
    JButton setupButton;    
    final int bankIdx;
    BunchSelectPanel bunchPanel = null;
            
    BankLine(int idx,Color background,JPanel parentPanel) {

      GridBagConstraints gbc = new GridBagConstraints();
      gbc.fill = GridBagConstraints.HORIZONTAL;
      gbc.gridy = idx+1;
      bankIdx = idx;
      
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
      bunchStateViewer = new SimpleScalarViewer();
      bunchStateViewer.setOpaque(false);
      bunchStateViewer.setBorder(null);
      gbc.gridx = 1;
      parentPanel.add(bunchStateViewer,gbc);
      
      // -------------------
      dacOutStateViewer = new SimpleScalarViewer();
      dacOutStateViewer.setOpaque(false);
      dacOutStateViewer.setBorder(null);
      gbc.gridx = 2;
      parentPanel.add(dacOutStateViewer,gbc);
      
      // -------------------
      dacGainStateViewer = new SimpleScalarViewer();
      dacGainStateViewer.setOpaque(false);
      dacGainStateViewer.setBorder(null);
      gbc.gridx = 3;
      parentPanel.add(dacGainStateViewer,gbc);
      
      // -------------------
      setupButton = new JButton("Setup");
      setupButton.addActionListener(new ActionListener(){
        public void actionPerformed(ActionEvent e) {
          if(bunchPanel==null)
            bunchPanel = new BunchSelectPanel(devName,bankIdx);
          bunchPanel.setVisible(true);
        }
      });
      gbc.gridx = 4;
      parentPanel.add(setupButton,gbc);
              
    }
    
    
    void setModel(String devName,AttributePolledList attList,int idx) throws ConnectionException {

      bunchState = (StringScalar)attList.add(devName+"/BUN_"+idx+"_FIRWF_STA");
      bunchStateViewer.setModel(bunchState);
      dacOutState = (StringScalar)attList.add(devName+"/BUN_"+idx+"_OUTWF_STA");
      dacOutStateViewer.setModel(dacOutState);
      dacGainState = (StringScalar)attList.add(devName+"/BUN_"+idx+"_GAINWF_STA");
      dacGainStateViewer.setModel(dacGainState);
            
    }
    
    
  }

  /**
   * Creates new form BunchControl
   */
  public BunchControlPanel(String devName) {
    
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
      bunchBankPanel.add(Utils.createLabel("Bank",""),gbc);              
      gbc.gridx = 1;
      bunchBankPanel.add(Utils.createLabel("FIR select",""),gbc);              
      gbc.gridx = 2;
      bunchBankPanel.add(Utils.createLabel("DAC Out status",""),gbc);              
      gbc.gridx = 3;
      bunchBankPanel.add(Utils.createLabel("DAC gain",""),gbc);              
      gbc.gridx = 4;
      bunchBankPanel.add(Utils.createLabel("",""),gbc);              
      
      
      for(int i=0;i<4;i++) {
        BankLine l = new BankLine(i,getBackground(),bunchBankPanel);
        l.setModel(devName, attList, i);
      }
      
      NumberScalar freq = (NumberScalar)attList.add(devName+"/NCO_FREQ_S");
      ncoFreqEditor.setModel(freq); 
      EnumScalar gain = (EnumScalar)attList.add(devName+"/NCO_GAIN_S");
      ncoEditor.setEnumModel(gain);      
      EnumScalar gainEna = (EnumScalar)attList.add(devName+"/NCO_ENABLE_S");
      ncoEnaEditor.setEnumModel(gainEna);      
      
    } catch (ConnectionException ex) {      
    }
        
    attList.setRefreshInterval(1000);
    
    setTitle("Bunch Control [" + devName + "]");
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
    java.awt.GridBagConstraints gridBagConstraints;

    bunchBankPanel = new javax.swing.JPanel();
    ncoPanel = new javax.swing.JPanel();
    jSmoothLabel16 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    ncoFreqEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSmoothLabel12 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    ncoEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    ncoEnaEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    btnPanel = new javax.swing.JPanel();
    dismissButton = new javax.swing.JButton();

    getContentPane().setLayout(new java.awt.GridBagLayout());

    bunchBankPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Bunch Bank"));
    bunchBankPanel.setLayout(new java.awt.GridBagLayout());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(bunchBankPanel, gridBagConstraints);

    ncoPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("NCO"));

    jSmoothLabel16.setFocusable(false);
    jSmoothLabel16.setHorizontalAlignment(0);
    jSmoothLabel16.setOpaque(false);
    jSmoothLabel16.setText("Frequency");
    ncoPanel.add(jSmoothLabel16);

    ncoFreqEditor.setOpaque(false);
    ncoPanel.add(ncoFreqEditor);

    jSmoothLabel12.setFocusable(false);
    jSmoothLabel12.setHorizontalAlignment(0);
    jSmoothLabel12.setOpaque(false);
    jSmoothLabel12.setText("Gain");
    ncoPanel.add(jSmoothLabel12);
    ncoPanel.add(ncoEditor);
    ncoPanel.add(ncoEnaEditor);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(ncoPanel, gridBagConstraints);

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
    gridBagConstraints.weighty = 1.0;
    getContentPane().add(btnPanel, gridBagConstraints);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void dismissButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_dismissButtonActionPerformed
    setVisible(false);
  }//GEN-LAST:event_dismissButtonActionPerformed

  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel btnPanel;
  private javax.swing.JPanel bunchBankPanel;
  private javax.swing.JButton dismissButton;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel12;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel16;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor ncoEditor;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor ncoEnaEditor;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor ncoFreqEditor;
  private javax.swing.JPanel ncoPanel;
  // End of variables declaration//GEN-END:variables
}
