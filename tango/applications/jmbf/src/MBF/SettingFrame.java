/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package MBF;

import fr.esrf.tangoatk.widget.attribute.NumberScalarSetPanel;
import fr.esrf.tangoatk.widget.util.JSmoothLabel;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;

class SettingFrame extends JFrame implements ActionListener {

  static Font titleFont = new Font("Dialog", Font.BOLD, 18);
  static Font setterFont = new Font("Dialog", Font.BOLD, 14);

  JSmoothLabel title;
  NumberScalarSetPanel setPanel;
  JButton dismissButton;

  public SettingFrame() {

    getContentPane().setLayout(new BorderLayout());

    this.title = new JSmoothLabel();
    this.title.setFont(titleFont);
    this.title.setBackground(getContentPane().getBackground());
    getContentPane().add(this.title,BorderLayout.NORTH);

    setPanel = new NumberScalarSetPanel();
    //setPanel.setLabelVisible(false);
    setPanel.setFont(setterFont);
    setPanel.setBorder(BorderFactory.createEmptyBorder(5,5,10,5));
    setPanel.getViewer().setAlarmEnabled(false);
    getContentPane().add(setPanel, BorderLayout.CENTER);

    JPanel btnPanel = new JPanel();
    btnPanel.setLayout(new FlowLayout(FlowLayout.RIGHT));
    getContentPane().add(btnPanel,BorderLayout.SOUTH);

    dismissButton = new JButton("Dismiss");
    dismissButton.addActionListener(this);
    btnPanel.add(dismissButton);
    setTitle("Setting");


  }

  public void actionPerformed(ActionEvent e) {
    if(e.getSource()==dismissButton) {
      setVisible(false);
    }
  }
        
  public void clearModel() {
    setPanel.clearModel();
  }

}
