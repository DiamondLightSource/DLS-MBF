//+=============================================================================
//
// file :         CleaningTask.cpp
//
//
// description :  Various cleaning step
//
// project :      TANGO Device Server 
//
// $Author: pons
//
//
// copyleft :     European Synchrotron Radiation Facility
//                BP 220, Grenoble 38043
//                FRANCE
//
//-=============================================================================
#include <CleaningTask.h>

namespace MBFCleaning_ns {

// Constructor:
CleaningTask::CleaningTask(MBFCleaning *cleaning, omni_mutex &m) :
        mutex(m), ds(cleaning) {
}

// ----------------------------------------------------------------------------------------

void CleaningTask::scrapper_up(bool updateState) {

  Tango::DeviceAttribute val;
  struct timespec nanotime;
  Tango::DeviceProxy *upp5Ds = NULL;
  Tango::DeviceProxy *low5Ds = NULL;
  Tango::DeviceProxy *upp25Ds = NULL;
  Tango::DeviceProxy *low25Ds = NULL;
  Tango::DeviceProxy *upp22Ds = NULL;
  Tango::DevState upp5_state;
  Tango::DevState low5_state;
  Tango::DevState upp25_state;
  Tango::DevState low25_state;
  Tango::DevState upp22_state;


  // Restore scraper value ---------------------------------------------------------------

  try {

    switch (ds->attr_Scrapers_read[0]) {

      case USE_UPP5LOW5:

        upp5Ds = new Tango::DeviceProxy(ds->scrUpp5Device);
        upp5Ds->set_source(Tango::DEV);
        val.set_name("Position");
        val << ds->Upp5_initpos;
        upp5Ds->write_attribute(val);
        cout << "ScraperUpThread: Write upp5 position " << ds->Upp5_initpos << endl;

        low5Ds = new Tango::DeviceProxy(ds->scrLow5Device);
        low5Ds->set_source(Tango::DEV);
        val.set_name("Position");
        val << ds->Low5_initpos;
        low5Ds->write_attribute(val);
        cout << "ScraperUpThread: Write low5 position " << ds->Low5_initpos << endl;

        // Wait while moving
        upp5_state = Tango::MOVING;
        low5_state = Tango::MOVING;
        while (upp5_state == Tango::MOVING || low5_state == Tango::MOVING) {

          // Sleep 1s
          nanotime.tv_sec = 1;
          nanotime.tv_nsec = 0;
          nanosleep(&nanotime, NULL);

          val = upp5Ds->read_attribute("State");
          val >> upp5_state;
          val = low5Ds->read_attribute("State");
          val >> low5_state;

        }

        break;

      case USE_UPP25LOW25:

        upp25Ds = new Tango::DeviceProxy(ds->scrUpp25Device);
        upp25Ds->set_source(Tango::DEV);
        val.set_name("Position");
        val << ds->Upp25_initpos;
        upp25Ds->write_attribute(val);
        cout << "ScraperUpThread: Write upp25 position " << ds->Upp25_initpos << endl;

        low25Ds = new Tango::DeviceProxy(ds->scrLow25Device);
        low25Ds->set_source(Tango::DEV);
        val.set_name("Position");
        val << ds->Low25_initpos;
        low25Ds->write_attribute(val);
        cout << "ScraperUpThread: Write low25 position " << ds->Low25_initpos << endl;

        // Wait while moving
        upp25_state = Tango::MOVING;
        low25_state = Tango::MOVING;
        while (upp25_state == Tango::MOVING || low25_state == Tango::MOVING) {

          // Sleep 1s
          nanotime.tv_sec = 1;
          nanotime.tv_nsec = 0;
          nanosleep(&nanotime, NULL);

          val = upp25Ds->read_attribute("State");
          val >> upp25_state;
          val = low25Ds->read_attribute("State");
          val >> low25_state;

        }

        break;

      case USE_UPP22:

        upp22Ds = new Tango::DeviceProxy(ds->scrUpp22Device);
        upp22Ds->set_source(Tango::DEV);
        val.set_name("Position");
        val << ds->Upp22_initpos;
        upp22Ds->write_attribute(val);
        cout << "ScraperUpThread: Write upp22 position " << ds->Upp22_initpos << endl;

        // Wait while moving
        upp22_state = Tango::MOVING;
        while (upp22_state == Tango::MOVING) {

          // Sleep 1s
          nanotime.tv_sec = 1;
          nanotime.tv_nsec = 0;
          nanosleep(&nanotime, NULL);

          val = upp22Ds->read_attribute("State");
          val >> upp22_state;

        }

        break;
    }

  } catch (Tango::DevFailed e) {

    cout << "SweepThread: Received DevFailed exception while moving scraper." << endl;
    Tango::Except::print_exception(e);

    if (upp5Ds) delete upp5Ds;
    if (low5Ds) delete low5Ds;
    if (upp25Ds) delete upp25Ds;
    if (low25Ds) delete low25Ds;
    if (upp22Ds) delete upp22Ds;
    {
      omni_mutex_lock l(mutex);
      string tmp;
      tmp = "Failure while moving scraper:\n" + string(e.errors[0].desc);
      ds->set_status(tmp.c_str());
      ds->set_state(Tango::OFF);
    }
    exit(0);

  }

  if (upp5Ds) delete upp5Ds;
  if (low5Ds) delete low5Ds;
  if (upp25Ds) delete upp25Ds;
  if (low25Ds) delete low25Ds;
  if (upp22Ds) delete upp22Ds;
  {
    omni_mutex_lock l(mutex);
    if (updateState) {
      ds->set_state(Tango::OFF);
    }
    ds->set_status("Device ready");
  }


}

// ----------------------------------------------------------------------------------------

void CleaningTask::scrapper_down(bool updateState) {

  Tango::DeviceAttribute val;
  struct timespec nanotime;
  Tango::DeviceProxy *upp5Ds = NULL;
  Tango::DeviceProxy *low5Ds = NULL;
  Tango::DeviceProxy *upp25Ds = NULL;
  Tango::DeviceProxy *low25Ds = NULL;
  Tango::DeviceProxy *upp22Ds = NULL;
  Tango::DevState upp5_state;
  Tango::DevState low5_state;
  Tango::DevState upp25_state;
  Tango::DevState low25_state;
  Tango::DevState upp22_state;

  // Read init position of scraper -------------------------------------------------------------------

  try {

    switch (ds->attr_Scrapers_read[0]) {

      case USE_UPP5LOW5:

        upp5Ds = new Tango::DeviceProxy(ds->scrUpp5Device);
        upp5Ds->set_source(Tango::DEV);
        val = upp5Ds->read_attribute("Position");
        val >> ds->Upp5_initpos;
        cout << "ScraperDownThread: Read upp5 position " << ds->Upp5_initpos << endl;

        low5Ds = new Tango::DeviceProxy(ds->scrLow5Device);
        low5Ds->set_source(Tango::DEV);
        val = low5Ds->read_attribute("Position");
        val >> ds->Low5_initpos;
        cout << "ScraperDownThread: Read low5 position " << ds->Low5_initpos << endl;

        break;

      case USE_UPP25LOW25:

        upp25Ds = new Tango::DeviceProxy(ds->scrUpp25Device);
        upp25Ds->set_source(Tango::DEV);
        val = upp25Ds->read_attribute("Position");
        val >> ds->Upp25_initpos;
        cout << "ScraperDownThread: Read upp25 position " << ds->Upp25_initpos << endl;

        low25Ds = new Tango::DeviceProxy(ds->scrLow25Device);
        low25Ds->set_source(Tango::DEV);
        val = low25Ds->read_attribute("Position");
        val >> ds->Low25_initpos;
        cout << "ScraperDownThread: Read low25 position " << ds->Low25_initpos << endl;

        break;

      case USE_UPP22:

        upp22Ds = new Tango::DeviceProxy(ds->scrUpp22Device);
        upp22Ds->set_source(Tango::DEV);
        val = upp22Ds->read_attribute("Position");
        val >> ds->Upp22_initpos;
        cout << "ScraperDownThread: Read upp22 position " << ds->Upp22_initpos << endl;

        break;
    }

  } catch (Tango::DevFailed e) {

    cout << "ScraperDownThread: Received DevFailed exception while getting scraper values." << endl;
    Tango::Except::print_exception(e);

    if (upp5Ds) delete upp5Ds;
    if (low5Ds) delete low5Ds;
    if (upp25Ds) delete upp25Ds;
    if (low25Ds) delete low25Ds;
    if (upp22Ds) delete upp22Ds;

    {
      omni_mutex_lock l(mutex);
      string tmp;
      tmp = "Failure while moving scraper:\n" + string(e.errors[0].desc);
      ds->set_status(tmp.c_str());
      ds->set_state(Tango::OFF);
    }
    exit(0);

  }


  // Move scraper to cleaning value ---------------------------------------------------------------

  // Sleep 1s
  nanotime.tv_sec = 1;
  nanotime.tv_nsec = 0;
  nanosleep(&nanotime, NULL);

  try {

    switch (ds->attr_Scrapers_read[0]) {

      case USE_UPP5LOW5:

        val.set_name("Position");
        val << ds->attr_Upp5_read[0];
        upp5Ds->write_attribute(val);
        cout << "ScraperDownThread: Write upp5 position " << ds->attr_Upp5_read[0] << endl;

        val.set_name("Position");
        val << ds->attr_Low5_read[0];
        low5Ds->write_attribute(val);
        cout << "ScraperDownThread: Write low5 position " << ds->attr_Low5_read[0] << endl;

        // Wait while moving
        upp5_state = Tango::MOVING;
        low5_state = Tango::MOVING;
        while (upp5_state == Tango::MOVING || low5_state == Tango::MOVING) {

          // Sleep 1s
          nanotime.tv_sec = 1;
          nanotime.tv_nsec = 0;
          nanosleep(&nanotime, NULL);

          val = upp5Ds->read_attribute("State");
          val >> upp5_state;
          val = low5Ds->read_attribute("State");
          val >> low5_state;

        }

        break;

      case USE_UPP25LOW25:

        val.set_name("Position");
        val << ds->attr_Upp25_read[0];
        upp25Ds->write_attribute(val);
        cout << "ScraperDownThread: Write upp25 position " << ds->attr_Upp25_read[0] << endl;

        val.set_name("Position");
        val << ds->attr_Low25_read[0];
        low25Ds->write_attribute(val);
        cout << "ScraperDownThread: Write low25 position " << ds->attr_Low25_read[0] << endl;

        // Wait while moving
        upp25_state = Tango::MOVING;
        low25_state = Tango::MOVING;
        while (upp25_state == Tango::MOVING || low25_state == Tango::MOVING) {

          // Sleep 1s
          nanotime.tv_sec = 1;
          nanotime.tv_nsec = 0;
          nanosleep(&nanotime, NULL);

          val = upp25Ds->read_attribute("State");
          val >> upp25_state;
          val = low25Ds->read_attribute("State");
          val >> low25_state;

        }

        break;

      case USE_UPP22:

        val.set_name("Position");
        val << ds->attr_Upp22_read[0];
        upp22Ds->write_attribute(val);
        cout << "ScraperDownThread: Write upp22 position " << ds->attr_Upp22_read[0] << endl;

        // Wait while moving
        upp22_state = Tango::MOVING;
        while (upp22_state == Tango::MOVING) {

          // Sleep 1s
          nanotime.tv_sec = 1;
          nanotime.tv_nsec = 0;
          nanosleep(&nanotime, NULL);

          val = upp22Ds->read_attribute("State");
          val >> upp22_state;

        }

        break;
    }

  } catch (Tango::DevFailed e) {

    cout << "SweepThread: Received DevFailed exception while moving scraper." << endl;
    Tango::Except::print_exception(e);

    if (upp5Ds) delete upp5Ds;
    if (low5Ds) delete low5Ds;
    if (upp25Ds) delete upp25Ds;
    if (low25Ds) delete low25Ds;
    if (upp22Ds) delete upp22Ds;
    {
      omni_mutex_lock l(mutex);
      string tmp;
      tmp = "Failure while moving scraper:\n" + string(e.errors[0].desc);
      ds->set_status(tmp.c_str());
      ds->set_state(Tango::ON);
    }
    exit(0);

  }

  if (upp5Ds) delete upp5Ds;
  if (low5Ds) delete low5Ds;
  if (upp25Ds) delete upp25Ds;
  if (low25Ds) delete low25Ds;
  if (upp22Ds) delete upp22Ds;
  {
    if (updateState) {
      omni_mutex_lock l(mutex);
      ds->set_state(Tango::ON);
    }
    ds->set_status("Ready to sweep");
  }


}

// ----------------------------------------------------------------------------------------

void CleaningTask::sweep(bool updateState) {

  Tango::DeviceAttribute val;
  struct timespec nanotime;


  try {

    if( ds->attr_ExternalSweep_read[0] ) {

      // Use external shaker

      // Write starting freq
      double amplitude = (ds->attr_Gain_read[0]/10.0); // 0-10V
      val.set_name("Amplitude");
      val << amplitude;
      ds->shakerDS->write_attribute(val);

      double freqMin = ds->attr_FreqMin_read[0]*SR_FREQ;
      double freqMax = ds->attr_FreqMax_read[0]*SR_FREQ;
      double freq = freqMin;
      val.set_name("Frequency");
      val << freq;
      ds->shakerDS->write_attribute(val);

      sleep(1);

      // Switch on the shaker
      ds->shakerDS->command_inout("On");
      sleep(1);

      // Sweep ---------------------------------------------------------------------------------

      int nb_step = (int) (ds->attr_SweepTime_read[0] / 0.05);
      int count = 20;

      cout << "SweepThread: Sweep from " << freqMin << "Hz to " << freqMax << "Hz" << endl;

      for (int i = 0; i <= nb_step; i++) {

        freq = freqMin +  (freqMax - freqMin) * ((double) i / (double) nb_step);
        val << freq;
        ds->shakerDS->write_attribute(val);

        // Sleep 50ms
        nanotime.tv_sec = 0;
        nanotime.tv_nsec = 50000000;
        nanosleep(&nanotime, NULL);

        count++;
        if (count > 20) {
          omni_mutex_lock l(mutex);
          char tmp[256];
          sprintf(tmp, "Sweeping: %.0fHz", freq);
          ds->set_status(tmp);
          count = 0;
        }

      }

      // Switch on the shaker
      ds->shakerDS->command_inout("Off");
      sleep(1);

    } else {

      // Use MBF NCO

      // Launch clening
      ds->mbfDS->command_inout("Clean");
      sleep(1);

      // Wait end of cleaning
      Tango::DevState mbfState = Tango::MOVING;
      while( mbfState==Tango::MOVING ) {

        // Get the last line of the macro history for the status
        Tango::DeviceAttribute da = ds->mbfDS->read_attribute("MacroHistory");
        if( da.get_quality() == Tango::ATTR_VALID ) {
          vector<string> hist;
          da >> hist;
          ds->set_status(hist[hist.size()-1]);
        }

        usleep(500000);

        ds->mbfDS->read_attribute("State") >> mbfState;

      }

    }

  } catch (Tango::DevFailed e) {
    cout << "SweepThread: Received DevFailed exception while sweeping." << endl;
    Tango::Except::print_exception(e);
    ds->set_status("SweepThread Error:" + string(e.errors[0].desc.in()));
    exit(0);
  }

  {
    if (updateState) {
      omni_mutex_lock l(mutex);
      ds->set_state(Tango::ON);
    }
    ds->set_status("Sweep done succesfully");
  }


}


} // namespace MultiBunchCleaning_ns

