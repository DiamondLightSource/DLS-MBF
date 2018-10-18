package CLEANING;

import fr.esrf.tangoatk.core.*;
import fr.esrf.tangoatk.core.attribute.DevStateScalar;
import fr.esrf.tangoatk.core.attribute.NumberSpectrum;
import fr.esrf.tangoatk.core.attribute.StringScalar;
import fr.esrf.tangoatk.core.command.VoidVoidCommand;
import fr.esrf.tangoatk.widget.attribute.NumberSpectrumViewer;
import fr.esrf.tangoatk.widget.attribute.ScalarListViewer;
import fr.esrf.tangoatk.widget.attribute.StateViewer;
import fr.esrf.tangoatk.widget.attribute.StatusViewer;
import fr.esrf.tangoatk.widget.command.VoidVoidCommandViewer;
import fr.esrf.tangoatk.widget.util.ErrorHistory;
import fr.esrf.tangoatk.widget.util.ErrorPopup;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Agilent 33500B Waveform generator (Used for external shaker)
 */
public class WaveformPanel extends JPanel implements ActionListener {

  private final static Font borderFont = new Font("Dialog",Font.BOLD,12);

  private String devName;

  private JPanel cmdPanel;
  private JTabbedPane attPanel;
  private JPanel innerPanel;
  private JPanel upPanel;
  private JPanel downPanel;

  private StatusViewer statusViewer = null;
  private StateViewer stateViewer = null;
  private ConfigFilePanel configPanel;

  private AttributeList attStatusList;
  private AttributeList attList;
  private AttributeList attWaveformList;
  private CommandList cmdList;

  private VoidVoidCommandViewer     onCmd = null;
  private VoidVoidCommand           onCommand = null;
  private VoidVoidCommandViewer     offCmd = null;
  private VoidVoidCommand           offCommand = null;
  private VoidVoidCommandViewer     resetCmd = null;
  private VoidVoidCommand           resetCommand = null;
  private JButton                   expertBtn = null;

  private ScalarListViewer listViewer;

  private NumberSpectrumViewer waveformViewer;
  
  private ErrorHistory errWin;

  public WaveformPanel(String devName,ErrorHistory errWin) {

    this.devName = devName;
    this.errWin = errWin;


    setLayout(new BorderLayout());
    upPanel = new JPanel();
    upPanel.setLayout(new BorderLayout());

    configPanel = new ConfigFilePanel("Waveform Configuration File");
    configPanel.setModel(devName,errWin,"Configuration_File");
    upPanel.add(configPanel,BorderLayout.NORTH);


    JPanel stateStatusPanel = new JPanel();
    stateStatusPanel.setLayout(new BorderLayout());
    
    JPanel statePanel = new JPanel();
    statePanel.setLayout(new FlowLayout(FlowLayout.CENTER));
    stateViewer = new StateViewer();
    statePanel.add(stateViewer);
    stateStatusPanel.add(statePanel,BorderLayout.NORTH);
    
    statusViewer = new StatusViewer();
    statusViewer.setPreferredSize(new Dimension(380,80));    
    stateStatusPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(), "Status",
                            TitledBorder.LEFT, TitledBorder.DEFAULT_POSITION,
                            new Font("Dialog",Font.BOLD,12), Color.BLACK));
    
    stateStatusPanel.add(statusViewer,BorderLayout.CENTER);
    
    upPanel.add(stateStatusPanel,BorderLayout.CENTER);

    cmdPanel = new JPanel();
    cmdPanel.setLayout(null);
    cmdPanel.setPreferredSize(new Dimension(120,140));
    upPanel.add(cmdPanel,BorderLayout.EAST);

    add(upPanel,BorderLayout.NORTH);

    onCmd = new VoidVoidCommandViewer();
    onCmd.setExtendedParam("text", "On", false);
    onCmd.setBounds(10,20,100,25);
    cmdPanel.add(onCmd);

    offCmd = new VoidVoidCommandViewer();
    offCmd.setExtendedParam("text", "Off", false);
    offCmd.setBounds(10,50,100,25);
    cmdPanel.add(offCmd);

    resetCmd = new VoidVoidCommandViewer();
    resetCmd.setExtendedParam("text", "Reset", false);
    resetCmd.setBounds(10,80,100,25);
    cmdPanel.add(resetCmd);

    expertBtn = new JButton("Expert");
    expertBtn.addActionListener(this);
    expertBtn.setBounds(10,110,100,25);
    cmdPanel.add(expertBtn);

    attPanel = new JTabbedPane();

    attPanel.setPreferredSize(new Dimension(380,400));
    add(attPanel,BorderLayout.CENTER);

    listViewer = new ScalarListViewer();
    JScrollPane scrollPane = new JScrollPane(listViewer);
    scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    attPanel.addTab("Parameters", scrollPane);

    waveformViewer = new NumberSpectrumViewer();
    attPanel.addTab("Waveform", waveformViewer);


    // Connect to attribute
    attStatusList = new AttributeList();
    attStatusList.addErrorListener(errWin);
    attList = new AttributeList();
    attList.addErrorListener(errWin);
    attList.addSetErrorListener(ErrorPopup.getInstance());
    attList.setFilter(
        new IEntityFilter() {
          public boolean keep(IEntity entity) {
            if (entity instanceof INumberScalar) {
              return true;
            }
            if (entity instanceof IEnumScalar) {
              return true;
            }
            if (entity instanceof IBooleanScalar) {
              return true;
            }
            if (entity instanceof INumberSpectrum) {
              return true;
            }
            return false;
          }
        }
    );
    attWaveformList = new AttributeList();
    attWaveformList.addErrorListener(errWin);

    cmdList = new CommandList();
    cmdList.addErrorListener(errWin);
    cmdList.addErrorListener(ErrorPopup.getInstance());

    try {

      DevStateScalar stateModel = (DevStateScalar)attStatusList.add(devName + "/State");
      stateViewer.setModel(stateModel);
      
      StringScalar statusModel = (StringScalar)attStatusList.add(devName + "/Status");
      statusViewer.setModel(statusModel);

      onCommand = (VoidVoidCommand)cmdList.add(devName+"/On");
      onCommand.addErrorListener(ErrorPopup.getInstance());
      onCmd.setModel(onCommand);

      offCommand = (VoidVoidCommand)cmdList.add(devName+"/Off");
      offCommand.addErrorListener(ErrorPopup.getInstance());
      offCmd.setModel(offCommand);

      resetCommand = (VoidVoidCommand)cmdList.add(devName+"/Reset");
      resetCommand.addErrorListener(ErrorPopup.getInstance());
      resetCmd.setModel(resetCommand);

      attList.add(devName+"/*");
      listViewer.setModel(attList);

      NumberSpectrum waveModel = (NumberSpectrum)attWaveformList.add(devName+"/Waveform");
      waveformViewer.setModel(waveModel);

    } catch( Exception e ) {
      System.out.println(e.getMessage());
    }

    statusViewer.setBorder(null);
    attList.setRefreshInterval(1000);
    attList.startRefresher();
    attStatusList.setRefreshInterval(1000);
    attStatusList.startRefresher();
    attWaveformList.setRefreshInterval(1000);
    attWaveformList.startRefresher();


  }

  public void actionPerformed(ActionEvent e) {

    Object src = e.getSource();

    if( src==expertBtn ) {

      new atkpanel.MainPanel(devName,false);

    }

  }
  
  public JTabbedPane getTabPane() {
    return attPanel;
  }

  public void clearModel() {

    if(stateViewer!=null) stateViewer.clearModel();
    if(statusViewer!=null) statusViewer.setModel(null);
    if(listViewer!=null) listViewer.setModel(null);
    if(waveformViewer!=null) waveformViewer.setModel(null);
    if(onCmd!=null) onCmd.setModel((ICommand)null);
    if(onCommand!=null) onCommand.removeErrorListener(ErrorPopup.getInstance());
    if(offCmd!=null) offCmd.setModel((ICommand)null);
    if(offCommand!=null) offCommand.removeErrorListener(ErrorPopup.getInstance());

    attList.stopRefresher();
    attList.removeErrorListener(errWin);
    attList.clear();
    attList = null;

    attWaveformList.stopRefresher();
    attWaveformList.removeErrorListener(errWin);
    attWaveformList.clear();
    attWaveformList = null;

    attStatusList.stopRefresher();
    attStatusList.removeErrorListener(errWin);
    attStatusList.clear();
    attStatusList = null;

    cmdList.removeErrorListener(errWin);
    cmdList.clear();
    cmdList = null;

  }


}
