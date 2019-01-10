/* Manages a bunch set selection user interface. */

struct bunch_set;

/* This will create bindings for two records in the current name prefix context:
 *
 *  :BUNCH_SELECT_S     stringout
 *  :SELECT_STATUS      stringin
 *
 * The database must be configured so that :SELECT_STATUS is processed when
 * :BUNCH_SELECT_S is written. */
struct bunch_set *create_bunch_set(void);

/* Writes the given value to the currently selected bunches in the given record.
 * The waveform_type and value_size must match the underlying record type. */
void update_record_with_bunch_set(
    struct bunch_set *bunch_set,
    struct epics_record *record, enum waveform_type waveform_type,
    const void *value, size_t value_size);


#define _id_UPDATE_RECORD_BUNCH_SET(value, type, bunch_set, record, value_in) \
    do { \
        type value = value_in; \
        update_record_with_bunch_set( \
            bunch_set, record, waveform_TYPE_##type, \
            &value, sizeof(value)); \
    } while(0)
#define UPDATE_RECORD_BUNCH_SET(type, bunch_set, record, value_in) \
    _id_UPDATE_RECORD_BUNCH_SET( \
        UNIQUE_ID(), type, bunch_set, record, value_in)
