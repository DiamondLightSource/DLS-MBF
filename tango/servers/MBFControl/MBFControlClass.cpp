/*----- PROTECTED REGION ID(MBFControlClass.cpp) ENABLED START -----*/
//=============================================================================
//
// file :        MBFControlClass.cpp
//
// description : C++ source for the MBFControlClass.
//               A singleton class derived from DeviceClass.
//               It implements the command and attribute list
//               and all properties and methods required
//               by the MBFControl once per process.
//
// project :     MBFControl
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


#include <MBFControlClass.h>

/*----- PROTECTED REGION END -----*/	//	MBFControlClass.cpp

//-------------------------------------------------------------------
/**
 *	Create MBFControlClass singleton and
 *	return it in a C function for Python usage
 */
//-------------------------------------------------------------------
extern "C" {
#ifdef _TG_WINDOWS_

__declspec(dllexport)

#endif

	Tango::DeviceClass *_create_MBFControl_class(const char *name) {
		return MBFControl_ns::MBFControlClass::init(name);
	}
}

namespace MBFControl_ns
{
//===================================================================
//	Initialize pointer for singleton pattern
//===================================================================
MBFControlClass *MBFControlClass::_instance = NULL;

//--------------------------------------------------------
/**
 * method : 		MBFControlClass::MBFControlClass(string &s)
 * description : 	constructor for the MBFControlClass
 *
 * @param s	The class name
 */
//--------------------------------------------------------
MBFControlClass::MBFControlClass(string &s):Tango::DeviceClass(s)
{
	cout2 << "Entering MBFControlClass constructor" << endl;
	set_default_property();
	write_class_property();

	/*----- PROTECTED REGION ID(MBFControlClass::constructor) ENABLED START -----*/
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::constructor

	cout2 << "Leaving MBFControlClass constructor" << endl;
}

//--------------------------------------------------------
/**
 * method : 		MBFControlClass::~MBFControlClass()
 * description : 	destructor for the MBFControlClass
 */
//--------------------------------------------------------
MBFControlClass::~MBFControlClass()
{
	/*----- PROTECTED REGION ID(MBFControlClass::destructor) ENABLED START -----*/
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::destructor

	_instance = NULL;
}


//--------------------------------------------------------
/**
 * method : 		MBFControlClass::init
 * description : 	Create the object if not already done.
 *                  Otherwise, just return a pointer to the object
 *
 * @param	name	The class name
 */
//--------------------------------------------------------
MBFControlClass *MBFControlClass::init(const char *name)
{
	if (_instance == NULL)
	{
		try
		{
			string s(name);
			_instance = new MBFControlClass(s);
		}
		catch (bad_alloc &)
		{
			throw;
		}
	}
	return _instance;
}

//--------------------------------------------------------
/**
 * method : 		MBFControlClass::instance
 * description : 	Check if object already created,
 *                  and return a pointer to the object
 */
//--------------------------------------------------------
MBFControlClass *MBFControlClass::instance()
{
	if (_instance == NULL)
	{
		cerr << "Class is not initialised !!" << endl;
		exit(-1);
	}
	return _instance;
}



//===================================================================
//	Command execution method calls
//===================================================================
//--------------------------------------------------------
/**
 * method : 		LoadConfigurationFileClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *LoadConfigurationFileClass::execute(Tango::DeviceImpl *device, const CORBA::Any &in_any)
{
	cout2 << "LoadConfigurationFileClass::execute(): arrived" << endl;
	Tango::DevString argin;
	extract(in_any, argin);
	((static_cast<MBFControl *>(device))->load_configuration_file(argin));
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		SaveConfigurationFileClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *SaveConfigurationFileClass::execute(Tango::DeviceImpl *device, const CORBA::Any &in_any)
{
	cout2 << "SaveConfigurationFileClass::execute(): arrived" << endl;
	Tango::DevString argin;
	extract(in_any, argin);
	((static_cast<MBFControl *>(device))->save_configuration_file(argin));
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		GetConfigurationFilePathClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *GetConfigurationFilePathClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "GetConfigurationFilePathClass::execute(): arrived" << endl;
	return insert((static_cast<MBFControl *>(device))->get_configuration_file_path());
}

//--------------------------------------------------------
/**
 * method : 		OnClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *OnClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "OnClass::execute(): arrived" << endl;
	((static_cast<MBFControl *>(device))->on());
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		OffClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *OffClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "OffClass::execute(): arrived" << endl;
	((static_cast<MBFControl *>(device))->off());
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		SweepOnClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *SweepOnClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "SweepOnClass::execute(): arrived" << endl;
	((static_cast<MBFControl *>(device))->sweep_on());
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		SweepOffClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *SweepOffClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "SweepOffClass::execute(): arrived" << endl;
	((static_cast<MBFControl *>(device))->sweep_off());
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		CleanClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *CleanClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "CleanClass::execute(): arrived" << endl;
	((static_cast<MBFControl *>(device))->clean());
	return new CORBA::Any();
}

//--------------------------------------------------------
/**
 * method : 		ResetClass::execute()
 * description : 	method to trigger the execution of the command.
 *
 * @param	device	The device on which the command must be executed
 * @param	in_any	The command input data
 *
 *	returns The command output data (packed in the Any object)
 */
//--------------------------------------------------------
CORBA::Any *ResetClass::execute(Tango::DeviceImpl *device, TANGO_UNUSED(const CORBA::Any &in_any))
{
	cout2 << "ResetClass::execute(): arrived" << endl;
	((static_cast<MBFControl *>(device))->reset());
	return new CORBA::Any();
}


//===================================================================
//	Properties management
//===================================================================
//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::get_class_property()
 *	Description : Get the class property for specified name.
 */
//--------------------------------------------------------
Tango::DbDatum MBFControlClass::get_class_property(string &prop_name)
{
	for (unsigned int i=0 ; i<cl_prop.size() ; i++)
		if (cl_prop[i].name == prop_name)
			return cl_prop[i];
	//	if not found, returns  an empty DbDatum
	return Tango::DbDatum(prop_name);
}

//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::get_default_device_property()
 *	Description : Return the default value for device property.
 */
//--------------------------------------------------------
Tango::DbDatum MBFControlClass::get_default_device_property(string &prop_name)
{
	for (unsigned int i=0 ; i<dev_def_prop.size() ; i++)
		if (dev_def_prop[i].name == prop_name)
			return dev_def_prop[i];
	//	if not found, return  an empty DbDatum
	return Tango::DbDatum(prop_name);
}

//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::get_default_class_property()
 *	Description : Return the default value for class property.
 */
//--------------------------------------------------------
Tango::DbDatum MBFControlClass::get_default_class_property(string &prop_name)
{
	for (unsigned int i=0 ; i<cl_def_prop.size() ; i++)
		if (cl_def_prop[i].name == prop_name)
			return cl_def_prop[i];
	//	if not found, return  an empty DbDatum
	return Tango::DbDatum(prop_name);
}


//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::set_default_property()
 *	Description : Set default property (class and device) for wizard.
 *                For each property, add to wizard property name and description.
 *                If default value has been set, add it to wizard property and
 *                store it in a DbDatum.
 */
//--------------------------------------------------------
void MBFControlClass::set_default_property()
{
	string	prop_name;
	string	prop_desc;
	string	prop_def;
	vector<string>	vect_data;

	//	Set Default Class Properties

	//	Set Default device Properties
	prop_name = "ConfigFilePath";
	prop_desc = "This is `root` file base path. This string will be concatenated with parameter\nof loadConfigFile command, to obtain an absolute filename.";
	prop_def  = "";
	vect_data.clear();
	if (prop_def.length()>0)
	{
		Tango::DbDatum	data(prop_name);
		data << vect_data ;
		dev_def_prop.push_back(data);
		add_wiz_dev_prop(prop_name, prop_desc,  prop_def);
	}
	else
		add_wiz_dev_prop(prop_name, prop_desc);
	prop_name = "MBFDevice";
	prop_desc = "Device name of the MultiBunch Feedback";
	prop_def  = "";
	vect_data.clear();
	if (prop_def.length()>0)
	{
		Tango::DbDatum	data(prop_name);
		data << vect_data ;
		dev_def_prop.push_back(data);
		add_wiz_dev_prop(prop_name, prop_desc,  prop_def);
	}
	else
		add_wiz_dev_prop(prop_name, prop_desc);
	prop_name = "DoorDevice";
	prop_desc = "Name of the door device";
	prop_def  = "";
	vect_data.clear();
	if (prop_def.length()>0)
	{
		Tango::DbDatum	data(prop_name);
		data << vect_data ;
		dev_def_prop.push_back(data);
		add_wiz_dev_prop(prop_name, prop_desc,  prop_def);
	}
	else
		add_wiz_dev_prop(prop_name, prop_desc);
	prop_name = "ModeList";
	prop_desc = "List of machine mode";
	prop_def  = "";
	vect_data.clear();
	if (prop_def.length()>0)
	{
		Tango::DbDatum	data(prop_name);
		data << vect_data ;
		dev_def_prop.push_back(data);
		add_wiz_dev_prop(prop_name, prop_desc,  prop_def);
	}
	else
		add_wiz_dev_prop(prop_name, prop_desc);
	prop_name = "GMBFDevice";
	prop_desc = "Name of the global MBF device";
	prop_def  = "";
	vect_data.clear();
	if (prop_def.length()>0)
	{
		Tango::DbDatum	data(prop_name);
		data << vect_data ;
		dev_def_prop.push_back(data);
		add_wiz_dev_prop(prop_name, prop_desc,  prop_def);
	}
	else
		add_wiz_dev_prop(prop_name, prop_desc);
}

//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::write_class_property()
 *	Description : Set class description fields as property in database
 */
//--------------------------------------------------------
void MBFControlClass::write_class_property()
{
	//	First time, check if database used
	if (Tango::Util::_UseDb == false)
		return;

	Tango::DbData	data;
	string	classname = get_name();
	string	header;
	string::size_type	start, end;

	//	Put title
	Tango::DbDatum	title("ProjectTitle");
	string	str_title("MBFControl");
	title << str_title;
	data.push_back(title);

	//	Put Description
	Tango::DbDatum	description("Description");
	vector<string>	str_desc;
	str_desc.push_back("A high level class to control MBF startup, configuration sequence and configuration file");
	description << str_desc;
	data.push_back(description);

	//  Put inheritance
	Tango::DbDatum	inher_datum("InheritedFrom");
	vector<string> inheritance;
	inheritance.push_back("TANGO_BASE_CLASS");
	inher_datum << inheritance;
	data.push_back(inher_datum);

	//	Call database and and values
	get_db_class()->put_property(data);
}

//===================================================================
//	Factory methods
//===================================================================

//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::device_factory()
 *	Description : Create the device object(s)
 *                and store them in the device list
 */
//--------------------------------------------------------
void MBFControlClass::device_factory(const Tango::DevVarStringArray *devlist_ptr)
{
	/*----- PROTECTED REGION ID(MBFControlClass::device_factory_before) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::device_factory_before

	//	Create devices and add it into the device list
	for (unsigned long i=0 ; i<devlist_ptr->length() ; i++)
	{
		cout4 << "Device name : " << (*devlist_ptr)[i].in() << endl;
		device_list.push_back(new MBFControl(this, (*devlist_ptr)[i]));
	}

	//	Manage dynamic attributes if any
	erase_dynamic_attributes(devlist_ptr, get_class_attr()->get_attr_list());

	//	Export devices to the outside world
	for (unsigned long i=1 ; i<=devlist_ptr->length() ; i++)
	{
		//	Add dynamic attributes if any
		MBFControl *dev = static_cast<MBFControl *>(device_list[device_list.size()-i]);
		dev->add_dynamic_attributes();

		//	Check before if database used.
		if ((Tango::Util::_UseDb == true) && (Tango::Util::_FileDb == false))
			export_device(dev);
		else
			export_device(dev, dev->get_name().c_str());
	}

	/*----- PROTECTED REGION ID(MBFControlClass::device_factory_after) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::device_factory_after
}
//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::attribute_factory()
 *	Description : Create the attribute object(s)
 *                and store them in the attribute list
 */
//--------------------------------------------------------
void MBFControlClass::attribute_factory(vector<Tango::Attr *> &att_list)
{
	/*----- PROTECTED REGION ID(MBFControlClass::attribute_factory_before) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::attribute_factory_before
	//	Attribute : Mode
	ModeAttrib	*mode = new ModeAttrib();
	Tango::UserDefaultAttrProp	mode_prop;
	//	description	not set for Mode
	//	label	not set for Mode
	//	unit	not set for Mode
	//	standard_unit	not set for Mode
	//	display_unit	not set for Mode
	//	format	not set for Mode
	//	max_value	not set for Mode
	//	min_value	not set for Mode
	//	max_alarm	not set for Mode
	//	min_alarm	not set for Mode
	//	max_warning	not set for Mode
	//	min_warning	not set for Mode
	//	delta_t	not set for Mode
	//	delta_val	not set for Mode
	
	mode->set_default_properties(mode_prop);
	//	Not Polled
	mode->set_disp_level(Tango::OPERATOR);
	mode->set_memorized();
	mode->set_memorized_init(true);
	att_list.push_back(mode);

	//	Attribute : ConfigFileName
	ConfigFileNameAttrib	*configfilename = new ConfigFileNameAttrib();
	Tango::UserDefaultAttrProp	configfilename_prop;
	//	description	not set for ConfigFileName
	//	label	not set for ConfigFileName
	//	unit	not set for ConfigFileName
	//	standard_unit	not set for ConfigFileName
	//	display_unit	not set for ConfigFileName
	//	format	not set for ConfigFileName
	//	max_value	not set for ConfigFileName
	//	min_value	not set for ConfigFileName
	//	max_alarm	not set for ConfigFileName
	//	min_alarm	not set for ConfigFileName
	//	max_warning	not set for ConfigFileName
	//	min_warning	not set for ConfigFileName
	//	delta_t	not set for ConfigFileName
	//	delta_val	not set for ConfigFileName
	
	configfilename->set_default_properties(configfilename_prop);
	//	Not Polled
	configfilename->set_disp_level(Tango::OPERATOR);
	//	Not Memorized
	att_list.push_back(configfilename);

	//	Attribute : Tune
	TuneAttrib	*tune = new TuneAttrib();
	Tango::UserDefaultAttrProp	tune_prop;
	//	description	not set for Tune
	//	label	not set for Tune
	//	unit	not set for Tune
	//	standard_unit	not set for Tune
	//	display_unit	not set for Tune
	//	format	not set for Tune
	//	max_value	not set for Tune
	//	min_value	not set for Tune
	//	max_alarm	not set for Tune
	//	min_alarm	not set for Tune
	//	max_warning	not set for Tune
	//	min_warning	not set for Tune
	//	delta_t	not set for Tune
	//	delta_val	not set for Tune
	
	tune->set_default_properties(tune_prop);
	//	Not Polled
	tune->set_disp_level(Tango::OPERATOR);
	tune->set_memorized();
	tune->set_memorized_init(true);
	att_list.push_back(tune);

	//	Attribute : FeedbackGain
	FeedbackGainAttrib	*feedbackgain = new FeedbackGainAttrib();
	Tango::UserDefaultAttrProp	feedbackgain_prop;
	//	description	not set for FeedbackGain
	//	label	not set for FeedbackGain
	//	unit	not set for FeedbackGain
	//	standard_unit	not set for FeedbackGain
	//	display_unit	not set for FeedbackGain
	//	format	not set for FeedbackGain
	//	max_value	not set for FeedbackGain
	//	min_value	not set for FeedbackGain
	//	max_alarm	not set for FeedbackGain
	//	min_alarm	not set for FeedbackGain
	//	max_warning	not set for FeedbackGain
	//	min_warning	not set for FeedbackGain
	//	delta_t	not set for FeedbackGain
	//	delta_val	not set for FeedbackGain
	
	feedbackgain->set_default_properties(feedbackgain_prop);
	//	Not Polled
	feedbackgain->set_disp_level(Tango::OPERATOR);
	feedbackgain->set_memorized();
	feedbackgain->set_memorized_init(true);
	att_list.push_back(feedbackgain);

	//	Attribute : FeedbackFineGain
	FeedbackFineGainAttrib	*feedbackfinegain = new FeedbackFineGainAttrib();
	Tango::UserDefaultAttrProp	feedbackfinegain_prop;
	//	description	not set for FeedbackFineGain
	//	label	not set for FeedbackFineGain
	//	unit	not set for FeedbackFineGain
	//	standard_unit	not set for FeedbackFineGain
	//	display_unit	not set for FeedbackFineGain
	//	format	not set for FeedbackFineGain
	//	max_value	not set for FeedbackFineGain
	//	min_value	not set for FeedbackFineGain
	//	max_alarm	not set for FeedbackFineGain
	//	min_alarm	not set for FeedbackFineGain
	//	max_warning	not set for FeedbackFineGain
	//	min_warning	not set for FeedbackFineGain
	//	delta_t	not set for FeedbackFineGain
	//	delta_val	not set for FeedbackFineGain
	
	feedbackfinegain->set_default_properties(feedbackfinegain_prop);
	//	Not Polled
	feedbackfinegain->set_disp_level(Tango::OPERATOR);
	feedbackfinegain->set_memorized();
	feedbackfinegain->set_memorized_init(true);
	att_list.push_back(feedbackfinegain);

	//	Attribute : FeedbackPhase
	FeedbackPhaseAttrib	*feedbackphase = new FeedbackPhaseAttrib();
	Tango::UserDefaultAttrProp	feedbackphase_prop;
	//	description	not set for FeedbackPhase
	//	label	not set for FeedbackPhase
	//	unit	not set for FeedbackPhase
	//	standard_unit	not set for FeedbackPhase
	//	display_unit	not set for FeedbackPhase
	//	format	not set for FeedbackPhase
	//	max_value	not set for FeedbackPhase
	//	min_value	not set for FeedbackPhase
	//	max_alarm	not set for FeedbackPhase
	//	min_alarm	not set for FeedbackPhase
	//	max_warning	not set for FeedbackPhase
	//	min_warning	not set for FeedbackPhase
	//	delta_t	not set for FeedbackPhase
	//	delta_val	not set for FeedbackPhase
	
	feedbackphase->set_default_properties(feedbackphase_prop);
	//	Not Polled
	feedbackphase->set_disp_level(Tango::OPERATOR);
	feedbackphase->set_memorized();
	feedbackphase->set_memorized_init(true);
	att_list.push_back(feedbackphase);

	//	Attribute : Harmonic
	HarmonicAttrib	*harmonic = new HarmonicAttrib();
	Tango::UserDefaultAttrProp	harmonic_prop;
	//	description	not set for Harmonic
	//	label	not set for Harmonic
	//	unit	not set for Harmonic
	//	standard_unit	not set for Harmonic
	//	display_unit	not set for Harmonic
	//	format	not set for Harmonic
	//	max_value	not set for Harmonic
	//	min_value	not set for Harmonic
	//	max_alarm	not set for Harmonic
	//	min_alarm	not set for Harmonic
	//	max_warning	not set for Harmonic
	//	min_warning	not set for Harmonic
	//	delta_t	not set for Harmonic
	//	delta_val	not set for Harmonic
	
	harmonic->set_default_properties(harmonic_prop);
	//	Not Polled
	harmonic->set_disp_level(Tango::OPERATOR);
	harmonic->set_memorized();
	harmonic->set_memorized_init(true);
	att_list.push_back(harmonic);

	//	Attribute : SweepRange
	SweepRangeAttrib	*sweeprange = new SweepRangeAttrib();
	Tango::UserDefaultAttrProp	sweeprange_prop;
	//	description	not set for SweepRange
	//	label	not set for SweepRange
	//	unit	not set for SweepRange
	//	standard_unit	not set for SweepRange
	//	display_unit	not set for SweepRange
	//	format	not set for SweepRange
	//	max_value	not set for SweepRange
	//	min_value	not set for SweepRange
	//	max_alarm	not set for SweepRange
	//	min_alarm	not set for SweepRange
	//	max_warning	not set for SweepRange
	//	min_warning	not set for SweepRange
	//	delta_t	not set for SweepRange
	//	delta_val	not set for SweepRange
	
	sweeprange->set_default_properties(sweeprange_prop);
	//	Not Polled
	sweeprange->set_disp_level(Tango::OPERATOR);
	sweeprange->set_memorized();
	sweeprange->set_memorized_init(true);
	att_list.push_back(sweeprange);

	//	Attribute : SweepDwellTime
	SweepDwellTimeAttrib	*sweepdwelltime = new SweepDwellTimeAttrib();
	Tango::UserDefaultAttrProp	sweepdwelltime_prop;
	//	description	not set for SweepDwellTime
	//	label	not set for SweepDwellTime
	//	unit	not set for SweepDwellTime
	//	standard_unit	not set for SweepDwellTime
	//	display_unit	not set for SweepDwellTime
	//	format	not set for SweepDwellTime
	//	max_value	not set for SweepDwellTime
	//	min_value	not set for SweepDwellTime
	//	max_alarm	not set for SweepDwellTime
	//	min_alarm	not set for SweepDwellTime
	//	max_warning	not set for SweepDwellTime
	//	min_warning	not set for SweepDwellTime
	//	delta_t	not set for SweepDwellTime
	//	delta_val	not set for SweepDwellTime
	
	sweepdwelltime->set_default_properties(sweepdwelltime_prop);
	//	Not Polled
	sweepdwelltime->set_disp_level(Tango::OPERATOR);
	sweepdwelltime->set_memorized();
	sweepdwelltime->set_memorized_init(true);
	att_list.push_back(sweepdwelltime);

	//	Attribute : SweepGain
	SweepGainAttrib	*sweepgain = new SweepGainAttrib();
	Tango::UserDefaultAttrProp	sweepgain_prop;
	//	description	not set for SweepGain
	//	label	not set for SweepGain
	//	unit	not set for SweepGain
	//	standard_unit	not set for SweepGain
	//	display_unit	not set for SweepGain
	//	format	not set for SweepGain
	//	max_value	not set for SweepGain
	//	min_value	not set for SweepGain
	//	max_alarm	not set for SweepGain
	//	min_alarm	not set for SweepGain
	//	max_warning	not set for SweepGain
	//	min_warning	not set for SweepGain
	//	delta_t	not set for SweepGain
	//	delta_val	not set for SweepGain
	
	sweepgain->set_default_properties(sweepgain_prop);
	//	Not Polled
	sweepgain->set_disp_level(Tango::OPERATOR);
	sweepgain->set_memorized();
	sweepgain->set_memorized_init(true);
	att_list.push_back(sweepgain);

	//	Attribute : BlankingInterval
	BlankingIntervalAttrib	*blankinginterval = new BlankingIntervalAttrib();
	Tango::UserDefaultAttrProp	blankinginterval_prop;
	//	description	not set for BlankingInterval
	//	label	not set for BlankingInterval
	//	unit	not set for BlankingInterval
	//	standard_unit	not set for BlankingInterval
	//	display_unit	not set for BlankingInterval
	//	format	not set for BlankingInterval
	//	max_value	not set for BlankingInterval
	//	min_value	not set for BlankingInterval
	//	max_alarm	not set for BlankingInterval
	//	min_alarm	not set for BlankingInterval
	//	max_warning	not set for BlankingInterval
	//	min_warning	not set for BlankingInterval
	//	delta_t	not set for BlankingInterval
	//	delta_val	not set for BlankingInterval
	
	blankinginterval->set_default_properties(blankinginterval_prop);
	//	Not Polled
	blankinginterval->set_disp_level(Tango::OPERATOR);
	//	Not Memorized
	att_list.push_back(blankinginterval);

	//	Attribute : TuneOnSingleBunch
	TuneOnSingleBunchAttrib	*tuneonsinglebunch = new TuneOnSingleBunchAttrib();
	Tango::UserDefaultAttrProp	tuneonsinglebunch_prop;
	//	description	not set for TuneOnSingleBunch
	//	label	not set for TuneOnSingleBunch
	//	unit	not set for TuneOnSingleBunch
	//	standard_unit	not set for TuneOnSingleBunch
	//	display_unit	not set for TuneOnSingleBunch
	//	format	not set for TuneOnSingleBunch
	//	max_value	not set for TuneOnSingleBunch
	//	min_value	not set for TuneOnSingleBunch
	//	max_alarm	not set for TuneOnSingleBunch
	//	min_alarm	not set for TuneOnSingleBunch
	//	max_warning	not set for TuneOnSingleBunch
	//	min_warning	not set for TuneOnSingleBunch
	//	delta_t	not set for TuneOnSingleBunch
	//	delta_val	not set for TuneOnSingleBunch
	
	tuneonsinglebunch->set_default_properties(tuneonsinglebunch_prop);
	//	Not Polled
	tuneonsinglebunch->set_disp_level(Tango::OPERATOR);
	tuneonsinglebunch->set_memorized();
	tuneonsinglebunch->set_memorized_init(true);
	att_list.push_back(tuneonsinglebunch);

	//	Attribute : TuneBunch
	TuneBunchAttrib	*tunebunch = new TuneBunchAttrib();
	Tango::UserDefaultAttrProp	tunebunch_prop;
	//	description	not set for TuneBunch
	//	label	not set for TuneBunch
	//	unit	not set for TuneBunch
	//	standard_unit	not set for TuneBunch
	//	display_unit	not set for TuneBunch
	//	format	not set for TuneBunch
	//	max_value	not set for TuneBunch
	//	min_value	not set for TuneBunch
	//	max_alarm	not set for TuneBunch
	//	min_alarm	not set for TuneBunch
	//	max_warning	not set for TuneBunch
	//	min_warning	not set for TuneBunch
	//	delta_t	not set for TuneBunch
	//	delta_val	not set for TuneBunch
	
	tunebunch->set_default_properties(tunebunch_prop);
	//	Not Polled
	tunebunch->set_disp_level(Tango::OPERATOR);
	tunebunch->set_memorized();
	tunebunch->set_memorized_init(true);
	att_list.push_back(tunebunch);

	//	Attribute : SweepState
	SweepStateAttrib	*sweepstate = new SweepStateAttrib();
	Tango::UserDefaultAttrProp	sweepstate_prop;
	//	description	not set for SweepState
	//	label	not set for SweepState
	//	unit	not set for SweepState
	//	standard_unit	not set for SweepState
	//	display_unit	not set for SweepState
	//	format	not set for SweepState
	//	max_value	not set for SweepState
	//	min_value	not set for SweepState
	//	max_alarm	not set for SweepState
	//	min_alarm	not set for SweepState
	//	max_warning	not set for SweepState
	//	min_warning	not set for SweepState
	//	delta_t	not set for SweepState
	//	delta_val	not set for SweepState
	
	sweepstate->set_default_properties(sweepstate_prop);
	//	Not Polled
	sweepstate->set_disp_level(Tango::OPERATOR);
	//	Not Memorized
	att_list.push_back(sweepstate);

	//	Attribute : MacroHistory
	MacroHistoryAttrib	*macrohistory = new MacroHistoryAttrib();
	Tango::UserDefaultAttrProp	macrohistory_prop;
	//	description	not set for MacroHistory
	//	label	not set for MacroHistory
	//	unit	not set for MacroHistory
	//	standard_unit	not set for MacroHistory
	//	display_unit	not set for MacroHistory
	//	format	not set for MacroHistory
	//	max_value	not set for MacroHistory
	//	min_value	not set for MacroHistory
	//	max_alarm	not set for MacroHistory
	//	min_alarm	not set for MacroHistory
	//	max_warning	not set for MacroHistory
	//	min_warning	not set for MacroHistory
	//	delta_t	not set for MacroHistory
	//	delta_val	not set for MacroHistory
	
	macrohistory->set_default_properties(macrohistory_prop);
	//	Not Polled
	macrohistory->set_disp_level(Tango::OPERATOR);
	//	Not Memorized
	att_list.push_back(macrohistory);

	//	Attribute : ModeList
	ModeListAttrib	*modelist = new ModeListAttrib();
	Tango::UserDefaultAttrProp	modelist_prop;
	//	description	not set for ModeList
	//	label	not set for ModeList
	//	unit	not set for ModeList
	//	standard_unit	not set for ModeList
	//	display_unit	not set for ModeList
	//	format	not set for ModeList
	//	max_value	not set for ModeList
	//	min_value	not set for ModeList
	//	max_alarm	not set for ModeList
	//	min_alarm	not set for ModeList
	//	max_warning	not set for ModeList
	//	min_warning	not set for ModeList
	//	delta_t	not set for ModeList
	//	delta_val	not set for ModeList
	
	modelist->set_default_properties(modelist_prop);
	//	Not Polled
	modelist->set_disp_level(Tango::OPERATOR);
	//	Not Memorized
	att_list.push_back(modelist);


	//	Create a list of static attributes
	create_static_attribute_list(get_class_attr()->get_attr_list());
	/*----- PROTECTED REGION ID(MBFControlClass::attribute_factory_after) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::attribute_factory_after
}
//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::pipe_factory()
 *	Description : Create the pipe object(s)
 *                and store them in the pipe list
 */
//--------------------------------------------------------
void MBFControlClass::pipe_factory()
{
	/*----- PROTECTED REGION ID(MBFControlClass::pipe_factory_before) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::pipe_factory_before
	/*----- PROTECTED REGION ID(MBFControlClass::pipe_factory_after) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::pipe_factory_after
}
//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::command_factory()
 *	Description : Create the command object(s)
 *                and store them in the command list
 */
//--------------------------------------------------------
void MBFControlClass::command_factory()
{
	/*----- PROTECTED REGION ID(MBFControlClass::command_factory_before) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::command_factory_before

	//	Set polling perod for command State
	Tango::Command	&stateCmd = get_cmd_by_name("State");
	stateCmd.set_polling_period(1000);
	

	//	Command LoadConfigurationFile
	LoadConfigurationFileClass	*pLoadConfigurationFileCmd =
		new LoadConfigurationFileClass("LoadConfigurationFile",
			Tango::DEV_STRING, Tango::DEV_VOID,
			"Configuration file name (without the path)",
			"",
			Tango::OPERATOR);
	command_list.push_back(pLoadConfigurationFileCmd);

	//	Command SaveConfigurationFile
	SaveConfigurationFileClass	*pSaveConfigurationFileCmd =
		new SaveConfigurationFileClass("SaveConfigurationFile",
			Tango::DEV_STRING, Tango::DEV_VOID,
			"Configuration file name (without the path)",
			"",
			Tango::OPERATOR);
	command_list.push_back(pSaveConfigurationFileCmd);

	//	Command GetConfigurationFilePath
	GetConfigurationFilePathClass	*pGetConfigurationFilePathCmd =
		new GetConfigurationFilePathClass("GetConfigurationFilePath",
			Tango::DEV_VOID, Tango::DEV_STRING,
			"",
			"Configuration file path",
			Tango::OPERATOR);
	command_list.push_back(pGetConfigurationFilePathCmd);

	//	Command On
	OnClass	*pOnCmd =
		new OnClass("On",
			Tango::DEV_VOID, Tango::DEV_VOID,
			"",
			"",
			Tango::OPERATOR);
	command_list.push_back(pOnCmd);

	//	Command Off
	OffClass	*pOffCmd =
		new OffClass("Off",
			Tango::DEV_VOID, Tango::DEV_VOID,
			"",
			"",
			Tango::OPERATOR);
	command_list.push_back(pOffCmd);

	//	Command SweepOn
	SweepOnClass	*pSweepOnCmd =
		new SweepOnClass("SweepOn",
			Tango::DEV_VOID, Tango::DEV_VOID,
			"",
			"",
			Tango::OPERATOR);
	command_list.push_back(pSweepOnCmd);

	//	Command SweepOff
	SweepOffClass	*pSweepOffCmd =
		new SweepOffClass("SweepOff",
			Tango::DEV_VOID, Tango::DEV_VOID,
			"",
			"",
			Tango::OPERATOR);
	command_list.push_back(pSweepOffCmd);

	//	Command Clean
	CleanClass	*pCleanCmd =
		new CleanClass("Clean",
			Tango::DEV_VOID, Tango::DEV_VOID,
			"",
			"",
			Tango::OPERATOR);
	command_list.push_back(pCleanCmd);

	//	Command Reset
	ResetClass	*pResetCmd =
		new ResetClass("Reset",
			Tango::DEV_VOID, Tango::DEV_VOID,
			"",
			"",
			Tango::OPERATOR);
	command_list.push_back(pResetCmd);

	/*----- PROTECTED REGION ID(MBFControlClass::command_factory_after) ENABLED START -----*/
	
	//	Add your own code
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::command_factory_after
}

//===================================================================
//	Dynamic attributes related methods
//===================================================================

//--------------------------------------------------------
/**
 * method : 		MBFControlClass::create_static_attribute_list
 * description : 	Create the a list of static attributes
 *
 * @param	att_list	the ceated attribute list
 */
//--------------------------------------------------------
void MBFControlClass::create_static_attribute_list(vector<Tango::Attr *> &att_list)
{
	for (unsigned long i=0 ; i<att_list.size() ; i++)
	{
		string att_name(att_list[i]->get_name());
		transform(att_name.begin(), att_name.end(), att_name.begin(), ::tolower);
		defaultAttList.push_back(att_name);
	}

	cout2 << defaultAttList.size() << " attributes in default list" << endl;

	/*----- PROTECTED REGION ID(MBFControlClass::create_static_att_list) ENABLED START -----*/
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::create_static_att_list
}


//--------------------------------------------------------
/**
 * method : 		MBFControlClass::erase_dynamic_attributes
 * description : 	delete the dynamic attributes if any.
 *
 * @param	devlist_ptr	the device list pointer
 * @param	list of all attributes
 */
//--------------------------------------------------------
void MBFControlClass::erase_dynamic_attributes(const Tango::DevVarStringArray *devlist_ptr, vector<Tango::Attr *> &att_list)
{
	Tango::Util *tg = Tango::Util::instance();

	for (unsigned long i=0 ; i<devlist_ptr->length() ; i++)
	{
		Tango::DeviceImpl *dev_impl = tg->get_device_by_name(((string)(*devlist_ptr)[i]).c_str());
		MBFControl *dev = static_cast<MBFControl *> (dev_impl);

		vector<Tango::Attribute *> &dev_att_list = dev->get_device_attr()->get_attribute_list();
		vector<Tango::Attribute *>::iterator ite_att;
		for (ite_att=dev_att_list.begin() ; ite_att != dev_att_list.end() ; ++ite_att)
		{
			string att_name((*ite_att)->get_name_lower());
			if ((att_name == "state") || (att_name == "status"))
				continue;
			vector<string>::iterator ite_str = find(defaultAttList.begin(), defaultAttList.end(), att_name);
			if (ite_str == defaultAttList.end())
			{
				cout2 << att_name << " is a UNWANTED dynamic attribute for device " << (*devlist_ptr)[i] << endl;
				Tango::Attribute &att = dev->get_device_attr()->get_attr_by_name(att_name.c_str());
				dev->remove_attribute(att_list[att.get_attr_idx()], true, false);
				--ite_att;
			}
		}
	}
	/*----- PROTECTED REGION ID(MBFControlClass::erase_dynamic_attributes) ENABLED START -----*/
	
	/*----- PROTECTED REGION END -----*/	//	MBFControlClass::erase_dynamic_attributes
}

//--------------------------------------------------------
/**
 *	Method      : MBFControlClass::get_attr_object_by_name()
 *	Description : returns Tango::Attr * object found by name
 */
//--------------------------------------------------------
Tango::Attr *MBFControlClass::get_attr_object_by_name(vector<Tango::Attr *> &att_list, string attname)
{
	vector<Tango::Attr *>::iterator it;
	for (it=att_list.begin() ; it<att_list.end() ; ++it)
		if ((*it)->get_name()==attname)
			return (*it);
	//	Attr does not exist
	return NULL;
}


/*----- PROTECTED REGION ID(MBFControlClass::Additional Methods) ENABLED START -----*/

/*----- PROTECTED REGION END -----*/	//	MBFControlClass::Additional Methods
} //	namespace