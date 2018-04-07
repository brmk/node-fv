# FormVision [![NPM version](https://badge.fury.io/js/nfv.png)](http://badge.fury.io/js/nfv) [![Dependency Status](https://david-dm.org/brmk/node-fv.png)](https://david-dm.org/brmk/node-fv) [![devDependency Status](https://david-dm.org/brmk/node-fv/dev-status.png)](https://david-dm.org/brmk/node-fv#info=devDependencies)

THE ORIGINAL REPO IS https://github.com/creatale/node-fv. But it has an outdated dv dependency, so as a temporary working solution, I published this module to allow using this package with an updated dependency.

FormVision is a [node.js](http://nodejs.org) library for extracting data from scanned forms.

## Features

- Extract text, barcodes and checkboxes from images
- Specify expected region, type and validation for each field
- Supports incorporation of domain specific knowledge (wrong place, right data)
- Supports multiple transformations (half printed, half written, different offsets)
- Meant to cut red tape!

## Installation

    $ npm install nfv

## Quick Start

Install `nfv`, download [that image](https://github.com/creatale/node-fv/blob/master/test/data/m10-printed.png) and [that schema](https://github.com/creatale/node-fv/blob/master/test/data/m10-schema.json). Now run the command-line interface:

- Print raw data extracted from image (without matching).
    ```
coffee bin/cli.coffee --remove-red --lang=deu m10-printed.png
    ```

- Print form data extracted from image using the specified schema (with matching).
    ```
coffee bin/cli.coffee --remove-red --lang=deu --schema=m10-schema.json m10-printed.png
    ```

## What's next?

Here are some quick links to help you get started:

- [API Reference](https://github.com/creatale/node-fv/wiki/API)
- [Bug Tracker](https://github.com/creatale/node-fv/issues)

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT License](http://creativecommons.org/licenses/MIT/). Copyright &copy; 2013-2014 Christoph Schulz.
Dependencies may be licensed differently.
