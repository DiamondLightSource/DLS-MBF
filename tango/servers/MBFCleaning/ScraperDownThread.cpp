//+=============================================================================
//
// file :         ScraperDownThread.cpp
//
//
// description :  This class is used for non blocking scraper motion
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
#include <ScraperDownThread.h>
#include <CleaningTask.h>

namespace MBFCleaning_ns
{

  // Constructor:
  ScraperDownThread::ScraperDownThread(MBFCleaning *cleaning, omni_mutex &m):
    Tango::LogAdapter(cleaning), mutex(m), ds(cleaning)
  {
    INFO_STREAM << "ScraperDownThread::ScraperDownThread(): entering." << endl;
    start();
  }

  // ----------------------------------------------------------------------------------------

  void ScraperDownThread::run(void *arg)
  {
  
    CleaningTask ct(ds,mutex);
    ct.scrapper_down(true);
    
  }
  

} // namespace MBFCleaning_ns

