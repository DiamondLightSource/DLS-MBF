# DLS-MBF Documentation

The **DLS-MBF documentation** is maintained in the **Wiki** associated with this repository.

➡️ **[Go to the DLS-MBF Wiki](https://github.com/DiamondLightSource/DLS-MBF/wiki)**

## About the wiki repository

The documentation content itself is maintained in the project wiki, which is different from the DLS-MBF repository.

The wiki pages are designed to be compatible with both GitHub and GitLab wikis, despite differences in Markdown syntax and supported features. To ensure portability between the two platforms, wiki pages should use a relatively simple and widely supported subset of Markdown.

The wiki content does not contain any absolute references to the hosting platform. Consequently, it can be forked to another GitHub or GitLab instance and used without modification.

**Note:** This README contains absolute links to the original repository. These links may need to be updated when the repository is forked or moved to another location.

### How to clone the wiki repository

The wiki content is versioned in a dedicated Git repository and can be cloned using either HTTPS or SSH.

Clone using HTTPS:
```bash
git clone https://github.com/DiamondLightSource/DLS-MBF.wiki.git
```

Clone using SSH:
```bash
git clone git@github.com:DiamondLightSource/DLS-MBF.wiki.git
```

## Versioning

To access the documentation corresponding to a previous MBF version, retrieve the commit SHA recorded in [`VERSIONS.md`](VERSIONS.md) and check out the corresponding commit in the wiki repository.

## Wiki maintenance notes

The following points should be considered whenever the wiki is updated.

### Documentation guidelines

The [`SYNTAX.md`](SYNTAX.md) file describes the Markdown conventions and formatting rules that must be followed to maintain compatibility between GitHub and GitLab wikis.

### Manually maintained tables of contents

Some wiki pages contain tables of contents that are **not generated automatically** and must be updated manually whenever pages are added, renamed, or removed.

The following files require particular attention:

- `_Sidebar.md`
- `home.md`
- `home-Help-Pages-for-Multi-Bunch-Feedback.md`
- `home-Help-Pages-for-Multi-Bunch-Feedback-version-1.3.md`

### Visual editing

A visual editor can be helpful when creating or modifying pages with complex layouts.

In particular, the **GitLab visual editor** can be useful when editing complex tables, especially those containing nested structures.

Unfortunately, GitHub does not provide an equivalent visual editor for editing complex Markdown elements.

### Version tracking

Whenever a new MBF version is released, update [`VERSIONS.md`](VERSIONS.md) with the commit SHA of the wiki documentation corresponding to that version.
