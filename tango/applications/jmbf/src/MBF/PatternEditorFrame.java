package MBF;

import static MBF.MainPanel.NB_BUCKET;
import fr.esrf.Tango.DevFailed;
import fr.esrf.TangoApi.DeviceAttribute;
import fr.esrf.TangoApi.DeviceProxy;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.ErrorPane;
import fr.esrf.tangoatk.widget.util.chart.JLAxis;
import fr.esrf.tangoatk.widget.util.chart.JLChart;
import fr.esrf.tangoatk.widget.util.chart.JLDataView;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.*;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Vector;

/**
 * A class for editing pattern
 */
public class PatternEditorFrame extends JFrame implements ActionListener {

  static int DOUBLE_TYPE = 0;
  static int INT_TYPE = 1;  
  
  private Vector patterns = new Vector();
  private boolean hasError;
  private String  deviceName;
  private String  attributeName;
  private String  fileDirectory = "/operation/dserver/settings/mfdbk";
  private int type;

  private JPanel            innerPanel;
  private JTable            patternTable;
  private DefaultTableModel patternModel;
  private JScrollPane       patternView;

  private JPanel            infoPanel;
  private JLabel            sumLabel;
  private JTextField        sumText;
  private JLabel            bunchLabel;
  private JTextField        bunchText;
  private JLabel            bucketLabel;
  private JTextField        bucketText;
  private JPanel            errorPanel;
  private JScrollPane       errorView;
  private JTextArea         errorText;
  private JButton           removeBtn;
  private JButton           insertBtn;
  private JButton           clearBtn;
  private JButton           saveBtn;
  private JButton           loadBtn;
  private JButton           applyBtn;
  private JButton           sortBtn;
  private JButton           viewGraphBtn;
  private JButton           dismissBtn;

  public PatternEditorFrame(int type,String fullAttributeName) {

    int pos = fullAttributeName.lastIndexOf("/");
    if(pos<0) {
      JOptionPane.showMessageDialog(null,"Invalid attribute name : " + fullAttributeName);
      return;
    }
    deviceName = fullAttributeName.substring(0,pos);
    attributeName = fullAttributeName.substring(pos+1,fullAttributeName.length());
    this.type = type;

    innerPanel = new JPanel();
    innerPanel.setLayout(new BorderLayout());
    setContentPane(innerPanel);

    // Pattern Table -----------------------------------------------------------
    patternModel = new DefaultTableModel() {

      public Class getColumnClass(int columnIndex) {
          return String.class;
      }
      public boolean isCellEditable(int row, int column) {
          return column<=2;
      }
      public void setValueAt(Object aValue, int row, int column) {
        switch(column) {
          case 0: // Start bucket
            int startBucket;
            try {
              startBucket = Integer.parseInt((String)aValue);
            } catch (NumberFormatException e) {
              JOptionPane.showMessageDialog(null,"Invalid start bucket number");
              return;
            }
            ((PatternInfo)patterns.get(row)).startBucket = startBucket;
            refreshComponents();
            break;
          case 1: // Length
            int length;
            try {
              length = Integer.parseInt((String)aValue);
            } catch (NumberFormatException e) {
              JOptionPane.showMessageDialog(null,"Invalid length number");
              return;
            }
            if(length==0) {
              JOptionPane.showMessageDialog(null,"Length cannot be 0");
              return;
            }
            ((PatternInfo)patterns.get(row)).length = length;
            refreshComponents();
            break;
          case 2: // Value
            int value;
            try {
              value = Integer.parseInt((String)aValue);
            } catch (NumberFormatException e) {
              JOptionPane.showMessageDialog(null,"Invalid value number");
              return;
            }
            ((PatternInfo)patterns.get(row)).value = value;
            refreshComponents();
            break;
        }
      }

    };
    patternTable = new JTable(patternModel);
    patternTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
    patternView = new JScrollPane(patternTable);
    patternView.setPreferredSize(new Dimension(490,200));
    innerPanel.add(patternView,BorderLayout.CENTER);

    // Info panel --------------------------------------------------------------
    infoPanel = new JPanel();
    infoPanel.setLayout(null);
    infoPanel.setPreferredSize(new Dimension(490,230));
    innerPanel.add(infoPanel,BorderLayout.SOUTH);

    sumLabel = new JLabel("Total sum");
    sumLabel.setFont(ATKConstant.labelFont);
    infoPanel.add(sumLabel);
    sumText = new JTextField();
    sumText.setEditable(false);
    infoPanel.add(sumText);
    bunchLabel = new JLabel("Bunch defined");
    bunchLabel.setFont(ATKConstant.labelFont);
    infoPanel.add(bunchLabel);
    bunchText = new JTextField();
    bunchText.setEditable(false);
    infoPanel.add(bunchText);
    bucketLabel = new JLabel("Bucket number");
    bucketLabel.setFont(ATKConstant.labelFont);
    infoPanel.add(bucketLabel);
    bucketText = new JTextField();
    bucketText.setEditable(false);
    infoPanel.add(bucketText);
    errorPanel = new JPanel();
    errorPanel.setBorder( BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(), "Errors",
                                            TitledBorder.LEFT, TitledBorder.DEFAULT_POSITION,
                                            ATKConstant.labelFont, Color.BLACK) );

    errorPanel.setLayout(new BorderLayout());
    errorText = new JTextArea();
    errorText.setEditable(false);
    errorView = new JScrollPane(errorText);
    errorPanel.add(errorView);
    infoPanel.add(errorPanel);

    removeBtn = new JButton("Remove");
    removeBtn.addActionListener(this);
    infoPanel.add(removeBtn);
    insertBtn = new JButton("Insert");
    insertBtn.addActionListener(this);
    infoPanel.add(insertBtn);
    clearBtn = new JButton("Clear");
    clearBtn.addActionListener(this);
    infoPanel.add(clearBtn);
    saveBtn = new JButton("Save");
    saveBtn.addActionListener(this);
    infoPanel.add(saveBtn);
    loadBtn = new JButton("Load");
    loadBtn.addActionListener(this);
    infoPanel.add(loadBtn);
    applyBtn = new JButton("Apply");
    applyBtn.setToolTipText(fullAttributeName);
    applyBtn.addActionListener(this);
    infoPanel.add(applyBtn);
    sortBtn = new JButton("Sort");
    sortBtn.addActionListener(this);
    infoPanel.add(sortBtn);
    viewGraphBtn = new JButton("View graph");
    viewGraphBtn.addActionListener(this);
    infoPanel.add(viewGraphBtn);
    dismissBtn = new JButton("Dismiss");
    dismissBtn.addActionListener(this);
    infoPanel.add(dismissBtn);

    placeInfoComponents();
    infoPanel.addComponentListener(new ComponentAdapter() {
      public void componentResized(ComponentEvent e) {
        placeInfoComponents();
      }
    });

    refresh();
    setTitle("Pattern editor");
    ATKGraphicsUtils.centerFrameOnScreen(this);
  }
  
  public void refresh() {
    initPatternsFromDevice();
    refreshComponents();    
  }

  public void setFileDirectory(String dir) {
    fileDirectory = dir;
  }

  public String getFileDirectory(String dir) {
    return fileDirectory;
  }

  public void actionPerformed(ActionEvent e) {
    Object src = e.getSource();

    if( src==removeBtn ) {

      int idx = patternTable.getSelectedRow();
      if( idx==-1 ) {
        JOptionPane.showMessageDialog(this,"No row selected");
        return;
      }
      patterns.remove(idx);
      refreshComponents();

    } else if (src==insertBtn) {

      PatternInfoDlg dlg = new PatternInfoDlg(this);
      if( dlg.showDlg() ) {
        int idx = patternTable.getSelectedRow();
        PatternInfo pi = new PatternInfo();
        pi.startBucket = dlg.startBucket;
        pi.length = dlg.length;
        pi.value = dlg.value;
        patterns.add(idx+1,pi);
        refreshComponents();
      }

    } else if (src==clearBtn) {

      if( JOptionPane.showConfirmDialog(this,"Do you want to clear the pattern ?",
              "Question",JOptionPane.YES_NO_OPTION)==JOptionPane.YES_OPTION ) {
        patterns.clear();
        refreshComponents();        
      }
      
    } else if (src==saveBtn) {

      if( hasError ) {
        JOptionPane.showMessageDialog(this,"The pattern contains errors\nPlease solve them before saving");
      } else {
        JFileChooser chooser = new JFileChooser(fileDirectory);
        int returnVal = chooser.showSaveDialog(this);

        if (returnVal == JFileChooser.APPROVE_OPTION) {
          saveFile(chooser.getSelectedFile().getAbsolutePath());
        }
      }

    } else if (src==loadBtn) {

      JFileChooser chooser = new JFileChooser(fileDirectory);
      int returnVal = chooser.showOpenDialog(this);

      if (returnVal == JFileChooser.APPROVE_OPTION) {
        loadFile(chooser.getSelectedFile().getAbsolutePath());
      }

    } else if (src==applyBtn) {

      if( hasError ) {
        JOptionPane.showMessageDialog(this,"The pattern contains errors\nPlease solve them before applying");
      } else {
        applyPatternToDevice();
      }

    } else if (src==dismissBtn ) {
      
      setVisible(false);
      
    } else if (src==sortBtn) {

      sortPattern();

    } else if (src==viewGraphBtn) {

      viewGraph();

    }

  }

  private void placeInfoComponents() {

    Dimension d = infoPanel.getSize();
    sumLabel.setBounds(5,10,80,25);
    sumText.setBounds(90,10,50,25);
    bunchLabel.setBounds(145,10,100,25);
    bunchText.setBounds(250,10,50,25);
    bucketLabel.setBounds(305,10,100,25);
    bucketText.setBounds(410,10,50,25);
    errorPanel.setBounds(5,40,d.width-10,d.height-105);
    errorPanel.revalidate();

    removeBtn.setBounds(10,d.height-60,90,25);
    insertBtn.setBounds(105,d.height-60,90,25);
    clearBtn.setBounds(200,d.height-60,90,25);
    saveBtn.setBounds(295,d.height-60,90,25);
    loadBtn.setBounds(390,d.height-60,90,25);
    applyBtn.setBounds(10,d.height-30,90,25);
    sortBtn.setBounds(105,d.height-30,90,25);
    viewGraphBtn.setBounds(200,d.height-30,185,25);
    dismissBtn.setBounds(390,d.height-30,90,25);

  }

  private void viewGraph() {

    JFrame fr = new JFrame();
    JLChart chart = new JLChart();

    JLDataView v = new JLDataView();
    v.setName("Pattern");

    double[] data = new double[NB_BUCKET];
    for(int i=0;i<NB_BUCKET;i++) data[i]=Double.NaN;
    for(int i=0;i<patterns.size();i++) {
      PatternInfo pi = (PatternInfo)patterns.get(i);
      for(int j=0;j<pi.length;j++) {
        data[pi.startBucket+j]=pi.value;
      }
    }
    for(int i=0;i<NB_BUCKET;i++) {
      v.add((double)i,data[i]);
    }
    chart.getY1Axis().addDataView(v);
    chart.getY1Axis().setAutoScale(true);
    chart.getXAxis().setAnnotation(JLAxis.VALUE_ANNO);
    fr.setContentPane(chart);
    chart.setPreferredSize(new Dimension(640,480));
    ATKGraphicsUtils.centerFrameOnScreen(fr);
    fr.setTitle("Pattern view [" + attributeName + "]");
    fr.setVisible(true);
    
  }

  private void sortPattern() {

    Vector sorted = new Vector();
    for(int i=0;i<patterns.size();i++) {
      PatternInfo pi = (PatternInfo)patterns.get(i);
      int j=0;
      boolean found = false;
      while(j<sorted.size() && !found) {
        PatternInfo pj = (PatternInfo)sorted.get(j);
        found = (pi.startBucket<pj.startBucket);
        if(!found) j++;
      }
      sorted.insertElementAt(pi,j);
    }
    patterns = sorted;
    refreshComponents();
    
  }

  private int[] buildPatternInt() {

    int[] data = new int[NB_BUCKET];
    for(int i=0;i<patterns.size();i++) {
      PatternInfo pi = (PatternInfo)patterns.get(i);
      for(int j=0;j<pi.length;j++) {
        data[pi.startBucket+j]=(int)pi.value;
      }
    }
    return data;

  }
  
  private double[] buildPatternDouble() {

    double[] data = new double[NB_BUCKET];
    for(int i=0;i<patterns.size();i++) {
      PatternInfo pi = (PatternInfo)patterns.get(i);
      for(int j=0;j<pi.length;j++) {
        data[pi.startBucket+j]=pi.value;
      }
    }
    return data;

  }

  private void applyPatternToDevice() {

    DeviceProxy ds;

    try {

      // Write the pattern
      ds = new DeviceProxy(deviceName);
      DeviceAttribute argin = new DeviceAttribute(attributeName);
      if(type==DOUBLE_TYPE)
        argin.insert(buildPatternDouble());
      else
        argin.insert(buildPatternInt());
      ds.write_attribute(argin);

    } catch (DevFailed e) {
      ErrorPane.showErrorMessage(null, deviceName, e);
    }

  }

  private void saveFile(String fileName) {

    
    double[] data = buildPatternDouble();

    try {
      FileWriter f = new FileWriter(fileName);
      for(int i=0;i<data.length;i++) {
        if(type==DOUBLE_TYPE)
          f.write(Double.toString(data[i])+"\n");
        else
          f.write(Integer.toString((int)data[i])+"\n");
      }
      f.close();
    } catch (IOException e) {
      JOptionPane.showMessageDialog(this,"Failed to write to " + fileName + "\n" + e.getMessage());
    }

  }

  private void loadFile(String fileName) {

    double data[] = new double[NB_BUCKET];
    
    try {
      FileReader f = new FileReader(fileName);
      for(int i=0;i<NB_BUCKET;i++) {
        StringBuffer str = new StringBuffer();
        int c = f.read();
        while(c>=32) {
          str.append((char)c);
          c = f.read();
        }
        try {
          data[i] = Double.parseDouble(str.toString());
        } catch (NumberFormatException e) {
          JOptionPane.showMessageDialog(this,"Fail to parse "+str.toString()+" at line " + i);
          return;
        }
      }
      f.close();
    } catch (IOException e) {
      JOptionPane.showMessageDialog(this,"Failed to read " + fileName + "\n" + e.getMessage());
      return;
    }

    initPatterns(data);
    applyPatternToDevice();
    refreshComponents();

  }

  private void initPatterns(int[] data) {

    patterns.clear();

    // Build pattern info from the pattern
    int lastValue = data[0];
    int length = 1;
    for(int i=1;i<NB_BUCKET;i++) {
      while(i<NB_BUCKET && data[i]==lastValue) {
        length++;
        i++;
      }
      // Add new pattern
      PatternInfo pi = new PatternInfo();
      pi.startBucket = i-length;
      pi.length = length;
      pi.value = lastValue;
      patterns.add(pi);

      if(i<NB_BUCKET) {
        lastValue = data[i];
        length = 1;
      } else {
        length = 0;
      }
    }

    // Last pattern
    if(length>0) {
      PatternInfo pi = new PatternInfo();
      pi.startBucket = NB_BUCKET-length;
      pi.length = length;
      pi.value = lastValue;
      patterns.add(pi);
    }

  }
  
  private void initPatterns(double[] data) {

    patterns.clear();

    // Build pattern info from the pattern
    double lastValue = data[0];
    int length = 1;
    for(int i=1;i<NB_BUCKET;i++) {
      while(i<NB_BUCKET && data[i]==lastValue) {
        length++;
        i++;
      }
      // Add new pattern
      PatternInfo pi = new PatternInfo();
      pi.startBucket = i-length;
      pi.length = length;
      pi.value = lastValue;
      patterns.add(pi);

      if(i<NB_BUCKET) {
        lastValue = data[i];
        length = 1;
      } else {
        length = 0;
      }
    }

    // Last pattern
    if(length>0) {
      PatternInfo pi = new PatternInfo();
      pi.startBucket = NB_BUCKET-length;
      pi.length = length;
      pi.value = lastValue;
      patterns.add(pi);
    }

  }

  public void initPatternsFromDevice() {

    DeviceProxy ds;
    double[] datad;
    int[] datai;

    try {

      // Read the pattern
      ds = new DeviceProxy(deviceName);
      DeviceAttribute argout = ds.read_attribute(attributeName);

      int readLength = argout.getNbRead();
      if(readLength!=NB_BUCKET) {
        JOptionPane.showMessageDialog(this,"Invalid pattern length, should be " + NB_BUCKET);
        return;
      }
      
      if(type==DOUBLE_TYPE) {
        datad = argout.extractDoubleArray();
        initPatterns(datad);
      } else {
        datai = argout.extractLongArray();
        initPatterns(datai);
      }
      
    } catch (DevFailed e) {
      ErrorPane.showErrorMessage(null, deviceName, e);
    }

  }

  public void refreshComponents() {

    // Refresh the table
    String patternColName[] = {"Start bucket" , "Length" , "Value" , "End bucket" };
    Object[][] patternInfo = new Object[patterns.size()][4];
    for(int i=0;i<patterns.size();i++) {
      PatternInfo pi = (PatternInfo)patterns.get(i);
      patternInfo[i][0] = Integer.toString(pi.startBucket);
      patternInfo[i][1] = Integer.toString(pi.length);
      if(type==DOUBLE_TYPE)
        patternInfo[i][2] = Double.toString(pi.value);
      else
        patternInfo[i][2] = Integer.toString((int)pi.value);
      patternInfo[i][3] = Integer.toString(pi.startBucket+pi.length-1);
    }
    patternModel.setDataVector(patternInfo, patternColName);

    // Calculate info and errors
    hasError = false;
    int bucketArray[] = new int[NB_BUCKET];
    for(int i=0;i<NB_BUCKET;i++) bucketArray[i] = 0;
    int sum = 0;
    int bunch = 0;
    int bucket = 0;
    boolean bucketOutOfBounds = false;
    for(int i=0;i<patterns.size();i++) {
      PatternInfo pi = (PatternInfo)patterns.get(i);
      sum += pi.value * pi.length;
      if(pi.value==0) bunch+=pi.length;
      bucket += pi.length;
      for(int j=0;j<pi.length;j++) {
        if(pi.startBucket+j<NB_BUCKET)
          bucketArray[pi.startBucket+j]++;
        else
          bucketOutOfBounds = true;
      }
    }
    sumText.setText(Integer.toString(sum));
    bunchText.setText(Integer.toString(bunch));
    bucketText.setText(Integer.toString(bucket));
    Vector overlaps = new Vector();
    Vector holes = new Vector();
    for(int i=0;i<NB_BUCKET;i++) {
      if(bucketArray[i]==0) holes.add(new Integer(i));
      if(bucketArray[i]>1) overlaps.add(new Integer(i));
    }
    StringBuffer errStr = new StringBuffer();
    if(holes.size()==0) {
      errStr.append("No hole detected\n");
    } else {
      errStr.append("Holes detected at :");
      for(int i=0;i<holes.size();i++) {
        errStr.append(((Integer)holes.get(i)).toString());
        errStr.append(" ");
      }
      errStr.append("\n");
      hasError = true;
    }
    if(overlaps.size()==0) {
      errStr.append("No overlap detected\n");
    } else {
      errStr.append("Overlaps detected at :");
      for(int i=0;i<overlaps.size();i++) {
        errStr.append(((Integer)overlaps.get(i)).toString());
        errStr.append(" ");
      }
      errStr.append("\n");
      hasError = true;
    }
    if( bucketOutOfBounds ) {
      errStr.append("Bucket out of bounds");
      errStr.append("\n");
      hasError = true;
    }
    errorText.setText(errStr.toString());

  }
  
  // Test function
  public static void main(String[] args) {
    final PatternEditorFrame fr = new PatternEditorFrame(INT_TYPE,"sr/d-mfdbk/utca-horizontal/BUN_1_FIRWF_S");
    fr.setVisible(true);
  }

}
