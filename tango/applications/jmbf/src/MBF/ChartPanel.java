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
import fr.esrf.tangoatk.core.ISpectrumListener;
import fr.esrf.tangoatk.core.NumberSpectrumEvent;
import fr.esrf.tangoatk.core.attribute.EnumScalar;
import fr.esrf.tangoatk.core.attribute.NumberScalar;
import fr.esrf.tangoatk.core.attribute.NumberSpectrum;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.chart.JLAxis;
import fr.esrf.tangoatk.widget.util.chart.JLDataView;
import java.awt.Color;
import java.awt.Dimension;

/**
 *
 * @author pons
 */
public class ChartPanel extends javax.swing.JFrame implements ISpectrumListener,IEnumScalarListener {

  private AttributePolledList attList;
  private AttributePolledList attChartList;
  
  private EnumScalar refreshModel;
  private NumberSpectrum minModel;
  private NumberSpectrum maxModel;
  private NumberSpectrum deltaModel;
  private NumberSpectrum meanModel;
  private NumberSpectrum stdModel;
  private JLDataView minView;
  private JLDataView maxView;
  private JLDataView deltaView;
  private JLDataView meanView;
  private JLDataView stdView;
  
  private String devName;
  private String type;

  /**
   * Creates new form ChartPanel
   */
  public ChartPanel(String devName,String type) {
    
    initComponents();
    
    this.devName = devName;
    this.type = type;
    attList = new AttributePolledList();
    attList.addErrorListener(errWin);
    attChartList = new AttributePolledList();
    attChartList.addErrorListener(errWin);
    attChartList.setSynchronizedPeriod(true);

    try {
      
      NumberScalar turns = (NumberScalar)attList.add(devName+"/"+type+"_MMS_TURNS");
      turnsViewer.setModel(turns);
      turnsViewer.setBackgroundColor(Color.WHITE);
      
      NumberScalar mean = (NumberScalar)attList.add(devName+"/"+type+"_MMS_MEAN_MEAN");
      meanViewer.setModel(mean);
      meanViewer.setBackgroundColor(Color.WHITE);

      NumberScalar stdMean = (NumberScalar)attList.add(devName+"/"+type+"_MMS_STD_MEAN");
      stdMeanViewer.setModel(stdMean);
      stdMeanViewer.setBackgroundColor(Color.WHITE);
      
      refreshModel = (EnumScalar)attList.add(devName+"/"+type+"_MMS_SCAN_S");
      adcScanComboEditor.setEnumModel(refreshModel);
      refreshModel.addEnumScalarListener(this);

      
      minModel = (NumberSpectrum)attChartList.add(devName+"/"+type+"_MMS_MIN");
      minModel.addSpectrumListener(this);
      maxModel = (NumberSpectrum)attChartList.add(devName+"/"+type+"_MMS_MAX");
      maxModel.addSpectrumListener(this);
      
      deltaModel = (NumberSpectrum)attChartList.add(devName+"/"+type+"_MMS_DELTA");
      deltaModel.addSpectrumListener(this);

      meanModel = (NumberSpectrum)attChartList.add(devName+"/"+type+"_MMS_MEAN");
      meanModel.addSpectrumListener(this);

      stdModel = (NumberSpectrum)attChartList.add(devName+"/"+type+"_MMS_STD");
      stdModel.addSpectrumListener(this);
      
      
    } catch (ConnectionException ex) {      
    }
    
    minView = new JLDataView();
    minView.setName(type+" Min");
    minView.setColor(Color.red);
    maxView = new JLDataView();
    maxView.setName(type+" Max");
    maxView.setColor(Color.blue);
    minmaxChart.setPreferredSize(new Dimension(400,150));
    minmaxChart.getXAxis().setAutoScale(true);
    minmaxChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    minmaxChart.getY1Axis().setAutoScale(true);
    minmaxChart.getY1Axis().addDataView(minView);
    minmaxChart.getY1Axis().addDataView(maxView);
    
    deltaView = new JLDataView();
    deltaView.setName(type+" Difference");
    deltaView.setColor(Color.blue);
    deltaChart.setPreferredSize(new Dimension(400,150));
    deltaChart.getXAxis().setAutoScale(true);
    deltaChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    deltaChart.getY1Axis().setAutoScale(true);
    deltaChart.getY1Axis().addDataView(deltaView);    

    meanView = new JLDataView();
    meanView.setName(type+" Mean");
    meanView.setColor(Color.blue);
    meanChart.setPreferredSize(new Dimension(400,150));
    meanChart.getXAxis().setAutoScale(true);
    meanChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    meanChart.getY1Axis().setAutoScale(true);
    meanChart.getY1Axis().addDataView(meanView);    

    stdView = new JLDataView();
    stdView.setName(type+" Standard Deviation");
    stdView.setColor(Color.blue);
    stdChart.setPreferredSize(new Dimension(400,150));
    stdChart.getXAxis().setAutoScale(true);
    stdChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    stdChart.getY1Axis().setAutoScale(true);
    stdChart.getY1Axis().addDataView(stdView);    
        
    attList.setRefreshInterval(1000);
    attChartList.setRefreshInterval(1000);
    
    setTitle(type+" Charts [" + devName + "]");
    ATKGraphicsUtils.centerFrameOnScreen(this);
    
  }
  
  private long getRefreshTime(int value) {

    switch(value) {
      case 3:
        return 10000;
      case 4:
        return 5000;
      case 5:
        return 2000;
      case 6:
        return 1000;
      case 7:
        return 500;
      case 8:
        return 200;
      case 9:
        return 100;      
    }
    return 1000;
    
  }
  
  public void setVisible(boolean visible) {
    if(visible) {
      attList.startRefresher();
      attChartList.startRefresher();
    } else {
      attList.stopRefresher();    
      attChartList.stopRefresher();
    }
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

    chartPanel = new javax.swing.JPanel();
    minmaxChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    deltaChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    meanChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    stdChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    btnPanel = new javax.swing.JPanel();
    jSmoothLabel1 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    turnsViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel2 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    meanViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel3 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    stdMeanViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    jSmoothLabel5 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    adcScanComboEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    downPanel = new javax.swing.JPanel();
    scanButton = new javax.swing.JButton();
    dismissButton = new javax.swing.JButton();

    chartPanel.setLayout(new java.awt.GridLayout(4, 1));

    minmaxChart.setBackground(java.awt.SystemColor.control);
    minmaxChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    chartPanel.add(minmaxChart);

    deltaChart.setBackground(java.awt.SystemColor.control);
    deltaChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    chartPanel.add(deltaChart);

    meanChart.setBackground(java.awt.SystemColor.control);
    meanChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    chartPanel.add(meanChart);

    stdChart.setBackground(java.awt.SystemColor.control);
    stdChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    chartPanel.add(stdChart);

    getContentPane().add(chartPanel, java.awt.BorderLayout.CENTER);

    btnPanel.setLayout(new java.awt.GridBagLayout());

    jSmoothLabel1.setFocusable(false);
    jSmoothLabel1.setOpaque(false);
    jSmoothLabel1.setText("Turns");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 10, 0, 0);
    btnPanel.add(jSmoothLabel1, gridBagConstraints);

    turnsViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 20;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    btnPanel.add(turnsViewer, gridBagConstraints);

    jSmoothLabel2.setFocusable(false);
    jSmoothLabel2.setOpaque(false);
    jSmoothLabel2.setText("Mean");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    btnPanel.add(jSmoothLabel2, gridBagConstraints);

    meanViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 20;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    btnPanel.add(meanViewer, gridBagConstraints);

    jSmoothLabel3.setFocusable(false);
    jSmoothLabel3.setOpaque(false);
    jSmoothLabel3.setText("Std Mean");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    btnPanel.add(jSmoothLabel3, gridBagConstraints);

    stdMeanViewer.setText("-----");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 20;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    btnPanel.add(stdMeanViewer, gridBagConstraints);

    jSmoothLabel5.setFocusable(false);
    jSmoothLabel5.setOpaque(false);
    jSmoothLabel5.setText("Refresh");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 0);
    btnPanel.add(jSmoothLabel5, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 20;
    gridBagConstraints.insets = new java.awt.Insets(5, 0, 0, 10);
    btnPanel.add(adcScanComboEditor, gridBagConstraints);

    downPanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

    scanButton.setText("Scan");
    scanButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        scanButtonActionPerformed(evt);
      }
    });
    downPanel.add(scanButton);

    dismissButton.setText("Dismiss");
    dismissButton.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {
        dismissButtonActionPerformed(evt);
      }
    });
    downPanel.add(dismissButton);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.gridwidth = 10;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    btnPanel.add(downPanel, gridBagConstraints);

    getContentPane().add(btnPanel, java.awt.BorderLayout.SOUTH);

    pack();
  }// </editor-fold>//GEN-END:initComponents

  private void dismissButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_dismissButtonActionPerformed
    setVisible(false);
  }//GEN-LAST:event_dismissButtonActionPerformed

  private void scanButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_scanButtonActionPerformed
    Utils.execCommand(devName, type+"_MMS_SCAN_CMD");
    attChartList.refresh();    
  }//GEN-LAST:event_scanButtonActionPerformed


  // Variables declaration - do not modify//GEN-BEGIN:variables
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor adcScanComboEditor;
  private javax.swing.JPanel btnPanel;
  private javax.swing.JPanel chartPanel;
  private fr.esrf.tangoatk.widget.util.chart.JLChart deltaChart;
  private javax.swing.JButton dismissButton;
  private javax.swing.JPanel downPanel;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel1;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel2;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel3;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel5;
  private fr.esrf.tangoatk.widget.util.chart.JLChart meanChart;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer meanViewer;
  private fr.esrf.tangoatk.widget.util.chart.JLChart minmaxChart;
  private javax.swing.JButton scanButton;
  private fr.esrf.tangoatk.widget.util.chart.JLChart stdChart;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer stdMeanViewer;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer turnsViewer;
  // End of variables declaration//GEN-END:variables

  @Override
  public void spectrumChange(NumberSpectrumEvent nse) {
    Object src = nse.getSource();
    double[] values = nse.getValue();
    if(src==minModel) {
      minView.reset();
      for(int i=0;i<values.length;i++)
        minView.add(i,values[i],false);
      minView.commitChange();
      minmaxChart.repaint();
    } else if(src==maxModel) {
      maxView.reset();
      for(int i=0;i<values.length;i++)
        maxView.add(i,values[i],false);
      maxView.commitChange();
      minmaxChart.repaint();      
    } else if(src==deltaModel) {
      deltaView.reset();
      for(int i=0;i<values.length;i++)
        deltaView.add(i,values[i],false);
      deltaView.commitChange();
      deltaChart.repaint();      
    } else if(src==meanModel) {
      meanView.reset();
      for(int i=0;i<values.length;i++)
        meanView.add(i,values[i],false);
      meanView.commitChange();
      meanChart.repaint();      
    } else if(src==stdModel) {
      stdView.reset();
      for(int i=0;i<values.length;i++)
        stdView.add(i,values[i],false);
      stdView.commitChange();
      stdChart.repaint();      
    }
  }

  @Override
  public void stateChange(AttributeStateEvent ase) {
  }

  @Override
  public void errorChange(ErrorEvent ee) {
    Object src = ee.getSource();
    if(src==minModel) {
      minView.reset();
      minmaxChart.repaint();
    } else if(src==maxModel) {
      maxView.reset();
      minmaxChart.repaint();      
    } else if(src==deltaModel) {
      deltaView.reset();
      deltaChart.repaint();      
    } else if(src==meanModel) {
      meanView.reset();
      meanChart.repaint();      
    } else if(src==stdModel) {
      stdView.reset();
      stdChart.repaint();      
    }
  }

  @Override
  public void enumScalarChange(EnumScalarEvent ese) {
    Object src = ese.getSource();
    if(src==refreshModel) {
      int v = refreshModel.getShortValueFromEnumScalar(ese.getValue());
      attChartList.setRefreshInterval((int)getRefreshTime(v));
    }
  }
  
}
