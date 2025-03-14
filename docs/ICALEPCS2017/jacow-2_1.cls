%%
%% This file has been developed as a common template for papers
%% destined for electronic production for Accelerator Conferences
%%
%% See the JACoW website for more information
%%
%%       http://jacow.org/
%%
%% This work may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either
%% version 1.3c of this license or (at your option) any later
%% version. This version of this license is in
%%    http://www.latex-project.org/lppl/lppl-1-3c.txt
%% and the latest version of this license is in
%%    http://www.latex-project.org/lppl.txt
%% and version 1.3 or later is part of all distributions of
%% LaTeX version 2005/12/01 or later.
%%
%% This work has the LPPL maintenance status "maintained".
%%
%% This Current Maintainer of this work is Volker RW Schaa.
%%
%% This work consists of the following files
%%    jacow.cls               this class file
%%    LaTeX-A4-JACoW.tex      A4/letter templates to demonstrate the
%%    LaTeX-Letter-JACoW.tex  .. use and explain the various parameters
%%                            .. and settings for a submission to
%%                            .. a JACoW conference proceedings
%%    LaTeX-A4-JACoW.pdf      template in format A4 and European
%%                            settings (citation and hyphenation)
%%    LaTeX-Letter-JACoW.pdf  template in format letter and American
%%                            setting (citation and hyphenation)
%%    JACpic_mc.pdf           a graphic showing the JACoW page format
%%    JACpic2v5.png           a graphic for a full width figure and
%%                            multiline caption
%%    jacow-collaboration-2016.tex  an example title page showing the
%%    jacow-collaboration-2016.pdf  JACoW Colloaboration, the responsible
%%                                  editors for the various platform
%%                            dependent templates (LaTeX, Word on PC and
%%                            Mac, ODF). The PDF is included in the template
%%
%  v0.1-1.3
%  Special thanks to John Jowett and Michel Goossens from CERN and
%  Martin Comyn at TRIUMF for their significant contributions to
%  this class file over the period 1996 to 2000.
%                                                 John Poole
%                                                 March 2000
%  v1.4
%  JAC2001.cls is a modified version of JAC2000.cls to produce indented
%  first paragraphs after section, subsection and subsubsection headings.
%                                                 Martin Comyn  April 2001
%
%  v1.5
%  This is a modified version of JAC2003.cls to adjust space around
%  section and subsection headers to be more consistent with JACoW Word
%  templates.                                     Todd Satogata  March 2011
%
% v 1.6
% This is a complectly rewritten version of JAC2003.cls which needs a current
% TeX-System to run.
%                                                 Ulrike Fischer, November 2013
%
% v 1.7
% - small change to correct the text block inside JACoW's magic red borders for
%   a4paper (aca4); top has been set 18.5mm (19mm is defined in the template but
%   leaves descenders outside the lower y margin).
% - duplicate {boxit} removed
%                                                 Volker RW Schaa, 14 April 2014
%
% v1.8
% - added setup for \micro sign which disappears when using XeTeX or LuaTeX
%   with unicode-math.                             Ulrike Fischer, 21 April 2014
%
% v1.9
% - fixed the pdfLaTeX warnings for the text/math-micro hack
%                                                  Ulrike Fischer, 22 April 2014
%
% v1.91
% - Ligatures=TeX switch introduced to accommodate
%                                                  Ulrike Fischer, 22 April 2014
%
% v1.92
% - settings for top margin have to be different in A4 and letter to accommodate
%   JACoW's PitStop Action List. This was found after receiving Plamen Hopchev's
%   email about margins and testing the workflow with cropping the bounding box
%   which starts at the lower left edge and not at the top (see graphic JACpic_mc
%   in the template for measures).
%                                                 Volker RW Schaa, 29 April 2014
% v1.93
% - setting the bottom margin (19mm) without top solves the problem for different
%   A4/Letter settings. This was already the default in v1.6. Pointed out by
%   Plamen Hopchev. To accommodate the descenders the bottom margin has been set
%   to 56pt now.
%                                                   Volker RW Schaa, 01 May 2014
%
% v1.94
% - the micro sign in UTF-8 prevents ASCII format of the cls file. Ulrike pointed
%   out a hack in http://tex.stackexchange.com/questions/172968/hide-notation-from-pdftex
%   which is now introduced.
%                                                   Volker RW Schaa, 02 May 2014
%
% v1.95
% - only change to the version 1.94 are the extended documenation and license
%   statement (lppl1.3c) as preparation for publication on CTAN.
%                                                   Volker RW Schaa, 02 May 2014
%
% v1.96
% - modification of bibatex style information. Since the JACoW template Feb-2016
%   the bibliography requires the IEEEtran style. Heine provided an adapted
%   version using the required values of the template:
%   + ieee biblatex style instead of numeric-compv
%   + doi field is cleared for all entries
%   + et al. is used when there are > 6 authors (maxnames=6). In that case,
%     only the first author is mentioned (minnames=1)
%   + url field is cleared for articles and inproceedings
%   + giveninits=true reduces all given names to initials
%                                            Heine Dølrath Thomsen, 30 June 2016
%
% v2.00
% - after using v1.96 during conferences where DOIs/URLs were present in biblio-
%   graphic records, the following changes to Heine's version have been made:
%   + doi field allowed
%   + url field allowed
%                                                  Volker RW Schaa, 30 July 2016
%
\def\fileversion{2.1}
\def\filedate{2017/05/03}
\def\docdate {2017/05/03}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jacow-2_1}[\filedate\space Version \fileversion]

\typeout{------------------------------------------------------------------------}
\typeout{LaTeX2e Class file for Accelerator Conference publication for LaTeX2e users}
\typeout{ }
\typeout{Use the boxit option to draw a box on page showing the correct margins}
\typeout{ }
\typeout{Itemize, Enumerate and Description environments are compact versions}
\typeout{------------------------------------------------------------------------}
\typeout{ }

\newif\ifjacowbiblatex
\newif\ifjacowrefpage

\DeclareOption{acus}{%
   \PassOptionsToPackage{paper=letterpaper}{geometry}
   \typeout{Setup for US LETTER PAPER}}

\DeclareOption{letterpaper}{%
   \PassOptionsToPackage{paper=letterpaper}{geometry}
   \typeout{Setup for US LETTER PAPER}}

\DeclareOption{a4paper}{%
    \PassOptionsToPackage{paper=a4paper}{geometry}
    \typeout{Setup for A4 PAPER}}

\DeclareOption{aca4}{%
    \PassOptionsToPackage{paper=a4paper}{geometry}
    \typeout{Setup for A4 PAPER}}

\DeclareOption{boxit}{\PassOptionsToPackage{showframe}{geometry}}

\DeclareOption{biblatex}{\jacowbiblatextrue}

\DeclareOption{refpage}{\jacowrefpagetrue}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ExecuteOptions{aca4}
\ProcessOptions
\RequirePackage{fix-cm}
\LoadClass[10pt,twocolumn]{article}
\RequirePackage{flushend}
% Tools:
\RequirePackage{etoolbox}
\RequirePackage{ifxetex}
\RequirePackage{ifluatex}
\RequirePackage{textcase}%

%Add thanks to the list of "\@nonchangecase"-commands from textcase:
\def\@uclcnotmath#1#2#3#4{\begingroup
      #1%
      \def\({$}\let\)\(%
      \def\NoCaseChange##1{\noexpand\NoCaseChange{\noexpand##1}}%
      \@nonchangecase\label
      \@nonchangecase\ref
      \@nonchangecase\ensuremath
      \@nonchangecase\thanks %new
      \@nonchangecase\si %new
      \@nonchangecase\SI %new
      \def\cite##1##{\toks@{\noexpand\cite##1}\@citex}%
      \def\@citex##1{\NoCaseChange{\the\toks@{##1}}}%
      \def\reserved@a##1##2{\let#2\reserved@a}%
      \expandafter\reserved@a\@uclclist\reserved@b{\reserved@b\@gobble}%
      \protected@edef\reserved@a{\endgroup
          \noexpand\@skipmath#3#4$\valign$}%
      \reserved@a}

\RequirePackage[detect-mode,detect-weight]{siunitx}
\RequirePackage{graphicx}
\RequirePackage{booktabs}
\RequirePackage[figureposition=bottom,tableposition=top,skip=5pt]{caption}
\RequirePackage{xcolor}
\RequirePackage{url}
\AtEndPreamble{\RequirePackage[autostyle]{csquotes}}


% Page layout:
\RequirePackage[%
  textwidth=170mm,
  textheight=241mm,
  heightrounded,
  left=20mm,
  bottom=56pt,
  columnsep=5mm,
  noheadfoot,
  nomarginpar,
  twocolumn]
  {geometry}

\columnseprule 0pt
\usepackage[hang]{footmisc}
\setlength{\footnotemargin}{.6em}


\pagestyle{empty}

\ifboolexpr{bool{xetex} or bool{luatex}}
 {}
 { \catcode`\^^^=9
 }

\ifboolexpr{bool{xetex} or bool{luatex}}
 { \let\ori@vdots\vdots
   \RequirePackage{unicode-math}
   \AtBeginDocument{\let\vdots\ori@vdots}
   \setmainfont[Ligatures=TeX]{TeX Gyre Termes}
   \setmathfont{TeX Gyre Termes Math}
   \sisetup{
     math-micro = \text{^^^^03bc},
     text-micro = ^^^^03bc
      }
 }
 {
  % Fonts: Times clones
  \RequirePackage{textcomp}
  \RequirePackage[T1]{fontenc}
  \RequirePackage{lmodern}
  \RequirePackage{tgtermes}
  \RequirePackage{newtxmath}
 }

\RequirePackage{microtype}
%Lists

\RequirePackage{enumitem}
\newenvironment{Enumerate}{\begin{enumerate}[nosep]}{\end{enumerate}}
\newenvironment{Itemize}{\begin{itemize}[nosep]}{\end{itemize}}
\newenvironment{Description}{\begin{description}[nosep]}{\end{description}}


%Floatparameter:
\renewcommand{\topfraction}{.95}
\renewcommand{\bottomfraction}{.95}
\renewcommand{\textfraction}{0.1}
\renewcommand{\floatpagefraction}{0.8}


%headings:
% section: Uppercase only for text
\renewcommand{\section}
   {%
    \@startsection{section}{1}{0mm}
       {2.0ex plus 0.8ex minus .1ex}{1.0ex plus .2ex}
       {\normalfont\large\bfseries\mathversion{bold}\centering\MakeTextUppercase}%
   }%

\renewcommand\subsection
  {%
   \@startsection{subsection}{2}{\z@}
    {1.4ex plus .8ex minus .17ex}{0.8ex plus .17ex}
    {\normalfont\large\itshape}%
   }

\renewcommand\subsubsection
 {%
  \@startsection{subsubsection}{3}{\parindent}
  {2.5ex plus .7ex minus .17ex}{-1em}
  {\normalfont\normalsize\bfseries}%
 }

\renewcommand\paragraph
 {%
  \@startsection{paragraph}{4}{\z@}
  {2.5ex plus .7ex minus .17ex}{-1em}
  {\normalfont\normalsize\itshape}%
 }

\renewcommand\subparagraph
 {%
  \@startsection{subparagraph}{4}{\parindent}
  {2.25ex plus .7ex minus .17ex}{-1em}
  {\normalfont\normalsize\bfseries}%
 }

\setcounter{secnumdepth}{0}

% This definition of \maketitle taken from article.sty, and has been
% somewhat modified.

\def\maketitle{\par
 \begingroup
   \def\thefootnote{\fnsymbol{footnote}}
   \def\@makefnmark{\hbox
       to 5pt{$^{\@thefnmark}$\hss}}
   \twocolumn[\@maketitle]
   \@thanks
 \endgroup
 \enlargethispage{\jac@copyrightspace}%
 \setcounter{footnote}{0}
 \let\maketitle\relax
 \let\@maketitle\relax
 \gdef\@thanks{}\gdef\@author{}\gdef\@title{}\let\thanks\relax}

\newlength{\titleblockheight}       % so user can change it if need be
\setlength{\titleblockheight}{3.5cm}

\newlength\titleblockstartskip
\setlength\titleblockstartskip{3pt}


\newlength\titleblockmiddleskip
\setlength\titleblockmiddleskip{1em}

\newlength\titleblockendskip
\setlength\titleblockendskip{1em}


\def\@maketitle{%
  \vskip \titleblockstartskip \centering
  {\Large\bfseries \MakeTextUppercase{\@title} \par}
  \vskip \titleblockmiddleskip               % Vertical space after title.
  {\large\begin{tabular}[t]{@{}c@{}}\@author \end{tabular}\par}
  \vskip \titleblockendskip}


% The \copyrightspace command is used to produce a blank space in the first
% column where a copyright notice may go.  It works by producing
% with \enlargethispage and is inserted by \maketitle.
% The command should be issued in the preamble.

\newcommand\jac@copyrightspace{0pt}
\newcommand\copyrightspace[1][1cm]{\renewcommand\jac@copyrightspace{-#1}}

\ifboolexpr{bool{@titlepage}}
{\renewenvironment{abstract}
 {\list{}{%
    \setlength{\leftmargin}{\dimexpr\textwidth/2-0.75\columnwidth}%
    \setlength{\rightmargin}{\dimexpr-0.75\columnwidth-\columnsep}%
    \setlength{\listparindent}{\parindent}%
    \setlength{\itemsep}{\parskip}%
    \setlength{\itemindent}{\z@}%
    \setlength{\topsep}{\z@}%
    \setlength{\parsep}{\parskip}%
    \setlength{\partopsep}{\z@}%
    \let\makelabel\@gobble
    \setlength{\labelwidth}{\z@}%
    \advance\@listdepth\m@ne   }%
   \item\relax\subsection*{Abstract}}
 {\endlist\clearpage}
}
{%
 \renewenvironment{abstract}
  {\subsection*{Abstract}}
  {\par}
}
\ifboolexpr{bool{jacowbiblatex}}
%2.00 {\RequirePackage[style=ieee,sorting=none,giveninits=true,doi=false,maxnames=6,minnames=1]{biblatex}
 {%\RequirePackage[style=ieee,sorting=none,giveninits=true,maxnames=6,minnames=1]{biblatex}
%2.1
  \RequirePackage[bibstyle=ieee,citestyle=numeric-comp,sorting=none,giveninits=true,maxnames=6,minnames=1]{biblatex}
  \renewbibmacro*{url+urldate}{%
    \iffieldundef{url}
     {}
     {\printfield{url}%
      \nopunct}}%
  \DeclareFieldFormat{url}{\url{#1}}
  \DeclareFieldFormat{eprint}{#1}
  % Drop urls for article and inproceedings entries
%2.00  \DeclareFieldFormat
%2.00  [article,inproceedings]
%2.00  {url}{}
  %
  \setlength\bibitemsep{0pt}
  \setlength\bibparsep{0pt}
  \setlength\biblabelsep{5pt}
  \ifjacowrefpage\preto\blx@bibliography{\clearpage}\fi
  \AtBeginBibliography{\small\clubpenalty4000\widowpenalty4000}%
 }
 {\RequirePackage{cite}
  % Redefine to use smaller fonts
  \def\thebibliography#1{\setlength{\itemsep}{0pt}\setlength{\parsep}{0pt}%
  \ifjacowrefpage\clearpage\fi
  \section*{REFERENCES\@mkboth
  {REFERENCES}{REFERENCES}}\small\list
  {[\arabic{enumi}]}{\settowidth\labelwidth{[#1]}\leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \usecounter{enumi}}
    \def\newblock{\hskip .11em plus .33em minus .07em}
    \sloppy\clubpenalty4000\widowpenalty4000
    \sfcode`\.=1000\relax}
   \let\endthebibliography=\endlist
  }


%\sloppy
\clubpenalty10000\widowpenalty10000
\flushbottom
%-----------------------------------------------------------------------

%avoid bug of fixltx2e:
%http://www.latex-project.org/cgi-bin/ltxbugs2html?pr=latex/4023
\RequirePackage{fixltx2e}%
\def\@outputdblcol{%
  \if@firstcolumn
    \global\@firstcolumnfalse
    \global\setbox\@leftcolumn\copy\@outputbox
    \splitmaxdepth\maxdimen
    \vbadness\maxdimen
    \setbox\@outputbox\vbox{\unvbox\@outputbox\unskip}%new
    \setbox\@outputbox\vsplit\@outputbox to\maxdimen
    \toks@\expandafter{\topmark}%
    \xdef\@firstcoltopmark{\the\toks@}%
    \toks@\expandafter{\splitfirstmark}%
    \xdef\@firstcolfirstmark{\the\toks@}%
    \ifx\@firstcolfirstmark\@empty
      \global\let\@setmarks\relax
    \else
      \gdef\@setmarks{%
        \let\firstmark\@firstcolfirstmark
        \let\topmark\@firstcoltopmark}%
    \fi
  \else
    \global\@firstcolumntrue
    \setbox\@outputbox\vbox{%
     \hb@xt@\textwidth{%
        \hb@xt@\columnwidth{\box\@leftcolumn \hss}%
        \hfil
        \vrule \@width\columnseprule
        \hfil
       \hb@xt@\columnwidth{\box\@outputbox \hss}}}%
  \@combinedblfloats
    \@setmarks
    \@outputpage
    \begingroup
      \@dblfloatplacement
      \@startdblcolumn
      \@whilesw\if@fcolmade \fi{\@outputpage\@startdblcolumn}%
    \endgroup
  \fi}

\endinput
