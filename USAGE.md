# Custom Beamer Template

A fixed-layout Beamer presentation template designed for 1920×1080 resolution with precise positioning and section tracking.

## Features

- **Fixed Layout**: Exact 1920×1080 pixel positioning scaled to 16:9 aspect ratio
- **Three Regions**: Title bar, main content area, and right sidebar
- **Section Tracking**: Dynamic sidebar showing presentation progress
- **Logo Integration**: Customizable logo positioning
- **No Default Elements**: Clean presentation without standard Beamer decorations

## Layout Specifications

### Title Area
- Dimensions: 1600×180 px (13.33×1.5 cm)
- Position: Top-left corner (0, 0)
- Background: `#015188` (dark blue)
- Text: White, centered vertically and horizontally

### Main Content Area
- Dimensions: 1600×900 px (13.33×7.5 cm)
- Position: Below title area at (0, 180)
- Background: White
- Contains slide content

### Right Sidebar
- Dimensions: 320×1080 px (2.67×9 cm)
- Position: Right edge (1600, 0)
- Background: `#00A7EF` (light blue)
- Contains logo and section list

## Usage

### Basic Slide Creation

```latex
\FullSlide{Slide Title}{Section ID}{%
  % Your slide content here
  \begin{itemize}
    \item First point
    \item Second point
  \end{itemize}
}
```

### Parameters

1. **Slide Title**: Text displayed in the title bar
2. **Section ID**: Unique identifier for section tracking
3. **Content**: LaTeX content for the main area

### Section Tracking

- Sections appear in sidebar only after being used
- Current section highlighted with white background
- Previous sections shown with blue background
- Section IDs should be unique and descriptive

### Logo Customization

Replace the default logo by redefining the logo path:

```latex
\renewcommand{\logopath}{path/to/your/logo.png}
```

## Example Document Structure

```latex
\documentclass{beamer-template}

\renewcommand{\logopath}{your-logo.png}

\begin{document}

\FullSlide{Introduction}{intro}{%
  Welcome to the presentation!
}

\FullSlide{Main Topic}{main}{%
  \begin{itemize}
    \item Key point 1
    \item Key point 2
  \end{itemize}
}

\FullSlide{Conclusion}{conclusion}{%
  Thank you for your attention.
}

\end{document}
```

## Color Customization

The template defines three main colors that can be customized:

```latex
\definecolor{TitleBG}{HTML}{015188}    % Title background
\definecolor{SidebarBG}{HTML}{00A7EF}  % Sidebar background  
\definecolor{ContentBG}{HTML}{FFFFFF}  % Content background
```

## Files

- `beamer-template.cls`: Main template class file
- `sample-presentation.tex`: Example presentation demonstrating usage

## Requirements

- LaTeX with Beamer package
- TikZ package for positioning
- XColor package for colors
- GraphicX package for logo handling
