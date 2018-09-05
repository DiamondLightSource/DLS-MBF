package MBF;


import static MBF.MainPanel.NB_BUCKET;
import fr.esrf.tangoatk.widget.util.ATKConstant;
import fr.esrf.tangoatk.widget.util.ATKGraphicsUtils;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Pattern info editor
 */
public class PatternInfoDlg extends JDialog  implements ActionListener {

  private JPanel     innerPanel;
  private JLabel     sBucketLabel;
  private JTextField sBucketText;
  private JLabel     lengthLabel;
  private JTextField lengthText;
  private JLabel     valueLabel;
  private JTextField valueText;
  private JButton    cancelBtn;
  private JButton    okBtn;

  int startBucket;
  int length;
  double value;
  boolean okFlag;
  boolean performValueChecking;

  PatternInfoDlg(JFrame parent) {

    super(parent,true);

    this.performValueChecking = performValueChecking;

    innerPanel = new JPanel();
    innerPanel.setLayout(null);
    innerPanel.setPreferredSize(new Dimension(220,140));
    setContentPane(innerPanel);

    sBucketLabel = new JLabel("Start Bucket");
    sBucketLabel.setFont(ATKConstant.labelFont);
    sBucketLabel.setBounds(5,10,100,25);
    innerPanel.add(sBucketLabel);
    sBucketText = new JTextField();
    sBucketText.setEditable(true);
    sBucketText.setBounds(110,10,100,25);
    innerPanel.add(sBucketText);

    lengthLabel = new JLabel("Length");
    lengthLabel.setFont(ATKConstant.labelFont);
    lengthLabel.setBounds(5,40,100,25);
    innerPanel.add(lengthLabel);
    lengthText = new JTextField();
    lengthText.setEditable(true);
    lengthText.setBounds(110,40,100,25);
    innerPanel.add(lengthText);

    valueLabel = new JLabel("Value");
    valueLabel.setFont(ATKConstant.labelFont);
    valueLabel.setBounds(5,70,100,25);
    innerPanel.add(valueLabel);
    valueText = new JTextField();
    valueText.setEditable(true);
    valueText.setBounds(110,70,100,25);
    innerPanel.add(valueText);

    okBtn = new JButton("Ok");
    okBtn.addActionListener(this);
    okBtn.setBounds(5,110,90,25);
    innerPanel.add(okBtn);

    cancelBtn = new JButton("Cancel");
    cancelBtn.addActionListener(this);
    cancelBtn.setBounds(120,110,90,25);
    innerPanel.add(cancelBtn);

    setTitle("Add new pattern");
    setResizable(false);
    ATKGraphicsUtils.centerDialog(this);
  }

  public void actionPerformed(ActionEvent e) {

    Object src = e.getSource();

    if( src==cancelBtn ) {

      okFlag = false;
      setVisible(false);

    } else if ( src==okBtn ) {

      // Start bucket
      try {
        startBucket = Integer.parseInt(sBucketText.getText());
      } catch(NumberFormatException ex) {
        JOptionPane.showMessageDialog(this,"Invalid start bucket number");
        return;
      }
      if(startBucket<0 || startBucket>=NB_BUCKET) {
        JOptionPane.showMessageDialog(this,"Start bucket number out of range [0,"+(NB_BUCKET-1)+"]");
        return;
      }

      // Length
      try {
        length = Integer.parseInt(lengthText.getText());
      } catch(NumberFormatException ex) {
        JOptionPane.showMessageDialog(this,"Invalid length number");
        return;
      }
      if(length<=0 || length>NB_BUCKET) {
        JOptionPane.showMessageDialog(this,"Length number out of range [1,"+NB_BUCKET+"]");
        return;
      }

      // Value
      try {
        value = Integer.parseInt(valueText.getText());
      } catch(NumberFormatException ex) {
        JOptionPane.showMessageDialog(this,"Invalid value number");
        return;
      }

      okFlag = true;
      setVisible(false);

    }
  }

  public boolean showDlg() {

    setVisible(true);
    return okFlag;

  }

}
