//+=============================================================================
//
// file :         SweepThread.cpp
//
//
// description :  This class is used for non blocking frequency sweep
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
#include <SweepThread.h>
#include <CleaningTask.h>

namespace MBFCleaning_ns
{

  // Constructor:
  SweepThread::SweepThread(MBFCleaning *cleaning, omni_mutex &m):
    Tango::LogAdapter(cleaning), mutex(m), ds(cleaning)
  {
    INFO_STREAM << "SweepThread::SweepThread(): entering." << endl;
    start();
  }

  // ----------------------------------------------------------------------------------------

  void SweepThread::run(void *arg)
  {
    
    CleaningTask ct(ds,mutex);
    ct.sweep(true);
    
  }
  

} // namespace MultiBunchCleaning_ns

