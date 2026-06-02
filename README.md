# HandyLinuxUtilities

A collection of small utilities for Linux. This repository includes showenv, a small C program that prints environment variables with colorized output and helpful highlighting.

![Divider](pics/pink.jpg?raw=true "Divider")

## showenv

   ### Usage

   Run the binary:

   ```bash
   ./showenv.pl
   ```

   It will print environment variables to stdout with colored highlights. Use in a terminal that supports ANSI colors.

![Divider](pics/pink.jpg?raw=true "Divider")

## awesome.sh

   ### Usage

   ```bash
   ./awesome.sh
   ```

   This will install the patched "Awesome" source code fonts for terminals.  These fonts have all of the glyphs and graphics characters, as well as a full Unicode set.

   They are really nice and easy to read fonts for coding.

![Divider](pics/pink.jpg?raw=true "Divider")

## cpu_cores.pl

   ### Usage

   For simple core count:

   ```bash
   ./cpu_cores.pl
   ```

   For detailed CPU description:

   ```bash
   ./cpu_cores.pl 1
   ```

   * cpu_cores.py

   ### Usage

   For simple core count:

   ```bash
   ./cpu_cores.py
   ```

   For detailed CPU description:

   ```bash
   ./cpu_cores.py 1
   ```

![Divider](pics/pink.jpg?raw=true "Divider")

## wimip.sh

   Tool to populate WHATISMYIP_INFO environment variable using your whatismyip.com API key (signup is free for personal use).  It works great in the ```/etc/bash.bashrc``` file.

   **showenv.pl** formats the variable on output.

   ### Usage

   ```bash
   export WHATISMYIP_INFO=`wimip [what is my ip key]`
   ```

![Divider](pics/pink.jpg?raw=true "Divider")

## readmd.pl

   Renders markdown file.  Requires "Text::Markdown" and "lynx".

   ### Usage

   ```bash
   readmd.pl [file]
   ```

![Divider](pics/pink.jpg?raw=true "Divider")

## COPYRIGHT

   Copyright © 2020-2026 Richard Kelsch,

   All Rights Reserved

![Divider](pics/pink.jpg?raw=true "Divider")

## LICENSE

### Perl Artistic License 2.0

   This program is free software; you can redistribute it and/or modify it under the terms of the the Artistic License (2.0). You may obtain a copy of the full license at:

[http://www.perlfoundation.org/artistic_license_2_0](http://www.perlfoundation.org/artistic_license_2_0)

![Divider](pics/pink.jpg?raw=true "Divider")

## Author

   Richard Kelsch <rich@rk-internet.com>
