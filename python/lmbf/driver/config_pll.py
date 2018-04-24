# Helper file for PLL configuration

import copy


# This rather convoluted code is concerned with providing a bridge between the
# nearly 300 field and register definitions for this device so that at the end
# of this file we can simply concentrate on assigning values to named fields.
#   There are two FieldWriter subclasses: the Output class used for defining
# each of the 7 pairs of clock outputs, and the SettingsBase class used for all
# the remaining settings.
#   Each subclass must define a _Fields attribute.  This contains all the field
# definitions as either single or multiple sub-fields, see the definitions of
# OutputFields and AllFields below.
class FieldWriter(object):
    _OutputNames = []

    # A field definition is either a single field definition:
    #   (register, width, offset, default)
    # or a list of sub-fields:
    #   [(r1, w1, o1, d1), ..., (rn, wn, on, dn)]
    # We normalise this, extracting the default as a single integer value and
    # returning a list of sub-fields in reverse order:
    #   default, [(rn, wn, on), ..., (r1, w1, o1)]
    def __compute_fields(self, field_def):
        # Convert field_def into working format: a field value followed by a
        # list of register sub-fields in byte order.  At this point we need to
        # separate single byte and multiple byte definitions.
        if isinstance(field_def[0], int):
            # Simple case: single field
            default = field_def[3]
            fields = (field_def[0:3],)
        else:
            # More complicated.
            # First assemble the default value
            default = field_def[0][3]
            for _, width, _, value in field_def[1:]:
                default = (default << width) | value

            # Next extract the list of field definitions in little endian order
            # for register generation.
            fields = tuple(reversed([field[0:3] for field in field_def]))
        return default, fields


    def __init__(self, PLL = None, base = 0, **kargs):
        self.__PLL = PLL
        self.__base = base
        self.__live = False

        # Gather list of valid field names in format for processing.
        self.__fields = {}      # Maps names to definitions
        self.__registers = {}   # Maps register numbers to values
        for name, field_def in self._Fields.__dict__.items():
            if name[0] != '_':  # Need to filter out built-in names etc
                assert name not in self.__fields
                default, fields = self.__compute_fields(field_def)
                self.__fields[name] = fields

                # Fill in the initial register values from the default
                self.write_value(name, default)

        # Validate field assignments for this subclass
        for name in dir(self):
            if name in self.__fields:
                setattr(self, name, getattr(self, name))

        # Use keyword arguments to set extra attributes
        for name, value in kargs.items():
            setattr(self, name, value)

        self._Outputs = [getattr(self, name) for name in self._OutputNames]


    def clone(self):
        result = self.__class__(PLL = self.__PLL, base = self.__base)
        result._Fields = self._Fields
        result.__fields = copy.deepcopy(self.__fields)
        result.__registers = copy.deepcopy(self.__registers)
        return result


    # Updates the registers associated with the given named field.
    def write_value(self, name, value):
        for reg, width, offset in self.__fields[name]:
            field_mask = ((1 << width) - 1) << offset
            reg_value = self.__registers.setdefault(reg, 0) & ~field_mask
            field_value = (value << offset) & field_mask
            self.__registers[reg] = reg_value | field_value
            value >>= width
        assert value == 0, 'Value for %s too large for field' % name


    def write_pll(self, reg, value = None):
        if value is None:
            value = self.__registers[reg]
#         print 'PLL[%03x] <= %02x' % (self.__base + reg, value)
        self.__PLL[self.__base + reg] = value

    # Writes current register values for named field to hardware.
    def write_hardware(self, name):
        for reg, _, _ in self.__fields[name]:
            self.write_pll(reg)


    def __setattr__(self, name, value):
        output = name in self._OutputNames
        assert name[0] == '_' or name in self.__fields or output, \
            'Invalid attribute "%s"' % name
        self.__dict__[name] = value
        if name[0] != '_' and not output:
            regs = self.write_value(name, value)
            if self.__live:
                # Also write updated registers to hardware.
                self.write_hardware(name)


    def set_pll(self, PLL):
        self.__PLL = PLL

    def write_fields(self, first = 0, last = 0xFFF):
        self.__live = True
        for reg in sorted(self.__registers):
            if first <= reg <= last:
                self.write_pll(reg)


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Field definitions.
#
# For each named field we specify the associated register, the width in bits,
# the starting offset of the field, and the default power-on reset value.
#    If a named field is split across multiple registers then we represent this
# as a list of field definitions.

# Each output is controlled by a group of seven registers offset from 0x100+8*n
class OutputFields:
    # Name                 f  w  o  d   field/width/offset/default
    #
    CLK_ODL             = (0, 1, 6, 0)      # Output drive level
    CLK_IDL             = (0, 1, 5, 0)      # Input drive level
    DCLK_DIV            = (0, 5, 0, 0)      # Clock output divisor
    DCLK_DDLY_CNTH      = (1, 4, 4, 5)      # Digital delay high count
    DCLK_DDLY_CNTL      = (1, 4, 0, 5)      # Digital delay low count
    DCLK_DDLYd_CNTH     = (2, 4, 4, 5)      # Digital delay high count
    DCLK_DDLYd_CNTL     = (2, 4, 0, 5)      # Digital delay low count
    DCLK_ADLY           = (3, 5, 3, 0)      # Analogue delay
    DCLK_ADLY_MUX       = (3, 1, 2, 0)      # Enable duty cycle correction
    DCLK_MUX            = (3, 2, 0, 0)      # DCLK output mux
    DCLK_HS             = (4, 1, 6, 0)      # DCLK half step
    SDCLK_MUX           = (4, 1, 5, 0)      # Select SDCLK source
    SDCLK_DDLY          = (4, 4, 1, 0)      # SDCLK delay
    SDCLK_HS            = (4, 1, 0, 0)      # SDCLK half step
    SDCLK_ADLY_EN       = (5, 1, 4, 0)      # Enable SDCLK analogue delay
    SDCLK_ADLY          = (5, 4, 0, 0)      # SDCLK analogue delay
    DCLK_DDLY_PD        = (6, 1, 7, 1)      # Digital delay power down
    DCLK_HSg_PD         = (6, 1, 6, 1)      # Glitchless half step power down
    DCLK_ADLYg_PD       = (6, 1, 5, 1)      # Glitchless analogue delay p/d
    DCLK_ADLY_PD        = (6, 1, 4, 1)      # Analogue delay power down
    CLK_PD              = (6, 1, 3, 1)      # Clock group power down
    SDCLK_DIS_MODE      = (6, 2, 1, 0)      # Sysref power down output mode
    SDCLK_PD            = (6, 1, 0, 1)      # Sysref power down
    SDCLK_POL           = (7, 1, 7, 0)      # Invert sysref clock output
    SDCLK_FMT           = (7, 3, 4, 0)      # Sysref clock output format
    DCLK_PLL            = (7, 1, 3, 0)      # Invert device clock output
    DCLK_FMT            = (7, 3, 0, 0)      # Device clock output format


# This contains definitions of all the other fields.
class AllFields:
    # Name                 field  w  o  d   width/offset/default
    #
    VCO_MUX             = (0x138, 2, 5, 0)  # Selects internal VCO0
    OSCout_MUX          = (0x138, 1, 4, 0)
    # Configure OSCout/CLKin2 as CLKin2 input (not actually used)
    OSCout_FMT          = (0x138, 3, 0, 0)
    SYSREF_CLKin0_MUX   = (0x139, 1, 2, 0)  # SYSREF from MUX or CLKin0
    SYSREF_MUX          = (0x139, 2, 0, 0)  # SYSREF source
    SYSREF_DIV          = [(0x13A, 5, 0, 12),   (0x13B, 8, 0, 0)]
    SYSREF_DDLY         = [(0x13C, 5, 0, 0),    (0x13D, 8, 0, 8)]
    SYSREF_PULSE_CNT    = (0x13E, 2, 0, 3)
    PLL2_NCLK_MUX       = (0x13F, 1, 4, 0)  # PLL2 N divider input
    PLL1_NCLK_MUX       = (0x13F, 1, 3, 0)  # PLL1 N delay input
    FB_MUX              = (0x13F, 2, 1, 0)  # PLL1 feedback mux
    FB_MUX_EN           = (0x13F, 1, 0, 0)  # Enable 0-delay feedback mux
    # Power down controls for various functions
    PLL1_PD             = (0x140, 1, 7, 0)  # Power down PLL1
    VCO_LDO_PD          = (0x140, 1, 6, 0)  # Power down ??
    VCO_PD              = (0x140, 1, 5, 0)  # Power down VCO
    OSCin_PD            = (0x140, 1, 4, 0)  # Power down OSCin port
    SYSREF_GBL_PD       = (0x140, 1, 3, 0)  # Global SYSREF power down control
    SYSREF_PD           = (0x140, 1, 2, 0)  # Power down SYSREF
    SYSREF_DDLY_PD      = (0x140, 1, 1, 0)  # Power down SYSREF digital delay
    SYSREF_PLSR_PD      = (0x140, 1, 0, 0)  # Power down SYSREF pulse generator
    # Dynamic digital delay enables and control
    DDLYd_SYSREF_EN     = (0x141, 1, 7, 0)  # Enable SYSREF dynamic delay
    DDLYd12_EN          = (0x141, 1, 6, 0)  # Enable DCLK digital delay
    DDLYd10_EN          = (0x141, 1, 5, 0)
    DDLYd8_EN           = (0x141, 1, 4, 0)
    DDLYd6_EN           = (0x141, 1, 3, 0)
    DDLYd4_EN           = (0x141, 1, 2, 0)
    DDLYd2_EN           = (0x141, 1, 1, 0)
    DDLYd0_EN           = (0x141, 1, 0, 0)
    DDLYd_STEP_CNT      = (0x142, 4, 0, 0)  # Digital delay control
    # SYSREEF and SYNC control
    SYSREF_CLR          = (0x143, 1, 7, 1)  # Must be reset to 0
    SYNC_1SHOT_EN       = (0x143, 1, 6, 0)
    SYNC_POL            = (0x143, 1, 5, 0)
    SYNC_EN             = (0x143, 1, 4, 1)
    SYNC_PLL2_DLD       = (0x143, 1, 3, 0)
    SYNC_PLL1_DLD       = (0x143, 1, 2, 0)
    SYNC_MODE           = (0x143, 2, 0, 1)  # SYNC event generation control
    # Control of whether SYNC events disturb DCLK outputs
    SYNC_DISSYSREF      = (0x144, 1, 7, 0)
    SYNC_DIS12          = (0x144, 1, 6, 0)
    SYNC_DIS10          = (0x144, 1, 5, 0)
    SYNC_DIS8           = (0x144, 1, 4, 0)
    SYNC_DIS6           = (0x144, 1, 3, 0)
    SYNC_DIS4           = (0x144, 1, 2, 0)
    SYNC_DIS2           = (0x144, 1, 1, 0)
    SYNC_DIS0           = (0x144, 1, 0, 0)
    # Fixed register
    x145_8_0            = (0x145, 8, 0, 127)    # Always program to 127!
    # CLKin control
    CLKin2_EN           = (0x146, 1, 5, 0)  # Enable auto-switching
    CLKin1_EN           = (0x146, 1, 4, 0)  # Enable auto-switching
    CLKin0_EN           = (0x146, 1, 3, 0)  # Enable auto-switching
    CLKin2_TYPE         = (0x146, 1, 2, 0)  # Bipolar input
    CLKin1_TYPE         = (0x146, 1, 1, 0)  # Bipolar input
    CLKin0_TYPE         = (0x146, 1, 0, 0)  # Bipolar input
    CLKin_SEL_POL       = (0x147, 1, 7, 0)
    CLKin_SEL_MODE      = (0x147, 3, 4, 3)  # Select PLL1 reference
    CLKin1_OUT_MUX      = (0x147, 2, 2, 2)  # Select CLKin1 destination
    CLKin0_OUT_MUX      = (0x147, 2, 0, 2)  # Select CLKin0 destination
    CLKin_SEL0_MUX      = (0x148, 3, 3, 0)  # Not used
    CLKin_SEL0_TYPE     = (0x148, 3, 0, 2)  # Input with pull-down
    SDIO_RDBK_TYPE      = (0x149, 1, 6, 1)  # Open collector SPI SDIO output
    CLKin_SEL1_MUX      = (0x149, 3, 3, 0)  # Not used
    CLKin_SEL1_TYPE     = (0x149, 3, 0, 2)  # Input with pull-down
    RESET_MUX           = (0x14A, 3, 3, 0)  # Not used
    RESET_TYPE          = (0x14A, 3, 0, 2)  # Input with pull-down
    # Holdover functionality (not used)
    LOS_TIMEOUT         = (0x14B, 2, 6, 0)
    LOS_EN              = (0x14B, 1, 5, 0)
    TRACK_EN            = (0x14B, 1, 4, 1)
    HOLDOVER_FORCE      = (0x14B, 1, 3, 0)
    MAN_DAC_EN          = (0x14B, 1, 2, 1)
    MAN_DAC             = [(0x14B, 2, 0, 2),    (0x14C, 8, 0, 0)]
    DAC_TRIP_LOW        = (0x14D, 6, 0, 0)  # Holdover mode high threshold
    DAC_CLK_MULT        = (0x14E, 2, 6, 0)
    DAC_TRIP_HIGH       = (0x14E, 6, 0, 0)  # Holdover mode low threshold
    DAC_CLK_CNTR        = (0x14F, 8, 0, 127)
    CLKin_OVERRIDE      = (0x150, 1, 6, 0)
    HOLDOVER_PLL1_DET   = (0x150, 1, 4, 0)
    HOLDOVER_LOS_DET    = (0x150, 1, 3, 0)
    HOLDOVER_VTUNE_DET  = (0x150, 1, 2, 0)
    HOLDOVER_HITLESS_SWITCH = (0x150, 1, 1, 1)
    HOLDOVER_EN         = (0x150, 1, 0, 1)  # Holdover enabled by default
    HOLDOVER_DLD_CNT    = [(0x151, 6, 0, 2),    (0x152, 8, 0, 0)]
    CLKin0_R            = [(0x153, 6, 0, 0),    (0x154, 8, 0, 120)]
    CLKin1_R            = [(0x155, 6, 0, 0),    (0x156, 8, 0, 150)]
    CLKin2_R            = [(0x157, 6, 0, 0),    (0x158, 8, 0, 150)]
    PLL1_N              = [(0x159, 6, 0, 0),    (0x15A, 8, 0, 120)]
    PLL1_WND_SIZE       = (0x15B, 2, 6, 3)  # Lock detect window
    PLL1_CP_TRI         = (0x15B, 1, 5, 0)
    PLL1_CP_POL         = (0x15B, 1, 4, 1)
    PLL1_CP_GAIN        = (0x15B, 4, 0, 4)
    PLL1_DLD_CNT        = [(0x15C, 6, 0, 32),   (0x15D, 8, 0, 0)]
    PLL1_R_DLY          = (0x15E, 3, 3, 0)
    PLL1_N_DLY          = (0x15E, 3, 0, 0)
    PLL1_LD_MUX         = (0x15F, 5, 3, 1)  # Select output to Status_LD1 pin
    PLL1_LD_TYPE        = (0x15F, 3, 0, 3)  # Configure push-pull drive
    PLL2_P              = (0x162, 3, 5, 2)
    OSCin_FREQ          = (0x162, 3, 2, 7)
    PLL2_XTAL_EN        = (0x162, 1, 1, 0)
    PLL2_REF_2X_EN      = (0x162, 1, 0, 1)
    PLL2_FCAL_DIS       = (0x166, 1, 2, 0)
    PLL2_R              = [(0x160, 4, 0, 0),    (0x161, 8, 0, 2)]
    PLL2_N_CAL          = [
        (0x163, 2, 0, 0),   (0x164, 8, 0, 0),   (0x165, 8, 0, 12)]
    PLL2_N              = [
        (0x166, 2, 0, 0),   (0x167, 8, 0, 0),   (0x168, 8, 0, 12)]
    PLL2_WND_SIZE       = (0x169, 2, 5, 2)  # Must be left at this value!
    PLL2_CP_GAIN        = (0x169, 2, 3, 3)
    PLL2_CP_POL         = (0x169, 1, 2, 0)
    PLL2_CP_TRI         = (0x169, 1, 1, 0)
    x169_1_0            = (0x169, 1, 0, 1)  # Always program to 1!
    SYSREF_REQ_EN       = (0x16A, 1, 6, 0)
    PLL2_DLD_CNT        = [(0x16A, 6, 0, 32),   (0x16B, 8, 0, 0)]
    PLL2_LF_R4          = (0x16C, 3, 3, 0)
    PLL2_LF_R3          = (0x16C, 3, 0, 0)
    PLL2_LF_C4          = (0x16D, 4, 4, 0)
    PLL2_LF_C3          = (0x16D, 4, 0, 0)
    PLL2_LD_MUX         = (0x16E, 5, 3, 2)
    PLL2_LD_TYPE        = (0x16E, 3, 0, 3)  # Configure push-pull drive
    PLL2_PRE_PD         = (0x173, 1, 6, 0)
    PLL2_PD             = (0x173, 1, 5, 1)


# Some useful constant definitions
class Const:
    # Output settings for [S]DCLK_FMT fields
    FMT_LVDS = 1
    FMT_HSDS8 = 3


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Output(FieldWriter):
    _Fields = OutputFields



class SettingsBase(FieldWriter):
    _Fields = AllFields

    # Bases for output fields
    #
    # Output level definitions taken from Malibu Fmc_500_Mb.cpp, function
    # Fmc500_Pll::OnInit().

    #   0   LVDS        FMC GBTCLK1_M2C     Unused
    #  S1   HSDS 8mA    ADC SYNC
    out0_1 = Output(base = 0x100, SDCLK_FMT = Const.FMT_HSDS8)

    #   2   LVDS        FMC HB[0]           pll_dclkout2
    #  S3   LVDS        FMC LA[19]          pll_sdclkout3
    # Temporary testing outputs, will be unused in working system.
    out2_3 = Output(base = 0x108,
        DCLK_FMT = Const.FMT_LVDS, SDCLK_FMT = Const.FMT_LVDS)

    #   4   LVDS        DAC DACCLK
    #  S5                                   Unused
    out4_5 = Output(base = 0x110, DCLK_FMT = Const.FMT_LVDS)

    #   6   LVDS        DAC REFCLK
    #  S7                                   Unused
    out6_7 = Output(base = 0x118, DCLK_FMT = Const.FMT_LVDS)

    #   8   Used for internal 0-delay feedback
    #  S9                                   Unused
    out8_9 = Output(base = 0x120)

    #   10  HSDS 8mA    J12
    #  S11                                  Unused
    out10_11 = Output(base = 0x128, DCLK_FMT = Const.FMT_HSDS8)

    #   12  LVDS        FMC GBTCLK0_M2C     Unused
    #  S13  HSDS 8mA    ADC CLK
    out12_13 = Output(base = 0x130, SDCLK_FMT = Const.FMT_HSDS8)


    def __init__(self, PLL, **kargs):
        FieldWriter.__init__(self, PLL, **kargs)
        for output in self._Outputs:
            output.set_pll(PLL)

    def __fixed_setup(self):
        # Completion programming sequence according to page 49 9.5.1
        self.write_pll(0x171, 0xAA)
        self.write_pll(0x172, 0x02)
        self.write_pll(0x17C, 21)
        self.write_pll(0x17D, 51)

    # Writes PLL configuration as described on Page 49 9.5.1
    def write_config(self):
        # 1. Reset the device
        self.write_pll(0, 0x80)
        # 2. Program outputs (registers 0x100 to 0x137)
        for output in self._Outputs:
            output.write_fields()
        #    Program first block of registers (0x138 to 0x165)
        self.write_fields(last = 0x165)
        # 3-5. Program special registers with fixed values
        self.__fixed_setup()
        # 6. Program remaining registers
        self.write_fields(first = 0x166)


    # This is called to populate the given dictionary with the default output
    # definitions.
    #
    @classmethod
    def create_outputs(cls, result):
        outputs = dict(
            out0_1 = cls.out0_1.clone(),
            out2_3 = cls.out2_3.clone(),
            out4_5 = cls.out4_5.clone(),
            out6_7 = cls.out6_7.clone(),
            out8_9 = cls.out8_9.clone(),
            out10_11 = cls.out10_11.clone(),
            out12_13 = cls.out12_13.clone())

        # Mark all these names to be excluded from name check.
        result.update(outputs)
        result['_OutputNames'] = outputs.keys()
