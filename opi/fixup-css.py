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


# ------------------------------------------------------------------------------
# Fixup actions


def convert_button_paths(root):
    # For all related display actions we need to edit the path by deleting the
    # leading prefix.
    path = '''
        widget
        actions
        action[@type='OPEN_DISPLAY']
        path
    '''
    for widget in find_widgets(root, path):
        widget.text = re.sub('^[^/]*/', './', widget.text)


def convert_linked_paths(root):
    # Similarly, all embedded windows need to be converted to relative paths.
    # We also need to set the border style of the containing parent to 0
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.linkingContainer']
    '''
    for widget in find_widgets(root, path):
        script = widget.find('scripts/path/scriptText')
        script.text = re.sub('"mbf/', '"./', script.text)

        border_style = et.Element('border_style')
        border_style.text = '0'
        widget.append(border_style)


def convert_editable_fields(root):
    # Convert editable input fields to Lowered Style border for visibility
    path = '''
        widget[@typeId='org.csstudio.opibuilder.widgets.TextInput']
        border_style
    '''
    for widget in find_widgets(root, path):
        widget.text = '3'


def convert_menumux_pv(root):
    # The menumux result needs to be converted into a local pv, and we'll need
    # to fix up the result of this conversion where it's used.
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


def convert_xygraph_traces(root, name):
    # In our specific application we substitute the one name in the x_pv traces
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
menumux_name = convert_menumux_pv(root)
if menumux_name:
    convert_xygraph_traces(root, menumux_name)

tree.write(sys.argv[1], encoding = 'utf-8', xml_declaration = True)
