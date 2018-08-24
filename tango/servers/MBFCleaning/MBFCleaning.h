/*----- PROTECTED REGION ID(MBFCleaning.h) ENABLED START -----*/
//=============================================================================
//
// file :        MBFCleaning.h
//
// description : Include file for the MBFCleaning class
//
// project :     MBFCleaning
//
// This file is part of Tango device class.
// 
// Tango is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Tango is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Tango.  If not, see <http://www.gnu.org/licenses/>.
// 
//
// Copyright (C): 2018
//                European Synchrotron Radiation Facility
//                BP 220, Grenoble 38043
//                France
//
//=============================================================================
//                This file is generated by POGO
//        (Program Obviously used to Generate tango Object)
//=============================================================================


#ifndef MBFCleaning_H
#define MBFCleaning_H

#include <tango.h>

#define USE_UPP5LOW5   0
#define USE_UPP25LOW25 1
#define USE_UPP22      2

#define SR_FREQ  355043.0 // SR Clock

#define RAISE_EXCEPTION(cmd) Tango::Except::throw_exception(\
(const char *)"MBFCleaning::error",\
(const char *)cmd,\
(const char *)"MBFCleaning");

/*----- PROTECTED REGION END -----*/	//	MBFCleaning.h

/**
 *  MBFCleaning class description:
 *    A class for the bunch by bunch cleaning in the SR
 */

namespace MBFCleaning_ns
{
/*----- PROTECTED REGION ID(MBFCleaning::Additional Class Declarations) ENABLED START -----*/

//	Additional Class Declarations

/*----- PROTECTED REGION END -----*/	//	MBFCleaning::Additional Class Declarations

class MBFCleaning : public TANGO_BASE_CLASS
{

/*----- PROTECTED REGION ID(MBFCleaning::Data Members) ENABLED START -----*/

//	Add your own data members
public:

		Tango::DeviceProxy *shakerDS;
		Tango::DeviceProxy *mbfDS;
		Tango::DeviceProxy *upp5Ds;
		Tango::DeviceProxy *low5Ds;
		Tango::DeviceProxy *upp25Ds;
		Tango::DeviceProxy *low25Ds;
		Tango::DeviceProxy *upp22Ds;

		double Upp5_initpos;
		double Low5_initpos;
		double Upp25_initpos;
		double Low25_initpos;
		double Upp22_initpos;

		string configFile;
		int  configurationLoadFailed;

		omni_mutex mutexsweep;

		void get_scr_open_pos(string scraperName,double *pos);
		void save_attribute_property(string attName,string propName,double value);

/*----- PROTECTED REGION END -----*/	//	MBFCleaning::Data Members

//	Device property data members
public:
	//	MBFDevice:	Name of the MBF device
	string	mBFDevice;
	//	ScrUpp25Device:	Name of the scraper Upp25
	string	scrUpp25Device;
	//	ScrLow25Device:	Name of the scraper Low25
	string	scrLow25Device;
	//	ScrUpp5Device:	Name of the scraper Upp5
	string	scrUpp5Device;
	//	ScrLow5Device:	Name of the ScrLow5 device
	string	scrLow5Device;
	//	ScrUpp22Device:	Name of the scraper Upp22
	string	scrUpp22Device;
	//	ExternalShakerDevice:	External shaker used for external sweep
	string	externalShakerDevice;
	//	ConfigFilePath:	Path where are stored configuration files
	string	configFilePath;

//	Attribute data members
public:
	Tango::DevDouble	*attr_FreqMin_read;
	Tango::DevDouble	*attr_FreqMax_read;
	Tango::DevDouble	*attr_SweepTime_read;
	Tango::DevDouble	*attr_Gain_read;
	Tango::DevString	*attr_ConfigFileName_read;
	Tango::DevShort	*attr_Scrapers_read;
	Tango::DevDouble	*attr_Upp5_read;
	Tango::DevDouble	*attr_Low5_read;
	Tango::DevDouble	*attr_Upp25_read;
	Tango::DevDouble	*attr_Low25_read;
	Tango::DevDouble	*attr_Upp22_read;
	Tango::DevBoolean	*attr_ExternalSweep_read;

//	Constructors and destructors
public:
	/**
	 * Constructs a newly device object.
	 *
	 *	@param cl	Class.
	 *	@param s 	Device Name
	 */
	MBFCleaning(Tango::DeviceClass *cl,string &s);
	/**
	 * Constructs a newly device object.
	 *
	 *	@param cl	Class.
	 *	@param s 	Device Name
	 */
	MBFCleaning(Tango::DeviceClass *cl,const char *s);
	/**
	 * Constructs a newly device object.
	 *
	 *	@param cl	Class.
	 *	@param s 	Device name
	 *	@param d	Device description.
	 */
	MBFCleaning(Tango::DeviceClass *cl,const char *s,const char *d);
	/**
	 * The device object destructor.
	 */
	~MBFCleaning() {delete_device();};


//	Miscellaneous methods
public:
	/*
	 *	will be called at device destruction or at init command.
	 */
	void delete_device();
	/*
	 *	Initialize the device
	 */
	virtual void init_device();
	/*
	 *	Read the device properties from database
	 */
	void get_device_property();
	/*
	 *	Always executed method before execution command method.
	 */
	virtual void always_executed_hook();


//	Attribute methods
public:
	//--------------------------------------------------------
	/*
	 *	Method      : MBFCleaning::read_attr_hardware()
	 *	Description : Hardware acquisition for attributes.
	 */
	//--------------------------------------------------------
	virtual void read_attr_hardware(vector<long> &attr_list);
	//--------------------------------------------------------
	/*
	 *	Method      : MBFCleaning::write_attr_hardware()
	 *	Description : Hardware writing for attributes.
	 */
	//--------------------------------------------------------
	virtual void write_attr_hardware(vector<long> &attr_list);

/**
 *	Attribute FreqMin related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_FreqMin(Tango::Attribute &attr);
	virtual void write_FreqMin(Tango::WAttribute &attr);
	virtual bool is_FreqMin_allowed(Tango::AttReqType type);
/**
 *	Attribute FreqMax related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_FreqMax(Tango::Attribute &attr);
	virtual void write_FreqMax(Tango::WAttribute &attr);
	virtual bool is_FreqMax_allowed(Tango::AttReqType type);
/**
 *	Attribute SweepTime related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_SweepTime(Tango::Attribute &attr);
	virtual void write_SweepTime(Tango::WAttribute &attr);
	virtual bool is_SweepTime_allowed(Tango::AttReqType type);
/**
 *	Attribute Gain related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_Gain(Tango::Attribute &attr);
	virtual void write_Gain(Tango::WAttribute &attr);
	virtual bool is_Gain_allowed(Tango::AttReqType type);
/**
 *	Attribute ConfigFileName related methods
 *	Description: 
 *
 *	Data type:	Tango::DevString
 *	Attr type:	Scalar
 */
	virtual void read_ConfigFileName(Tango::Attribute &attr);
	virtual bool is_ConfigFileName_allowed(Tango::AttReqType type);
/**
 *	Attribute Scrapers related methods
 *	Description: 
 *
 *	Data type:	Tango::DevShort
 *	Attr type:	Scalar
 */
	virtual void read_Scrapers(Tango::Attribute &attr);
	virtual void write_Scrapers(Tango::WAttribute &attr);
	virtual bool is_Scrapers_allowed(Tango::AttReqType type);
/**
 *	Attribute Upp5 related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_Upp5(Tango::Attribute &attr);
	virtual void write_Upp5(Tango::WAttribute &attr);
	virtual bool is_Upp5_allowed(Tango::AttReqType type);
/**
 *	Attribute Low5 related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_Low5(Tango::Attribute &attr);
	virtual void write_Low5(Tango::WAttribute &attr);
	virtual bool is_Low5_allowed(Tango::AttReqType type);
/**
 *	Attribute Upp25 related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_Upp25(Tango::Attribute &attr);
	virtual void write_Upp25(Tango::WAttribute &attr);
	virtual bool is_Upp25_allowed(Tango::AttReqType type);
/**
 *	Attribute Low25 related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_Low25(Tango::Attribute &attr);
	virtual void write_Low25(Tango::WAttribute &attr);
	virtual bool is_Low25_allowed(Tango::AttReqType type);
/**
 *	Attribute Upp22 related methods
 *	Description: 
 *
 *	Data type:	Tango::DevDouble
 *	Attr type:	Scalar
 */
	virtual void read_Upp22(Tango::Attribute &attr);
	virtual void write_Upp22(Tango::WAttribute &attr);
	virtual bool is_Upp22_allowed(Tango::AttReqType type);
/**
 *	Attribute ExternalSweep related methods
 *	Description: 
 *
 *	Data type:	Tango::DevBoolean
 *	Attr type:	Scalar
 */
	virtual void read_ExternalSweep(Tango::Attribute &attr);
	virtual void write_ExternalSweep(Tango::WAttribute &attr);
	virtual bool is_ExternalSweep_allowed(Tango::AttReqType type);


	//--------------------------------------------------------
	/**
	 *	Method      : MBFCleaning::add_dynamic_attributes()
	 *	Description : Add dynamic attributes if any.
	 */
	//--------------------------------------------------------
	void add_dynamic_attributes();




//	Command related methods
public:
	/**
	 *	Command StartCleaning related method
	 *	Description: Starts the cleaning (Move scrapper down)
	 *
	 */
	virtual void start_cleaning();
	virtual bool is_StartCleaning_allowed(const CORBA::Any &any);
	/**
	 *	Command LoadConfigurationFile related method
	 *	Description: Loads a configuration file
	 *
	 *	@param argin Configuration file name (without the path)
	 */
	virtual void load_configuration_file(Tango::DevString argin);
	virtual bool is_LoadConfigurationFile_allowed(const CORBA::Any &any);
	/**
	 *	Command SaveConfigurationFile related method
	 *	Description: 
	 *
	 *	@param argin Configuration file name (without the path)
	 */
	virtual void save_configuration_file(Tango::DevString argin);
	virtual bool is_SaveConfigurationFile_allowed(const CORBA::Any &any);
	/**
	 *	Command GetConfigurationFilePath related method
	 *	Description: Returns the absolute confiration file path
	 *
	 *	@returns Configuration file path
	 */
	virtual Tango::DevString get_configuration_file_path();
	virtual bool is_GetConfigurationFilePath_allowed(const CORBA::Any &any);
	/**
	 *	Command Sweep related method
	 *	Description: Start sweep (Sweep from freqmin to freqmax)
	 *
	 */
	virtual void sweep();
	virtual bool is_Sweep_allowed(const CORBA::Any &any);
	/**
	 *	Command EndCleaning related method
	 *	Description: End the cleaning (restore scraper positions)
	 *
	 */
	virtual void end_cleaning();
	virtual bool is_EndCleaning_allowed(const CORBA::Any &any);
	/**
	 *	Command DoAll related method
	 *	Description: Perform cleaning task (move scraper and sweep)
	 *
	 */
	virtual void do_all();
	virtual bool is_DoAll_allowed(const CORBA::Any &any);
	/**
	 *	Command Stop related method
	 *	Description: Stops the cleaning
	 *
	 */
	virtual void stop();
	virtual bool is_Stop_allowed(const CORBA::Any &any);


	//--------------------------------------------------------
	/**
	 *	Method      : MBFCleaning::add_dynamic_commands()
	 *	Description : Add dynamic commands if any.
	 */
	//--------------------------------------------------------
	void add_dynamic_commands();

/*----- PROTECTED REGION ID(MBFCleaning::Additional Method prototypes) ENABLED START -----*/

//	Additional Method prototypes

/*----- PROTECTED REGION END -----*/	//	MBFCleaning::Additional Method prototypes
};

/*----- PROTECTED REGION ID(MBFCleaning::Additional Classes Definitions) ENABLED START -----*/

//	Additional Classes Definitions

/*----- PROTECTED REGION END -----*/	//	MBFCleaning::Additional Classes Definitions

}	//	End of namespace

#endif   //	MBFCleaning_H