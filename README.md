# Morse Code Audio to Words Converter

This project is a tool to convert Morse code audio signals into readable words. It utilizes OCAML for its functional programming capabilities, ffmpeg for audio processing, and the Core library for efficient data manipulation.

## Installation

1. **OCAML**: If you haven't installed OCAML yet, you can do so by following the instructions on [OCAML's official website](https://ocaml.org/docs/install.html).

2. **FFmpeg**: You'll need FFmpeg installed on your system. You can download it from [the official FFmpeg website](https://ffmpeg.org/download.html) or install it via your package manager if you're on a Unix-like system.

3. **Core Library**: The Core library is a part of the Jane Street's ecosystem. You can install it via OPAM:

   ```bash
   opam install core
   ```

4. **Dune**: You will need dune installed on your system as well to build and execute the project.

## Usage

1. Clone the repository
2. Build the project

   ```bash
   dune build
   ```

3. Execute the project

   ```bash
   dune exec morse_code_translator
   ```

## Configuration

There are two input files given in the input folder in the repository. They have extension .wav. You can upload and test the program using your own audio files as well. I built the program and tested it using the following website, which allows you to download the audio files, with the following settings:

https://www.meridianoutpost.com/resources/etools/calculators/calculator-morse-code.php?

```
7 WPM, 1000 Hz
```

Feel free to visit the website above and download your own audio files to test!

To change which audio file the program will run, change the filepath in line 121:

```
  let _ = run_command "ffmpeg -i FILE_PATH_GOES_HERE -af \"silencedetect=noise=-30dB:d=0.01\" -f null - 2> input/silencedetect_output.txt" in
```

**TO-DO**: Test the program with audio files from other sources. Develop the program so that it can dynamically adjust to different WPM/Hz rates. Clean up the code a little bit.
