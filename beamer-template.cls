% Custom Beamer Template Class
% Fixed 1920x1080 layout with manual positioning
% Version 2.0: Added two-pass compilation for full navigation mode
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{beamer-template}[2025/08/01 Custom Fixed Layout Beamer Template]

% --- CLASS OPTIONS ---
% 'presentation' (default): Sidebar shows only visited sections.
% 'navigation': Sidebar shows ALL sections (requires 2 compilations).
\newif\ifshowallsections
\showallsectionsfalse
\DeclareOption{navigation}{\showallsectionstrue}
\DeclareOption{presentation}{\showallsectionsfalse}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax

% --- PACKAGE LOADING ---
\LoadClass[aspectratio=169]{beamer}
\RequirePackage{tikz}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
\RequirePackage{etoolbox}
\RequirePackage{xstring}

% --- COLOR DEFINITIONS ---
\definecolor{TitleBG}{HTML}{414867}
% \definecolor{SidebarBG}{HTML}{9199BA}
% \definecolor{SidebarBG}{HTML}{C1CAF4}
\definecolor{SidebarBG}{HTML}{82869A}
\definecolor{ContentBG}{HTML}{FFFFFF}

% --- BEAMER DEFAULTS OVERRIDE ---
% Disable all default beamer elements for a fully custom layout
\setbeamertemplate{navigation symbols}{}
\setbeamertemplate{headline}{}
\setbeamertemplate{footline}{}
\setbeamertemplate{sidebar right}{}
\setbeamertemplate{sidebar left}{}
\setbeamertemplate{frametitle}{}
\geometry{paperwidth=16cm,paperheight=9cm}

% --- SECTION TRACKING LOGIC (TWO-PASS SYSTEM) ---

% For 'presentation' mode (dynamic list of visited sections)
\newcommand{\sectionlist}{}
\newcommand{\currentsectionname}{}
\newcommand{\lastsectionadded}{}

% For 'navigation' mode (global list loaded from .aux file)
\gdef\allsectionslist{}
\gdef\collectedsections{} % Temp list to prevent duplicate writes to .aux

% \AddSection: Builds the DYNAMIC list for 'presentation' mode.
\newcommand{\AddSection}[1]{%
  \def\tempsection{#1}%
  \ifx\sectionlist\empty%
    \xdef\sectionlist{#1}%
    \xdef\lastsectionadded{#1}%
  \else%
    \ifx\lastsectionadded\tempsection%
      % Same section, do nothing
    \else%
      \xdef\sectionlist{\sectionlist,#1}%
      \xdef\lastsectionadded{#1}%
    \fi%
  \fi%
  \xdef\currentsectionname{#1}%
}

% \StoreSectionData: Called from .aux file at start of 2nd pass.
% Populates the global list of all sections.
\newcommand{\StoreSectionData}[1]{%
  \ifx\allsectionslist\empty%
    \xdef\allsectionslist{#1}%
  \else%
    \xdef\allsectionslist{\allsectionslist,#1}%
  \fi%
}

% \CollectSectionData: Called on 1st pass to write unique section
% IDs to the .aux file.
\newcommand{\CollectSectionData}[1]{%
  \bgroup%
  \edef\cleanedsectionname{#1}%
  % Use xstring's \IfSubStr to check if section already exists
  \IfSubStr{\collectedsections}{\cleanedsectionname}{%
    % If already collected in this run, do nothing
  }{%
    % If new, add to temp list and write to .aux file for the next pass
    \ifx\collectedsections\empty%
      \xdef\collectedsections{#1}%
    \else%
      \xdef\collectedsections{\collectedsections,#1}%
    \fi%
    % Write the command directly to the aux file
    \immediate\write\@auxout{\string\StoreSectionData{#1}}%
  }%
  \egroup%
}

% --- CUSTOMIZATION HOOKS ---
% Logo path (can be overridden in main .tex file)
\newcommand{\logopath}{./change-in-main-file}
\IfFileExists{\logopath}{}{\renewcommand{\logopath}{example-image-a}}

% --- SIDEBAR RENDERING LOGIC ---
% Renders the section list based on the selected mode.
\newcommand{\RenderSections}[1]{%
  \ifshowallsections%
    % NAVIGATION MODE: Use the global list of all sections.
    \edef\renderlist{\allsectionslist}%
  \else%
    % PRESENTATION MODE: Use the dynamic list of visited sections.
    \edef\renderlist{\sectionlist}%
  \fi%

  \ifx\renderlist\empty\else%
    \pgfmathsetmacro{\currentypos}{0}%
    \foreach \sec in \renderlist {%
      \ifx\sec\empty\else%
        % Calculate box height based on text length
        \StrLen{\sec}[\seccharcount]%
        \ifnum\seccharcount>16\relax%
          \def\boxheight{1.0}\def\textyoffset{0.5}%
        \else%
          \def\boxheight{0.5}\def\textyoffset{0.25}%
        \fi%
        
        \edef\tempsec{#1}%
        \edef\currentsec{\sec}%
        
        \ifx\currentsec\tempsec%
          % Current section: white background, black text
          \fill[white] (0, \currentypos) rectangle (2.67, \currentypos-\boxheight);%
          \node[black, font=\footnotesize\bfseries, align=center, text width=2.4cm] 
               at (1.335, \currentypos-\textyoffset) {\sec};%
        \else%
          % Other sections: blue background, white text, clickable
          \fill[SidebarBG] (0, \currentypos) rectangle (2.67, \currentypos-\boxheight);%
          \node[white, font=\footnotesize, align=center, text width=2.4cm] 
               at (1.335, \currentypos-\textyoffset) {\hyperlink{sec:\sec}{\sec}};%
        \fi%
        \pgfmathsetmacro{\currentypos}{\currentypos-\boxheight}%
        \global\let\currentypos\currentypos%
      \fi%
    }%
  \fi%
}

% --- MAIN SLIDE MACRO ---
\newcommand{\FullSlide}[3]{%
  % #1: Slide title
  % #2: Section identifier
  % #3: Content
  
  % Call BOTH collectors. One builds the dynamic list for presentation mode,
  % the other writes data to the .aux file for navigation mode.
  \CollectSectionData{#2}%
  \AddSection{#2}%
  
  \begin{frame}[plain, label={sec:#2}]
    \begin{tikzpicture}[remember picture, overlay]
      % Scale: 16cm width = 1920px, so 1cm = 120px
      
      % 1. Title Area (1600x180 px = 13.33x1.5 cm)
      \fill[TitleBG] (current page.north west) rectangle ++(13.33, -1.5);
      % black text title
      % \node[black, font=\Large\bfseries, text width=13cm, align=center] 
        %  at ([xshift=6.665cm, yshift=-0.75cm]current page.north west) {#1};
      % white text title
      \node[white, font=\Large\bfseries, text width=13cm, align=center] 
         at ([xshift=6.665cm, yshift=-0.75cm]current page.north west) {#1};
      % 2. Content Area (1600x900 px = 13.33x7.5 cm)
      \fill[ContentBG] ([yshift=-1.5cm]current page.north west) rectangle ++(13.33, -7.5);
      
      % 3. Right Sidebar (320x1080 px = 2.67x9 cm)
      \begin{scope}[shift={([xshift=13.33cm]current page.north west)}]
        \fill[SidebarBG] (0, 0) rectangle (2.67, -9);
        \node at (1.335, -0.9) {%
          \includegraphics[width=2.2cm, height=1.5cm, keepaspectratio]{\logopath}%
        };
        \begin{scope}[shift={(0, -2)}]
          \RenderSections{\currentsectionname}
        \end{scope}
        \node[white, font=\footnotesize, anchor=south east] 
          at (2.57, -9) {\insertframenumber/\inserttotalframenumber};
      \end{scope}
      
      % 4. Main Content
      \node[anchor=north west, text width=12.8cm, inner sep=0pt] 
           at ([xshift=0.3cm, yshift=-1.8cm]current page.north west) {#3};
    \end{tikzpicture}
  \end{frame}%
}