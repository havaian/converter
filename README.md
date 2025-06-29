# Universal File Converter

![Universal File Converter](resources/icons/app_icon.png)

A powerful, offline file converter that unifies different conversion utilities (FFmpeg, Pandoc, LibreOffice) into a single, easy-to-use interface.

## Features

- **Versatile Conversion**: Convert between various file formats
  - **Documents**: PDF, DOC, DOCX, ODT, TXT, MD, HTML
  - **Audio/Video**: MP4, AVI, MP3, WAV, OGG, AAC
  - **Images**: JPG, PNG, GIF, BMP, TIFF
  - **Spreadsheets**: XLS, XLSX, ODS, CSV
  - **Presentations**: PPT, PPTX, ODP

- **Multiple Interfaces**:
  - Intuitive graphical user interface (GUI)
  - Command-line interface (CLI) for automation

- **Smart Features**:
  - Automatic format detection
  - Intelligent converter selection
  - Batch conversion support
  - Progress tracking
  - Portable mode with bundled tools

## Installation

### Pre-built Packages

1. Download the latest release for your platform from the [Releases](https://github.com/yourusername/universal-file-converter/releases) page

2. Unpack the archive to any location

3. Run the application:
   - **Windows**: Double-click `universal-converter.exe`
   - **macOS**: Open `UniversalConverter.app`
   - **Linux**: Run `./universal-converter`

### From Source

#### Prerequisites

- Python 3.8+
- Dependencies: PyQt6, tqdm, requests

```bash
# Clone the repository
git clone https://github.com/yourusername/universal-file-converter.git
cd universal-file-converter

# Install Python dependencies
pip install -r requirements.txt

# Download required tools
python download_tools.py

# Run the application
python src/main_gui.py
```

## Usage

### Graphical Interface

1. Launch the application
2. Select a file to convert
3. Choose the output format
4. Click "Convert"
5. Optionally save the output to a specific location

### Command Line

The command-line version offers more flexibility for automation:

```bash
# Basic conversion
universal-converter-cli --input example.docx --output-format pdf

# Batch conversion
universal-converter-cli batch-convert --input-dir ./documents --output-format pdf --pattern "*.docx" --pattern "*.odt"

# Check dependencies
universal-converter-cli check-deps
```

## Portable Usage

The application includes a portable mode where conversion tools are bundled with the application:

1. First time setup will download required tools
2. Tools are stored in the `portable_tools` directory
3. Updates can be checked and installed via Settings

## Building from Source

### Windows

```bash
# Run the build script
build_windows.bat
```

### macOS/Linux

```bash
# Make the script executable
chmod +x build_unix.sh

# Run the build script
./build_unix.sh
```

The executable will be available in the `dist/universal-converter` directory.

## Required External Tools

The converter utilizes these external tools:

- **FFmpeg**: For audio and video conversions
- **Pandoc**: For document format conversions
- **LibreOffice**: For office document conversions (DOC, DOCX, XLS, PPT, etc.)

When running in portable mode, these tools will be automatically downloaded as needed.

## License

[MIT License](LICENSE)

## Credits

- [FFmpeg](https://ffmpeg.org/)
- [Pandoc](https://pandoc.org/)
- [LibreOffice](https://www.libreoffice.org/)
- [PyQt](https://www.riverbankcomputing.com/software/pyqt/)