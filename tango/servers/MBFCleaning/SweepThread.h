//+=============================================================================
//
// file :         SweepThread.h
//
// description :  Include for the SweepThread class.
//                This class is used for non blocking frequency sweep
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
#ifndef _SWEEPTHREAD_H
#define _SWEEPTHREAD_H

#include <tango.h>
#include <MBFCleaning.h>
#include <iostream>

namespace MBFCleaning_ns {
class SweepThread : public omni_thread, public Tango::LogAdapter {

public:
    // Constructor.
    SweepThread(MBFCleaning *, omni_mutex &);
    void run(void *);

private:
    omni_mutex &mutex;
    MBFCleaning *ds;


}; // class SweepThread
} // namespace MBFCleaning_ns

#endif // _SWEEPTHREAD_H
