# Simple CSS fixup

import sys
import re

import xml.etree.ElementTree as et



# Converts a macro name into a local PV
def name_to_loc(name, default = None):
    if default is None:
        return 'loc://$(DID)%s' % name
    else:
        return 'loc://$(DID)%s<VString>("%s")' % (name, default)

# Given a string with a substitution of the form $(name) converts this into the
# appropriate scripting using the pv() function.
def subst_to_pv(name, pv):
    lookup = 'toString(\'%s\')' % name_to_loc(name)
    pv_split = pv.split('$(%s)' % name)
    # This step is a bit irritating.  We want to convert the list pv_split,
    # of the general form [a, b, ..., c] into a list [a, x, b, x, ..., c] and
    # then drop any empty entries from the list, but this seems to be hard to do
    # cleanly.
    concat_args = sum((['"%s"' % part, lookup] for part in pv_split[:-1]), [])
    concat_args = filter(None, concat_args)
    return '=pv(concat(%s))' % ', '.join(concat_args)


# Helper for xpaths
def find_widgets(root, xpath):
    xpath = re.sub(' *\n *', '/', xpath.strip())
    return root.findall(xpath)

# Helper for finding elements with particular tag patterns
def find_matching(node, pattern):
    for element in node:
        if re.match(pattern, element.tag):
            yield element


def create_element(tag, _text = '', _elements = [], **kargs):
    element = et.Element(tag)
    element.text = _text
    for name, value in kargs.items():
        element.set(name, value)
    element.extend(_elements)
    return element


# ------------------------------------------------------------------------------
# Fixup actions


# For all related display actions we need to edit the path by deleting the
# leading prefix.
def convert_button_paths(root):
    path = '''
        widget
        actions
        action[@type='OPEN_DISPLAY']
        path
    '''
    for widget in find_widgets(root, path):
        widget.text = re.sub('^[^/]*/', './', widget.text)


# Similarly, all embedded windows need to be converted to relative paths.  We
# also need to set the border style of the containing parent to 0
def convert_linked_paths(root):
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.linkingContainer']
    '''
    for widget in find_widgets(root, path):
        script = widget.find('scripts/path/scriptText')
        script.text = re.sub('"mbf/', '"./', script.text)

        widget.append(create_element('border_style', '0'))


# Convert editable input fields to Lowered Style border for visibility
def convert_editable_fields(root):
    path = '''
        .//widget[@typeId='org.csstudio.opibuilder.widgets.TextInput']
        border_style
    '''
    for widget in find_widgets(root, path):
        widget.text = '3'


# Convert long string display type to String display type.  Fortunately this
# only occurs once
def convert_hostname_field(root):
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.TextUpdate']\
[pv_name='$(device):HOSTNAME']
        format_type
    '''
    for widget in find_widgets(root, path):
        widget.text = '4'


# Convert commands to use path to scripts dir and special CSS flag
def convert_command_script(root):
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.ActionButton']
        actions
        action[@type='EXECUTE_CMD']
        command
    '''
    for widget in find_widgets(root, path):
        # If command is run-command add the special -P flag
        widget.text = re.sub(
            '^run-command', 'run-command -P', widget.text)
        # Add explicit path to script
        widget.text = re.sub('^', '../scripts/', widget.text)


# The menumux result needs to be converted into a local pv, and we'll need to
# fix up the result of this conversion where it's used.
def convert_menumux_pv(root):
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.edm.menumux']
    '''
    for widget in find_widgets(root, path):
        field = widget.find('target0')
        value = widget.find('values0').find('s').text
        name = field.text
        field.text = name_to_loc(name, value)

        # There is only going to be one match
        return name


# In our specific application we substitute the one name in the x_pv traces
def convert_xygraph_traces(root, name):
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.dawn.xygraph']
    '''
    for widget in find_widgets(root, path):
        for field in find_matching(widget, 'trace_[0-9]_x_pv'):
            field.text = subst_to_pv(name, field.text)


# ------------------------------------------------------------------------------
# Convert and update

tree = et.parse(sys.argv[1])
root = tree.getroot()

convert_button_paths(root)
convert_linked_paths(root)
convert_editable_fields(root)
convert_hostname_field(root)
convert_command_script(root)
menumux_name = convert_menumux_pv(root)
if menumux_name:
    convert_xygraph_traces(root, menumux_name)

tree.write(sys.argv[1], encoding = 'utf-8', xml_declaration = True)
