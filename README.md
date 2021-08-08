# Space Radar

## Description

A Ruby application that takes an ASCII radar sample as an argument and reveals possible locations of invaders space ships.

## Installation

```bash
bundle install
```

## Show help

```bash
bin/space-radar --help
```

## Run with default data

```bash
bin/space-radar
```

## Run with custom data

**Note:** All data files need to have the `txt` extension.

```bash
bin/space-radar --radar-scan-path spath/to/file.txt --known-items-dir-path path/to/folder
```

## Test

```bash
bin/rspec
```
