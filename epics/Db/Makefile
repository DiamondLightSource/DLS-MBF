TOP = ..
include $(TOP)/configure/CONFIG

#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

#----------------------------------------------------
# Create and install (or just install) into <top>/db
# databases, templates, substitutions like this
DB += lmbf.db
DB += tmbf.db
DB += access.acf

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_template = <templatename>

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

# include $(TOP)/install_d/CONFIG

export EPICS_DEVICE

# We use the python library to construct the .db file
%.db: $(wildcard ../*.py)
	$(PYTHON) ../mbf.py $@ $(*F)


clean::
	rm -f *.pyc
