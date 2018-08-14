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
import fr.esrf.tangoatk.core.ErrorEvent;
import fr.esrf.tangoatk.core.INumberScalarListener;
import fr.esrf.tangoatk.core.NumberScalarEvent;
import fr.esrf.tangoatk.core.attribute.EnumScalar;
import fr.esrf.tangoatk.core.attribute.NumberScalar;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import java.awt.Color;
import java.awt.GridLayout;
import javax.swing.BorderFactory;
import javax.swing.JPanel;

/**
 *
 * @author pons
 */
public class DelayPanel extends javax.swing.JFrame implements INumberScalarListener {

  private AttributePolledList attList;
  NumberScalar fifo;
  JPanel[] fifoPanels;

  /**
   * Creates new form DelayPanel
   */
  public DelayPanel() {
    
    initComponents();
    
    attList = new AttributePolledList();
    attList.addErrorListener(errWin);

    try {
      
      NumberScalar fine = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_DAC_FINE_DELAY_S");
      fineEditor.setModel(fine);
      NumberScalar coarse = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_DAC_COARSE_DELAY_S");
      coarseEditor.setModel(coarse);
      NumberScalar total = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_DAC_DELAY_PS");
      totalViewer.setModel(total);
      fifo = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_DAC_FIFO");
      fifo.addNumberScalarListener(this);
      
      NumberScalar bunch = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_TURN_OFFSET_S");
      bunchEditor.setModel(bunch);
      EnumScalar status = (EnumScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_TURN_STATUS");
      statusViewer.setModel(status);
      NumberScalar skew = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_TURN_DELAY_S");
      skewEditor.setModel(skew);
      NumberScalar turnDelay = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_TURN_DELAY_PS");
      turnDelayViewer.setModel(turnDelay);
      NumberScalar errors = (NumberScalar)attList.add(MainPanel.mfdbkGEpicsDevName+"/DLY_TURN_RATE");
      errorViewer.setModel(errors);      
      
    } catch (ConnectionException ex) {      
    }
    
    fifoPanel.setLayout(new GridLayout(1,8));
    fifoPanels = new JPanel[8];
    for(int i=0;i<8;i++) {
      fifoPanels[i] = new JPanel();
      fifoPanels[i].setBorder(BorderFactory.createLineBorder(Color.BLACK, 1));
      fifoPanels[i].setBackground(ATKConstant.getColor4State("UNKNOWN"));
      fifoPanel.add(fifoPanels[i]);
    }
        
    attList.setRefreshInterval(1000);
    
    setTitle("Delay Setup");
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

    dacDelayPanel = new javax.swing.JPanel();
    jSmoothLabel1 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    fineEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSmoothLabel2 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    coarseEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    stepButton = new javax.swing.JButton();
    resetButton = new javax.swing.JButton();
    jSmoothLabel3 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    totalViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel4 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    fifoPanel = new javax.swing.JPanel();
    turnClockPanel = new javax.swing.JPanel();
    syncButton = new javax.swing.JButton();
    jSmoothLabel5 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    bunchEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    jSmoothLabel6 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    skewEditor = new fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor();
    turnDelayViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel7 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    errorViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    statusViewer = new fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer();
    btnPanel = new javax.swing.JPanel();
    dismissButton = new javax.swing.JButton();

    getContentPane().setLayout(new java.awt.GridBagLayout());

    dacDelayPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("DAC delay"));
    dacDelayPanel.setLayout(new java.awt.GridBagLayout());

    jSmoothLabel1.setHorizontalAlignment(0);
    jSmoothLabel1.setOpaque(false);
    jSmoothLabel1.setText("Fine");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(jSmoothLabel1, gridBagConstraints);

    fineEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(fineEditor, gridBagConstraints);

    jSmoothLabel2.setHorizontalAlignment(0);
    jSmoothLabel2.setOpaque(false);
    jSmoothLabel2.setText("Coarse");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(jSmoothLabel2, gridBagConstraints);

    coarseEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(coarseEditor, gridBagConstraints);

    stepButton.setText("Step");
    stepButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        stepButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(stepButton, gridBagConstraints);

    resetButton.setText("Reset");
    resetButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        resetButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 3;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(resetButton, gridBagConstraints);

    jSmoothLabel3.setHorizontalAlignment(0);
    jSmoothLabel3.setOpaque(false);
    jSmoothLabel3.setText("Total");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(jSmoothLabel3, gridBagConstraints);

    totalViewer.setBorder(null);
    totalViewer.setText("-----");
    totalViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(totalViewer, gridBagConstraints);

    jSmoothLabel4.setHorizontalAlignment(0);
    jSmoothLabel4.setOpaque(false);
    jSmoothLabel4.setText("FIFO");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(jSmoothLabel4, gridBagConstraints);

    fifoPanel.setBackground(new java.awt.Color(153, 153, 153));

    javax.swing.GroupLayout fifoPanelLayout = new javax.swing.GroupLayout(fifoPanel);
    fifoPanel.setLayout(fifoPanelLayout);
    fifoPanelLayout.setHorizontalGroup(
      fifoPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 133, Short.MAX_VALUE)
    );
    fifoPanelLayout.setVerticalGroup(
      fifoPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 18, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.gridwidth = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    dacDelayPanel.add(fifoPanel, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(dacDelayPanel, gridBagConstraints);

    turnClockPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Turn Clock"));
    turnClockPanel.setLayout(new java.awt.GridBagLayout());

    syncButton.setText("Sync");
    syncButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        syncButtonActionPerformed(evt);
      }
    });
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(syncButton, gridBagConstraints);

    jSmoothLabel5.setHorizontalAlignment(0);
    jSmoothLabel5.setOpaque(false);
    jSmoothLabel5.setText("Bunch");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(jSmoothLabel5, gridBagConstraints);

    bunchEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(bunchEditor, gridBagConstraints);

    jSmoothLabel6.setHorizontalAlignment(0);
    jSmoothLabel6.setOpaque(false);
    jSmoothLabel6.setText("Skew");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(jSmoothLabel6, gridBagConstraints);

    skewEditor.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(skewEditor, gridBagConstraints);

    turnDelayViewer.setBorder(null);
    turnDelayViewer.setText("-----");
    turnDelayViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(turnDelayViewer, gridBagConstraints);

    jSmoothLabel7.setHorizontalAlignment(0);
    jSmoothLabel7.setOpaque(false);
    jSmoothLabel7.setText("Clock errors");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(jSmoothLabel7, gridBagConstraints);

    errorViewer.setBorder(null);
    errorViewer.setText("-----");
    errorViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    turnClockPanel.add(errorViewer, gridBagConstraints);

    statusViewer.setBorder(null);
    statusViewer.setText("-----");
    statusViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.ipadx = 40;
    turnClockPanel.add(statusViewer, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    getContentPane().add(turnClockPanel, gridBagConstraints);

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

  private void stepButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_stepButtonActionPerformed
    Utils.execCommand(MainPanel.mfdbkGEpicsDevName,"DLY_DAC_STEP_S");    
  }//GEN-LAST:event_stepButtonActionPerformed

  private void resetButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetButtonActionPerformed
    Utils.execCommand(MainPanel.mfdbkGEpicsDevName,"DLY_DAC_RESET_S");
  }//GEN-LAST:event_resetButtonActionPerformed

  private void dismissButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_dismissButtonActionPerformed
    setVisible(false);
  }//GEN-LAST:event_dismissButtonActionPerformed

  private void syncButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_syncButtonActionPerformed
    // TODO add your handling code here:
    Utils.execCommand(MainPanel.mfdbkGEpicsDevName,"DLY_TURN_SYNC_S");
  }//GEN-LAST:event_syncButtonActionPerformed

  /**
   * @param args the command line arguments
   */
  public static void main(String args[]) {
    /* Set the Nimbus look and feel */
    //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
    /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
     */
    try {
      for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
        if ("Nimbus".equals(info.getName())) {
          javax.swing.UIManager.setLookAndFeel(info.getClassName());
          break;
        }
      }
    } catch (ClassNotFoundException ex) {
      java.util.logging.Logger.getLogger(DelayPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
    } catch (InstantiationException ex) {
      java.util.logging.Logger.getLogger(DelayPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
    } catch (IllegalAccessException ex) {
      java.util.logging.Logger.getLogger(DelayPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
    } catch (javax.swing.UnsupportedLookAndFeelException ex) {
      java.util.logging.Logger.getLogger(DelayPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
    }
    //</editor-fold>

    /* Create and display the form */
    java.awt.EventQueue.invokeLater(new Runnable() {
      public void run() {
        new DelayPanel().setVisible(true);
      }
    });
  }

  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JPanel btnPanel;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor bunchEditor;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor coarseEditor;
  private javax.swing.JPanel dacDelayPanel;
  private javax.swing.JButton dismissButton;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer errorViewer;
  private javax.swing.JPanel fifoPanel;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor fineEditor;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel1;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel2;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel3;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel4;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel5;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel6;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel7;
  private javax.swing.JButton resetButton;
  private fr.esrf.tangoatk.widget.attribute.NumberScalarWheelEditor skewEditor;
  private fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer statusViewer;
  private javax.swing.JButton stepButton;
  private javax.swing.JButton syncButton;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer totalViewer;
  private javax.swing.JPanel turnClockPanel;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer turnDelayViewer;
  // End of variables declaration//GEN-END:variables

  @Override
  public void numberScalarChange(NumberScalarEvent nse) {
    int v = (int)nse.getValue();
    int mask = 0x80;
    for(int i=0;i<8;i++) {
      if( (v & mask) != 0 )
        fifoPanels[i].setBackground(Color.GREEN);
      else
        fifoPanels[i].setBackground(Color.GREEN.darker());
      mask = mask >> 1;
    }
  }

  @Override
  public void stateChange(AttributeStateEvent ase) {
  }

  @Override
  public void errorChange(ErrorEvent ee) {
    for(int i=0;i<8;i++) {
      fifoPanels[i].setBackground(ATKConstant.getColor4State("UNKNOWN"));
    }
  }
  
}
