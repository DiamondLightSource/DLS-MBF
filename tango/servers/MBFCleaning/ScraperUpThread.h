//+=============================================================================
//
// file :         ScraperUpThread.h
//
// description :  Include for the ScraperUpThread class.
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
#ifndef _SCRAPERUPTHREAD_H
#define _SCRAPERUPTHREAD_H

#include <tango.h>
#include <MBFCleaning.h>
#include <iostream>

namespace MBFCleaning_ns {
class ScraperUpThread : public omni_thread, public Tango::LogAdapter {

public:
    // Constructor.
    ScraperUpThread(MBFCleaning *, omni_mutex &);

    void run(void *);

private:
    omni_mutex &mutex;
    MBFCleaning *ds;


}; // class ScraperUpThread
} // namespace MBFCleaning_ns

#endif // _SCRAPERUPTHREAD_H
