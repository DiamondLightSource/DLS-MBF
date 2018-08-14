//+=============================================================================
//
// file :         ScraperDownThread.h
//
// description :  Include for the ScraperDownThread class.
//                This class is used for non blocking scraper motion
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
#ifndef _SCRAPERDOWNTHREAD_H
#define _SCRAPERDOWNTHREAD_H

#include <tango.h>
#include <MBFCleaning.h>
#include <iostream>

namespace MBFCleaning_ns {
class ScraperDownThread : public omni_thread, public Tango::LogAdapter {

public:
    // Constructor.
    ScraperDownThread(MBFCleaning *, omni_mutex &);

    void run(void *);

private:
    omni_mutex &mutex;
    MBFCleaning *ds;


}; // class ScraperDownThread
} // namespace MBFCleaning

#endif // _SCRAPERDOWNTHREAD_H
