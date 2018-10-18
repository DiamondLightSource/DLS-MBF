//+=============================================================================
//
// file :         DoAllThread.h
//
// description :  Include for the DoAll class.
//                This class is used for non blocking cleaning task
//
// project :      TANGO Device Server 
//
// $Author: pons
//
//
//
// copyleft :     European Synchrotron Radiation Facility
//                BP 220, Grenoble 38043
//                FRANCE
//
//-=============================================================================
#ifndef _DOALLTHREAD_H
#define _DOALLTHREAD_H

#include <tango.h>
#include <MBFCleaning.h>
#include <iostream>

namespace MBFCleaning_ns {
class DoAllThread : public omni_thread, public Tango::LogAdapter {

public:
    // Constructor.
    DoAllThread(MBFCleaning *, omni_mutex &);
    void run(void *);

private:
    omni_mutex &mutex;
    MBFCleaning *ds;


}; // class DoAllThread
} // namespace MBFCleaning_ns

#endif // _DOALLTHREAD_H
