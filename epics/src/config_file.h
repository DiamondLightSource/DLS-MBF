/* Configuration file parsing. */


/* The following types configuration entry are supported. */
enum config_entry_type {
    CONFIG_int,
    CONFIG_uint,
    CONFIG_double,
    CONFIG_string,
    CONFIG_bool,
};


/* Configuration file definition. */
struct config_entry
{
    enum config_entry_type entry_type;    // Type of value
    const char *name;               // Name of value to read from file
    void *address;                  // Where to write result
};


/* Reads configuration from named file according to rules defined in
 * config_table[].  If ignore_unknown is set then undefined keys are ignored. */
error__t load_config_file(
    const char *file_name, const struct config_entry config_table[],
    size_t config_size, bool ignore_unknown);
