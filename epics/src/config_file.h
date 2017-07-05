/* Configuration file parsing. */


/* The following types configuration entry are supported. */
enum config_entry_type {
    CONFIG_int,
    CONFIG_uint,
    CONFIG_double,
    CONFIG_string,
};


/* Configuration file definition. */
struct config_entry
{
    enum config_entry_type entry_type;    // Type of value
    const char *name;               // Name of value to read from file
    void *address;                  // Where to write result
};


error__t load_config_file(
    const char *file_name, const struct config_entry config_table[],
    size_t config_size);
