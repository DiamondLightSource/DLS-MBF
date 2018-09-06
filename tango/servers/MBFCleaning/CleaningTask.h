//+=============================================================================
//
// file :         CleaningTask.h
//
// description :  Include for the CleaningTask class.
//
// project :      TANGO Device Server 
//
// $Author: pons
//
// $Revision: 1.2 $
//
// copyleft :     European Synchrotron Radiation Facility
//                BP 220, Grenoble 38043
//                FRANCE
//
//-=============================================================================
#ifndef _CLEANINGTASK_H
#define _CLEANINGTASK_H

#include <tango.h>
#include <MBFCleaning.h>
#include <iostream>

namespace MBFCleaning_ns {
class CleaningTask {

public:
    // Constructor.
    CleaningTask(MBFCleaning *, omni_mutex &);

    void scrapper_up(bool updateState);
    void scrapper_down(bool updateState);
    void sweep(bool updateState);

private:
    omni_mutex &mutex;
    MBFCleaning *ds;

}; // class CleaningTask
} // namespace MultiBunchCleaninig

#endif // _CLEANINGTASK_H
