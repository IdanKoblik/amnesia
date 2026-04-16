<p align="center">
  <img src="assets/logo.png" alt="amnesia logo" width="200">
</p>

# amnesia

A brainfuck compiler written in x86_64 assembly.

> **Status:** In development. For now, `amenasia` translates brainfuck source into x86_64 assembly and prints the result to stdout.

## Install

Requires `nasm` and `ld` (GNU linker).

```sh
git clone https://github.com/IdanKoblik/amenasia.git
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

The generated assembly is written to stdout. Redirect it to a file to assemble it further:

```sh
./amn fixtures/hello.bf > hello.asm
```
