package CLEANING;

import fr.esrf.tangoatk.core.*;
import fr.esrf.tangoatk.widget.attribute.SimpleScalarViewer;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;
import fr.esrf.tangoatk.widget.util.ErrorHistory;
import fr.esrf.tangoatk.widget.util.ErrorPopup;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Vector;

/**
 * A panel for the configuration file
 */
public class ConfigFilePanel extends JPanel implements IResultListener, ActionListener {

  private Insets bMargin = new Insets(2,3,2,3);
  private AttributeList attList;
  private CommandList   cmdList;
  private ICommand      gfilePathModel;
  private String        configFilePath=null;
  private ICommand      loadCmd;
  private ICommand      saveCmd;

  private SimpleScalarViewer configFileViewer;
  private JButton loadConfigBtn;
  private JButton saveConfigBtn;
  private JButton previewConfigBtn;

  private PreviewDialog previewDialog = null;
  private String devName = "";

  ConfigFilePanel(String title) {

    setLayout(new GridBagLayout());
    setBorder( BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(), title,
                            TitledBorder.LEFT, TitledBorder.DEFAULT_POSITION,
                            new Font("Dialog",Font.BOLD,12), Color.BLACK) );
    
    GridBagConstraints gbc = new GridBagConstraints();
    gbc.fill = GridBagConstraints.BOTH;
    gbc.weightx = 1.0;    
    gbc.weighty = 1.0;    
    gbc.insets.top = 2;
    gbc.insets.left = 2;
    gbc.insets.bottom = 2;
    gbc.insets.right = 2;

    configFileViewer = new SimpleScalarViewer();
    configFileViewer.setBackgroundColor(new Color(255,255,255));
    configFileViewer.setBorder(BorderFactory.createLoweredBevelBorder());
    add(configFileViewer,gbc);
    
    gbc.weightx = 0.0;

    loadConfigBtn = new JButton("Load");
    loadConfigBtn.setFont(ATKConstant.labelFont);
    loadConfigBtn.setMargin(bMargin);
    loadConfigBtn.addActionListener(this);
    add(loadConfigBtn,gbc);

    saveConfigBtn = new JButton("Save");
    saveConfigBtn.setFont(ATKConstant.labelFont);
    saveConfigBtn.setMargin(bMargin);
    saveConfigBtn.addActionListener(this);
    add(saveConfigBtn,gbc);

    previewConfigBtn = new JButton("View");
    previewConfigBtn.setFont(ATKConstant.labelFont);
    previewConfigBtn.setMargin(bMargin);
    previewConfigBtn.addActionListener(this);
    add(previewConfigBtn,gbc);

  }

  public void setModel(String devName, ErrorHistory errWin) {
    setModel(devName,errWin,"ConfigFileName");
  }
  
  public void setModel(String devName, ErrorHistory errWin,String configNameAtt) {

    this.devName = devName;
    attList = new AttributeList();
    attList.addErrorListener(errWin);
    cmdList = new CommandList();
    try {

      // Config file name attribute
      IStringScalar cfileModel = (IStringScalar)attList.add(devName+"/"+configNameAtt);
      configFileViewer.setModel(cfileModel);

      // Commands
      gfilePathModel = (ICommand)cmdList.add(devName+"/GetConfigurationFilePath");
      gfilePathModel.addErrorListener(errWin);
      gfilePathModel.addResultListener(this);
      gfilePathModel.execute();

      loadCmd = (ICommand)cmdList.add(devName+"/LoadConfigurationFile");
      loadCmd.addErrorListener(ErrorPopup.getInstance());
      saveCmd = (ICommand)cmdList.add(devName+"/SaveConfigurationFile");
      saveCmd.addErrorListener(ErrorPopup.getInstance());

      // Set timeout to 10 sec
      DeviceFactory.getInstance().getDevice(devName).setDevTimeout(10000);

    } catch (ConnectionException e) {
    }
    attList.startRefresher();

  }

  public void clearModel() {

    attList.stopRefresher();
    
  }

  public void resultChange(ResultEvent e)
  {

      Object src = e.getSource();
      if( src==gfilePathModel ) {
        System.out.println("Get Res Path=" + e.getResult());
        setDirPath(e);
      }

  }

  public void errorChange(ErrorEvent e)
  {
  }

  public void actionPerformed(ActionEvent e) {
    Object src = e.getSource();
    if ( src==loadConfigBtn ) {
      loadConfigFile();
    } else if ( src==saveConfigBtn ) {
      saveConfigFile();
    } else if ( src==previewConfigBtn ) {
      previewConfigFile();
    }
  }

  private void setDirPath(ResultEvent resEvent)
  {
      java.util.List result = null;
      Object resElem = null;

      result = resEvent.getResult();
      
      if (result == null)
      {
          return;
      }
      if (result.isEmpty())
      {
          return;
      }

      try
      {
          resElem = result.get(0);
      }
      catch (java.lang.IndexOutOfBoundsException iob)
      {
          return;
      }

      if (resElem == null)
      {
          return;
      }
      if (!(resElem instanceof String))
      {
          return;
      }

      String cFilePath = (String) resElem;
      // The following lines are added to work around a Bug appeared since Java 1.5.
      // Bug description : When a mounting point is used through a symbolic link in a file system
      //    (for example /operation -->link--> /_mntdirect/operation (which is the real mounting point)
      //  The first time the "FileChooser.setCurrentDirectory(new File(serverDirPath)) is called the path returned through
      //  filechooser.getSelelectedFile().getAbsolutePath() or getPath() is the path with the real mounting point
      //  where the second call to FileChooser.setCurrentDirectory(new File(serverDirPath)) will make the
      //  filechooser.getSelelectedFile().getAbsolutePath() return the path using the symbolique link. To avoid this
      //  inconsistency we should save the ServerDirPath with the symbolic link resolved (not containing any symb. link)
      //  by calling getCanonicalPath();
      File sDir = new File(cFilePath);
      try
      {
          configFilePath = sDir.getCanonicalPath();
      }
      catch (IOException ioex)
      {
      }

  }

  void previewConfigFile() {

    int dialReturn;
    String selectedFilePath;
    String shortFileName;
    int serverPathLength;

    if (configFilePath == null) {
        javax.swing.JOptionPane.showMessageDialog(
                null, "Cannot get the config file root directory.\n"
                + "Check that the device " + devName + " is running and responding correctly to command GetConfigurationFilePath.\n",
                "Load config file aborted\n",
                javax.swing.JOptionPane.ERROR_MESSAGE);
        return;
    }

    serverPathLength = configFilePath.length();
    if (serverPathLength <= 0) {
        javax.swing.JOptionPane.showMessageDialog(
                null, "The config file root directory is not set correctly.\n"
                + "Check that the device " + devName + " + is running and responding correctly to command GetConfigurationFilePath.\n",
                "Load config file aborted\n",
                javax.swing.JOptionPane.ERROR_MESSAGE);
        return;
    }

    JFileChooser fc = new JFileChooser();
    fc.setCurrentDirectory(new File(configFilePath));

    dialReturn = fc.showDialog(this, "View");

    if (dialReturn == JFileChooser.APPROVE_OPTION)
    {

      try
      {
          selectedFilePath = fc.getSelectedFile().getCanonicalPath();
          shortFileName = fc.getSelectedFile().getName();
      }
      catch (IOException ioex)
      {
          javax.swing.JOptionPane.showMessageDialog(
                  null, "Failed to get the canonical path of the selected file.\n\n"
                  + ioex + "\n\n\n",
                  "Load config file aborted\n",
                  javax.swing.JOptionPane.ERROR_MESSAGE);
          return;
      }

      StringBuffer cFile = new StringBuffer();

      try {

        FileReader f = new FileReader(selectedFilePath);
        while(f.ready())
          cFile.append((char)f.read());
        f.close();

      } catch(IOException e) {
        JOptionPane.showMessageDialog(this,"Error while loading file:\n"+e.getMessage(),"Error",JOptionPane.ERROR_MESSAGE);
        return;
      }

      if( previewDialog==null ) previewDialog = new PreviewDialog();
      previewDialog.setText(cFile.toString());
      previewDialog.setTitle("Configuration file [" + shortFileName + "]");
      ATKGraphicsUtils.centerFrameOnScreen(previewDialog);
      previewDialog.setVisible(true);
      
    }

  }

  void loadConfigFile()
  {
      int dialReturn;
      String selectedFilePath = null, fileRelativePathName = null;
      int serverPathLength = 0, filePathLength = 0, increment = 1;

      if (configFilePath == null) {
          javax.swing.JOptionPane.showMessageDialog(
                  null, "Cannot get the config file root directory.\n"
                  + "Check that the device " + devName + " is running and responding correctly to command GetConfigurationFilePath.\n",
                  "Load config file aborted\n",
                  javax.swing.JOptionPane.ERROR_MESSAGE);
          return;
      }

      serverPathLength = configFilePath.length();
      if (serverPathLength <= 0) {
          javax.swing.JOptionPane.showMessageDialog(
                  null, "The config file root directory is not set correctly.\n"
                  + "Check that the device " + devName + " + is running and responding correctly to command GetConfigurationFilePath.\n",
                  "Load config file aborted\n",
                  javax.swing.JOptionPane.ERROR_MESSAGE);
          return;
      }

      if (configFilePath.endsWith(File.separator)) {
        increment = 0;
      } else {
        increment = 1;
      }

      JFileChooser fc = new JFileChooser();
      fc.setCurrentDirectory(new File(configFilePath));

      dialReturn = fc.showDialog(this, "Load");

      if (dialReturn == JFileChooser.APPROVE_OPTION)
      {
          try
          {
              selectedFilePath = fc.getSelectedFile().getCanonicalPath();
          }
          catch (IOException ioex)
          {
              javax.swing.JOptionPane.showMessageDialog(
                      null, "Failed to get the canonical path of the selected file.\n\n"
                      + ioex + "\n\n\n",
                      "Load config file aborted\n",
                      javax.swing.JOptionPane.ERROR_MESSAGE);
              return;
          }
          filePathLength = selectedFilePath.length();

          if (!selectedFilePath.startsWith(configFilePath))
          {
              javax.swing.JOptionPane.showMessageDialog(
                      null, "The selected file is not inside the authorized root directory.\n\n"
                      + "The file should be located in " + configFilePath + " directory tree.\n\n",
                      "Load config file aborted\n",
                      javax.swing.JOptionPane.ERROR_MESSAGE);
              return;
          }


          if ((serverPathLength + increment) >= filePathLength)
          {
              javax.swing.JOptionPane.showMessageDialog(
                      null, "Invalid config file name :" + selectedFilePath + ".\n\n",
                      "Load config file aborted\n",
                      javax.swing.JOptionPane.ERROR_MESSAGE);
              return;
          }

          fileRelativePathName = selectedFilePath.substring(serverPathLength + increment);
          System.out.println("call " + loadCmd.getName() + " command on server with = " + fileRelativePathName);

          Vector inputArg = new Vector();
          inputArg.add(fileRelativePathName);

          loadCmd.execute(inputArg);
      }
  }

  void saveConfigFile()
  {
      int dialReturn;
      String selectedFilePath = null, fileRelativePathName = null;
      int serverPathLength = 0, filePathLength = 0, increment = 1;

      if (configFilePath == null) {
          javax.swing.JOptionPane.showMessageDialog(
                  null, "Cannot get the config file root directory.\n"
                  + "Check that the device " + devName + " + is running and responding correctly to command GetConfigurationFilePath.\n",
                  "Load config file aborted\n",
                  javax.swing.JOptionPane.ERROR_MESSAGE);
          return;
      }

      serverPathLength = configFilePath.length();
      if (serverPathLength <= 0) {
          javax.swing.JOptionPane.showMessageDialog(
                  null, "The config file root directory is not set correctly.\n"
                  + "Check that the device " + devName + " + is running and responding correctly to command GetConfigurationFilePath.\n",
                  "Load config file aborted\n",
                  javax.swing.JOptionPane.ERROR_MESSAGE);
          return;
      }

      if (configFilePath.endsWith(File.separator)) {
        increment = 0;
      } else {
        increment = 1;
      }

      JFileChooser fc = new JFileChooser();
      fc.setCurrentDirectory(new File(configFilePath));

      dialReturn = fc.showDialog(this, "Save");

      if (dialReturn == JFileChooser.APPROVE_OPTION)
      {
          try
          {
              selectedFilePath = fc.getSelectedFile().getCanonicalPath();
          }
          catch (IOException ioex)
          {
              javax.swing.JOptionPane.showMessageDialog(
                      null, "Failed to get the canonical path of the selected file.\n\n"
                      + ioex + "\n\n\n",
                      "Load config file aborted\n",
                      javax.swing.JOptionPane.ERROR_MESSAGE);
              return;
          }
          filePathLength = selectedFilePath.length();

          if (!selectedFilePath.startsWith(configFilePath))
          {
              javax.swing.JOptionPane.showMessageDialog(
                      null, "The selected file is not inside the authorized root directory.\n\n"
                      + "The file should be located in " + configFilePath + " directory tree.\n\n",
                      "Save config file aborted\n",
                      javax.swing.JOptionPane.ERROR_MESSAGE);
              return;
          }


          if ((serverPathLength + increment) >= filePathLength)
          {
              javax.swing.JOptionPane.showMessageDialog(
                      null, "Invalid config file name :" + selectedFilePath + ".\n\n",
                      "Save config file aborted\n",
                      javax.swing.JOptionPane.ERROR_MESSAGE);
              return;
          }

          fileRelativePathName = selectedFilePath.substring(serverPathLength + increment);
          System.out.println("call " + saveCmd.getName() + " command on server with = " + fileRelativePathName);

          Vector inputArg = new Vector();
          inputArg.add(fileRelativePathName);

          saveCmd.execute(inputArg);
      }
  }

}
