<p align="center">
  <img src="assets/logo.png" alt="amnesia logo" width="200">
</p>

# amnesia

A brainfuck compiler written in x86_64 assembly.

## Install

Requires `nasm` and `ld` (GNU linker).

```sh
git clone https://github.com/IdanKoblik/amnesia.git
cd amenasia
make
```

This produces the `amn` binary in the project root.

## Usage

```sh
./amn <file.bf>
```

Example:

```sh
./amn fixtures/hello.bf
```

The compiler translates the brainfuck source into x86_64 assembly, pipes it through `gcc`, and produces an `out.bin` executable in the current directory.
