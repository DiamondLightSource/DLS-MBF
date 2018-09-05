//+=============================================================================
//
// file :         DoAllThread.cpp
//
//
// description :  This class is used for non blocking cleaning task
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
#include <DoAllThread.h>
#include <CleaningTask.h>

namespace MBFCleaning_ns
{

  // Constructor:
  DoAllThread::DoAllThread(MBFCleaning *cleaning, omni_mutex &m):
    Tango::LogAdapter(cleaning), mutex(m), ds(cleaning)
  {
    INFO_STREAM << "DoAllThread::DoAllThread(): entering." << endl;
    start();
  }

  // ----------------------------------------------------------------------------------------

  void DoAllThread::run(void *arg)
  {
    
    CleaningTask ct(ds,mutex);

    ct.scrapper_down(false);    

    ct.sweep(false);

    {
      omni_mutex_lock l(mutex);
      ds->set_status("Moving scrappers");
    }
    ct.scrapper_up(true);
    
  }
  

} // namespace MultiBunchCleaning_ns

