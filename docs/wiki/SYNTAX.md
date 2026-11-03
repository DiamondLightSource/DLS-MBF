# Wiki Syntax and Formatting Guidelines

This document defines the rules to follow when creating or modifying wiki pages in the MBF-DLS documentation.

The main objective is to ensure that the documentation remains compatible with both **GitHub and GitLab wikis**, without requiring platform-specific modifications.

## File Organisation

Follow these rules when creating or organising wiki files:

- **Markdown files:** All `.md` files must be located at the root of the wiki repository.
- **File names:** File names must not contain spaces. Use hyphens (`-`) to separate words when necessary.

Examples:

```text
wiki/
├── _Sidebar.md
├── home.md
├── home-Bringing-up-MBF.md
├── home-Help-Pages-for-Multi-Bunch-Feedback.md
├── images/
│   ├── adc.png
│   ├── overview.png
├── files/
│   ├── DEELS2019.pdf
│   └── extensions.tgz
└── ...
```

Two files have a special role in the wiki:

- **`home.md`:** Defines the wiki home page, which is displayed when users access the wiki's main entry point.
- **`_Sidebar.md`:** Defines the wiki navigation sidebar, providing a hierarchical overview of all documentation pages.

## Links

Use the standard Markdown link syntax for all links:

```markdown
[Link text](target)
```

### Links to wiki pages

When linking to another wiki page, **do not include the `.md` extension** in the link target.

Omitting the extension ensures that the link opens the rendered wiki page rather than displaying the raw Markdown source.

Example:

```markdown
See the [Installation](Installation) page for instructions.
```

**Incorrect:**

```markdown
See the [Installation](Installation.md) page for instructions.
```

### Linking to a specific section of a wiki page

You can also use **anchors** to link directly to a specific section within a wiki page.

The anchor is appended to the page name, preceded by `#`. GitHub and GitLab automatically generate anchors from Markdown headings.

To obtain an anchor, navigate to the desired section on the wiki and click the link icon next to its heading. Copy the resulting link and use the part following `#` as the anchor.

For example, given a page containing the following heading:

```markdown
## Hardware
```

You can link directly to that section using:

```markdown
See the [Hardware](home-Bringing-up-MBF#hardware) section.
```

### Links to external websites

Use the full URL as the link target.

Example:

```markdown
See the [Git documentation](https://git-scm.com/doc) for more information.
```

### Links to downloadable attachments

Links to downloadable files must follow a consistent format that includes a download icon and the file name.

Use the following syntax:

```markdown
[`📥 file.pdf`](files/file.pdf)
```

Unlike wiki page links, attachment links must include the file name and its extension.

## Text Formatting

The following formatting options can be used to improve the readability of wiki pages.

### Bold

Use double asterisks (`**`) to display text in bold.

```markdown
**This text is bold.**
```

### Italic

Use single asterisks (`*`) to display text in italic.

```markdown
*This text is italic.*
```

### Bold and italic

Both styles can be combined using three asterisks (`***`).

```markdown
***This text is bold and italic.***
```

### Superscript

Use the HTML `<sup>` tag to display superscript text.

```html
E = mc<sup>2</sup>
```

Result: E = mc<sup>2</sup>

### Subscript

Use the HTML `<sub>` tag to display subscript text.

```html
H<sub>2</sub>O
```

Result: H<sub>2</sub>O

### Line breaks

Use the HTML `<br>` tag to force a line break without starting a new paragraph.

```html
First line.<br>
Second line.
```

Result:

First line.<br>
Second line.

## Mathematical Formulas

Mathematical formulas can be included either inline or as separate blocks.

**Compatibility note:** Mathematical rendering may differ between GitHub and GitLab. Verify that formulas display correctly on both platforms.

### Inline formulas

Use single dollar signs (`$`) to delimit an inline formula.

Example:

```markdown
The relativistic energy is given by $E = mc^2$.
```

Result:

The relativistic energy is given by $E = mc^2$.

### Block formulas

Use double dollar signs (`$$`) to delimit a formula displayed as a separate block.

Example:

```markdown
$$
E = mc^2
$$
```

Block formulas should be separated from surrounding text by blank lines.

## Admonition Blocks

Admonition blocks can be used to highlight important information, tips, warnings, or potential risks.

The following block types are supported:

- `[!note]`
- `[!tip]`
- `[!important]`
- `[!warning]`
- `[!caution]`

Use the following syntax, replacing `note` with the desired block type:

```markdown
> [!note]
> This parameter is optional.
```

### Examples

> [!note]
> This parameter is optional.

> [!tip]
> Use a relative link when referencing another wiki page.

> [!important]
> Update the manually maintained table of contents when adding a new page.

> [!warning]
> Changing this parameter may affect the system configuration.

> [!caution]
> Verify the configuration before applying changes to a running system.

## Compatibility Principle

The primary requirement is that the same wiki content must be usable on both GitHub and GitLab without modification.

When introducing new syntax or formatting, verify its compatibility with both platforms before using it throughout the documentation.

If a feature behaves differently between the two platforms, prefer a simpler alternative that produces an acceptable result on both.
