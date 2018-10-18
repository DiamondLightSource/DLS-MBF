/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package MBF;

import static MBF.MainPanel.errWin;
import fr.esrf.Tango.DevFailed;
import fr.esrf.TangoApi.DeviceAttribute;
import fr.esrf.TangoApi.DeviceProxy;
import fr.esrf.tangoatk.core.AttributePolledList;
import fr.esrf.tangoatk.core.AttributeStateEvent;
import fr.esrf.tangoatk.core.ConnectionException;
import fr.esrf.tangoatk.core.DeviceFactory;
import fr.esrf.tangoatk.core.EnumScalarEvent;
import fr.esrf.tangoatk.core.ErrorEvent;
import fr.esrf.tangoatk.core.IEnumScalarListener;
import fr.esrf.tangoatk.core.IRefresherListener;
import fr.esrf.tangoatk.core.ISpectrumListener;
import fr.esrf.tangoatk.core.NumberSpectrumEvent;
import fr.esrf.tangoatk.core.attribute.EnumScalar;
import fr.esrf.tangoatk.core.attribute.NumberScalar;
import fr.esrf.tangoatk.core.attribute.NumberSpectrum;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.chart.DataList;
import fr.esrf.tangoatk.widget.util.chart.IJLChartListener;
import fr.esrf.tangoatk.widget.util.chart.JLAxis;
import fr.esrf.tangoatk.widget.util.chart.JLChartEvent;
import fr.esrf.tangoatk.widget.util.chart.JLDataView;
import java.awt.Color;
import java.awt.Dimension;

/**
 *
 * @author pons
 */
public class DETWaveformPanel extends javax.swing.JFrame implements IJLChartListener,IRefresherListener,ISpectrumListener,IEnumScalarListener {

  private AttributePolledList attList;
  private AttributePolledList attChartList;
  
  private EnumScalar overflow;
  private NumberSpectrum powerModel;
  private NumberSpectrum phaseModel;
  private NumberSpectrum iModel;
  private NumberSpectrum qModel;
  private JLDataView powerView;
  private JLDataView phaseView;
  private JLDataView iView;
  private JLDataView qView;
  
  private String devName;
  private int    detIdx;
  
  /**
   * Creates new form DETWaveformPanel
   */
  public DETWaveformPanel(String devName,int idx) {

    initComponents();
    
    this.devName = devName;
    this.detIdx = idx;
    attList = new AttributePolledList();
    attList.addErrorListener(errWin);
    attChartList = new AttributePolledList();
    attChartList.addErrorListener(errWin);
    attChartList.setSynchronizedPeriod(true);
    
    try {
      
      NumberScalar maxPower = (NumberScalar)attList.add(devName+"/DET_"+detIdx+"_MAX_POWER");
      maxPowerViewer.setModel(maxPower);
      overflow = (EnumScalar)attList.add(devName+"/DET_"+detIdx+"_OUT_OVF");
      overflowViewer.setModel(overflow);
      overflow.addEnumScalarListener(this);
      EnumScalar gain = (EnumScalar)attList.add(devName+"/DET_"+detIdx+"_SCALING_S");
      gainEditor.setEnumModel(gain);
      
      
      powerModel = (NumberSpectrum)attChartList.add(devName+"/DET_"+detIdx+"_POWER");
      powerModel.addSpectrumListener(this);
      phaseModel = (NumberSpectrum)attChartList.add(devName+"/DET_"+detIdx+"_PHASE");
      phaseModel.addSpectrumListener(this);
      iModel = (NumberSpectrum)attChartList.add(devName+"/DET_"+detIdx+"_I");
      iModel.addSpectrumListener(this);
      qModel = (NumberSpectrum)attChartList.add(devName+"/DET_"+detIdx+"_Q");
      qModel.addSpectrumListener(this);
      attChartList.addRefresherListener(this);
            
      
    } catch (ConnectionException ex) {      
    }
    
    powerView = new JLDataView();
    powerView.setName("Power");
    powerView.setColor(Color.blue);
    powerChart.setPreferredSize(new Dimension(500,200));
    powerChart.setHeader("Power");
    powerChart.getXAxis().setAutoScale(true);
    powerChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    powerChart.getY1Axis().setAutoScale(true);
    powerChart.getY1Axis().addDataView(powerView);    
    
    phaseView = new JLDataView();
    phaseView.setName("Phase");
    phaseView.setMarkerColor(Color.blue);
    phaseView.setLineWidth(0);
    phaseView.setMarker(JLDataView.MARKER_DOT);
    phaseView.setMarkerSize(1);
    phaseChart.setPreferredSize(new Dimension(500,200));
    phaseChart.getXAxis().setAutoScale(true);
    phaseChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    phaseChart.getY1Axis().setAutoScale(true);
    phaseChart.getY1Axis().addDataView(phaseView);    
    
    iView = new JLDataView();
    iView.setName("I");
    iView.setColor(Color.red);
    iView.setMarkerSize(1);        
    qView = new JLDataView();
    qView.setName("Q");
    qView.setColor(Color.blue);
    iqChart.setHeader("I/Q");
    iqChart.setPreferredSize(new Dimension(500,200));
    iqChart.getXAxis().setAutoScale(true);
    iqChart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    iqChart.getY1Axis().setAutoScale(true);
    iqChart.getY1Axis().addDataView(iView);
    iqChart.getY1Axis().addDataView(qView);
    iqChart.setJLChartListener(this);
            
    attList.setRefreshInterval(1000);
    attChartList.setRefreshInterval(1000);
    
    setTitle("Detector "+detIdx+" Waveforms [" + devName + "]");
    ATKGraphicsUtils.centerFrameOnScreen(this);
    
    
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

    powerChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    phaseChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    iqChart = new fr.esrf.tangoatk.widget.util.chart.JLChart();
    paramPanel = new javax.swing.JPanel();
    jSmoothLabel1 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    modeComboBox = new javax.swing.JComboBox<>();
    jSmoothLabel2 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    maxPowerViewer = new fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer();
    overflowGroupPanel = new javax.swing.JPanel();
    overflowPanel = new javax.swing.JPanel();
    overflowViewer = new fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer();
    jSmoothLabel3 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    gainEditor = new fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor();
    jSmoothLabel4 = new fr.esrf.tangoatk.widget.util.JSmoothLabel();
    iqComboBox = new javax.swing.JComboBox<>();
    btnPanel = new javax.swing.JPanel();
    dismissButton = new javax.swing.JButton();

    getContentPane().setLayout(new java.awt.GridBagLayout());

    powerChart.setBackground(java.awt.SystemColor.control);
    powerChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 0.33;
    getContentPane().add(powerChart, gridBagConstraints);

    phaseChart.setBackground(java.awt.SystemColor.control);
    phaseChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 1;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 0.33;
    getContentPane().add(phaseChart, gridBagConstraints);

    iqChart.setBackground(java.awt.SystemColor.control);
    iqChart.setBorder(javax.swing.BorderFactory.createEtchedBorder());
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 2;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    gridBagConstraints.weighty = 0.33;
    getContentPane().add(iqChart, gridBagConstraints);

    paramPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Setup"));
    paramPanel.setLayout(new java.awt.GridBagLayout());

    jSmoothLabel1.setOpaque(false);
    jSmoothLabel1.setText("X Axis");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(jSmoothLabel1, gridBagConstraints);

    modeComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Frequency", "Timebase" }));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(modeComboBox, gridBagConstraints);

    jSmoothLabel2.setOpaque(false);
    jSmoothLabel2.setText("Max power");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 6;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(jSmoothLabel2, gridBagConstraints);

    maxPowerViewer.setBorder(null);
    maxPowerViewer.setText("-----");
    maxPowerViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 7;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(maxPowerViewer, gridBagConstraints);

    overflowGroupPanel.setLayout(new java.awt.GridBagLayout());

    overflowPanel.setBackground(new java.awt.Color(153, 153, 153));
    overflowPanel.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
    overflowPanel.setPreferredSize(new java.awt.Dimension(25, 20));

    javax.swing.GroupLayout overflowPanelLayout = new javax.swing.GroupLayout(overflowPanel);
    overflowPanel.setLayout(overflowPanelLayout);
    overflowPanelLayout.setHorizontalGroup(
      overflowPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 0, Short.MAX_VALUE)
    );
    overflowPanelLayout.setVerticalGroup(
      overflowPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGap(0, 16, Short.MAX_VALUE)
    );

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    overflowGroupPanel.add(overflowPanel, gridBagConstraints);

    overflowViewer.setBorder(null);
    overflowViewer.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
    overflowViewer.setText("-----");
    overflowViewer.setOpaque(false);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 1;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.ipadx = 30;
    gridBagConstraints.insets = new java.awt.Insets(0, 4, 0, 0);
    overflowGroupPanel.add(overflowViewer, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 8;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(overflowGroupPanel, gridBagConstraints);

    jSmoothLabel3.setOpaque(false);
    jSmoothLabel3.setText("Gain");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 4;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(jSmoothLabel3, gridBagConstraints);
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 5;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(gainEditor, gridBagConstraints);

    jSmoothLabel4.setOpaque(false);
    jSmoothLabel4.setText("I/Q Display");
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 2;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(jSmoothLabel4, gridBagConstraints);

    iqComboBox.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Individual", "X/Y" }));
    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 3;
    gridBagConstraints.gridy = 0;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
    paramPanel.add(iqComboBox, gridBagConstraints);

    gridBagConstraints = new java.awt.GridBagConstraints();
    gridBagConstraints.gridx = 0;
    gridBagConstraints.gridy = 3;
    gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
    gridBagConstraints.weightx = 1.0;
    getContentPane().add(paramPanel, gridBagConstraints);

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
    gridBagConstraints.gridy = 4;
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
  private javax.swing.JButton dismissButton;
  private fr.esrf.tangoatk.widget.attribute.EnumScalarComboEditor gainEditor;
  private fr.esrf.tangoatk.widget.util.chart.JLChart iqChart;
  private javax.swing.JComboBox<String> iqComboBox;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel1;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel2;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel3;
  private fr.esrf.tangoatk.widget.util.JSmoothLabel jSmoothLabel4;
  private fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer maxPowerViewer;
  private javax.swing.JComboBox<String> modeComboBox;
  private javax.swing.JPanel overflowGroupPanel;
  private javax.swing.JPanel overflowPanel;
  private fr.esrf.tangoatk.widget.attribute.SimpleEnumScalarViewer overflowViewer;
  private javax.swing.JPanel paramPanel;
  private fr.esrf.tangoatk.widget.util.chart.JLChart phaseChart;
  private fr.esrf.tangoatk.widget.util.chart.JLChart powerChart;
  // End of variables declaration//GEN-END:variables

  @Override
  public void spectrumChange(NumberSpectrumEvent nse) {
    Object src = nse.getSource();
    double[] values = nse.getValue();
    if( src==powerModel ) {
      powerView.reset();
      for(int i=0;i<values.length;i++)
        powerView.add(i,values[i],false);
      powerView.commitChange();
    } else if( src==phaseModel ) {
      phaseView.reset();
      for(int i=0;i<values.length;i++)
        phaseView.add(i,values[i],false);
      phaseView.commitChange();
    } else if( src==iModel ) {
      iView.reset();
      for(int i=0;i<values.length;i++)
        iView.add(i,values[i],false);
      iView.commitChange();
    } else if( src==qModel ) {
      qView.reset();
      for(int i=0;i<values.length;i++)
        qView.add(i,values[i],false);
      qView.commitChange();
    }
  }

  @Override
  public void stateChange(AttributeStateEvent ase) {
  }

  @Override
  public void errorChange(ErrorEvent ee) {
    Object src = ee.getSource();
    if( src==overflow ) {
      overflowPanel.setBackground(ATKConstant.getColor4State("UNKNOWN"));      
    } else if ( src==powerModel ) {
      powerView.reset();      
    } else if ( src==phaseModel ) {
      phaseView.reset();            
    } else if ( src==iModel ) {
      iView.reset();            
    } else if ( src==qModel ) {
      qView.reset();            
    }
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
  public void refreshStep() {
    
    try {
      
      DeviceAttribute da;
      DeviceProxy ds = DeviceFactory.getInstance().getDevice(devName);
      double[] xValues;
      
      if( modeComboBox.getSelectedIndex()==0 ) {
        // Frequency mode
        da = ds.read_attribute("DET_SCALE");
        xValues = da.extractDoubleArray();
      } else {
        // Timebase mode
        da = ds.read_attribute("DET_TIMEBASE");
        int[] lValues = da.extractLongArray();
        xValues = new double[lValues.length];
        for(int i=0;i<xValues.length;i++)
          xValues[i] = (double)lValues[i];
      }
            
      if( powerView.getDataLength()==xValues.length ) {
        DataList l = powerView.getData();
        for(int i=0;i<xValues.length;i++) {
          l.x = xValues[i];
          l = l.next;
        }
      }
      
      if( phaseView.getDataLength()==xValues.length ) {
        DataList l = phaseView.getData();
        for(int i=0;i<xValues.length;i++) {
          l.x = xValues[i];
          l = l.next;
        }
      }
      
      if( iView.getDataLength()==xValues.length ) {
        DataList l = iView.getData();
        for(int i=0;i<xValues.length;i++) {
          l.x = xValues[i];
          l = l.next;
        }
      }
      
      if( qView.getDataLength()==xValues.length ) {
        DataList l = qView.getData();
        for(int i=0;i<xValues.length;i++) {
          l.x = xValues[i];
          l = l.next;
        }
      }
              
      if( iqComboBox.getSelectedIndex()==0 ) {
        
        // Individual curve
        qView.removeFromAxis();
        iqChart.getY1Axis().addDataView(qView);
        iView.setLineWidth(1);
        iView.setMarker(JLDataView.MARKER_NONE);
        iView.setName("I");
        
      } else {

        // XY plot        
        qView.removeFromAxis();
        iqChart.getXAxis().addDataView(qView);
        iView.setLineWidth(0);
        iView.setMarker(JLDataView.MARKER_DOT);
        iView.setName("I/Q");
        
      }
      
    } catch(ConnectionException | DevFailed e) {                
    }
    
    powerChart.repaint();
    phaseChart.repaint();
    iqChart.repaint();
    
  }

  @Override
  public String[] clickOnChart(JLChartEvent jlce) {

    String[] ret;
    String dvName = jlce.getDataView().getName();
    String xName;
    if( modeComboBox.getSelectedIndex()==0 ) {
      xName = "Freq";   
    } else {
      xName = "Timebase";         
    }
        
    if( iqChart.getXAxis().isXY() ) {
      ret = new String[3];
      ret[0] = xName + "= " + jlce.searchResult.value.x;
      ret[1] = "I= " + jlce.searchResult.value.y;
      ret[2] = "Q= " + jlce.searchResult.xvalue.y;
    } else {
      ret = new String[2];
      ret[0] = xName + "= " + Double.toString(jlce.getXValue());    
      ret[1] = dvName + "= " + Double.toString(jlce.getXValue());    
    }
    
    return ret;
    
  }
  
}
