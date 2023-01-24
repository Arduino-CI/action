# Arduino-CI GitHub Action

This repository is for the **GitHub Action** to run [`arduino_ci`](https://github.com/Arduino-CI/arduino_ci) on a repository containing an Arduino library.  You can also run it locally with Docker, _right now_, if that's easier -- see below.


## Why You Should Use This Action

- Contributions to your Arduino library are tested automatically, _without_ the need for hardware present
- Example sketches in your `examples/` directory are compiled automatically, to detect broken code in the default branch

### See Also
* [`arduino-lint` action](https://github.com/marketplace/actions/arduino-arduino-lint-action) for verifying metadata (e.g. `library.properties`) and structural aspects of a library

## Adding Arduino CI Pull Request Tests To Your Project

1. Create a new YAML file in your repository's `.github/workflows` directory, e.g. `.github/workflows/arduino_ci.yml`
2. Copy an example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Merge into your default branch to enable testing of all following pull requests


### Configuring a Workflow to Use the GitHub Action

There are several ways to specify what version of the action to run.

Value for `uses:`              | Meaning | Pros | Cons
-------------------------------|---------|------|------
`Arduino-CI/action@v0.1.2`     | exact version | Complete control | Adopt new versions manually, which may be tiresome if you have many libraries
`Arduino-CI/action@latest`     | bleeding-edge unreleased `arduino_ci` version | Receive latest features & fixes automatically | High risk of encountering breaking changes or new bugs
`Arduino-CI/action@stable-1.x` | use highest available `arduino_ci` version that is < `2.0.0` | Receive latest features & fixes automatically, but avoids breaking changes | Not a 100% guarantee against unintended CI changes

Using `Arduino-CI/action@stable-1.x` is **recommended**, so the contents listed below for `.github/workflows/arduino_ci.yml` should work for most users.

```yml
---
name: Arduino_CI

on: [pull_request]

jobs:
  arduino_ci:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: Arduino-CI/action@stable-1.x
```

The full set of configuration options for the action is enumerated here; note that if the `env:` section is empty, it must be commented out or deleted as well.

```yml
---
name: Arduino_CI

on: [pull_request]

jobs:
  arduino_ci:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: Arduino-CI/action@stable-1.x   # or latest, or a pinned version
        env:
          # Not all libraries are in the root directory of a repository.
          # Specifying the path of the library here (relative to the root
          # of the repository) will adjust that.
          #
          # The default is the current directory
          #
          USE_SUBDIR: .

          # Not all libraries include examples or unit tests.  The default
          #  behavior of arduino_ci is to assume that "if the files don't
          #  exist, then they were not MEANT to exist".  In other words,
          #  if you were to accidentally delete all your tests or example
          #  sketches, then the CI runner would by default assume that was
          #  intended and return a passing result.
          #
          # If you'd rather have the test runner fail the test in the
          #  absence of either tests or examples, uncommenting either of
          #  the following variables to 'true' (as appropriate) will
          #  enforce that.
          #
          EXPECT_EXAMPLES: false
          EXPECT_UNITTESTS: false

          # Although dependencies will be installed automatically via the
          # library manager, your library under test may require an
          # unofficial version of a dependency.  In those cases, the custom
          # libraries must be insalled prior to the test execution; those
          # installation commands should be placed in a shell script (that
          # will be executed by /bin/sh) stored in your library.
          #
          # Then, set this variable to the path to that file (relative to
          # the root of your repository).  The script will be run from
          # within the Arduino libraries directory; you should NOT attempt
          # to find that directory nor change to it from within the script.
          #
          # CUSTOM_INIT_SCRIPT: install_dependencies.sh
```

### Status Badges

You can show Arduino CI status with a badge in your repository `README.md`

```markdown
[![Arduino CI](https://github.com/<OWNER>/<REPOSITORY>/workflows/Arduino_CI/badge.svg)](https://github.com/marketplace/actions/arduino_ci)
```

> Note that
> * you must replace `<OWNER>` with your GitHub username
> * you must replace `<REPOSITORY>` with the name of the GitHub repository
> * `Arduino_CI` in the URL must match the `name: Arduino_CI` line in the example YAML files above


## Configuring Behavior of the Arduino CI Test Runner Itself

When configuring the test runner itself, it's more efficient to run `arduino_ci` locally -- it works on the same OSes as the Arduino IDE.  Instructions for setting that up can be found at [the `arduino_ci` project homepage on GitHub](https://github.com/Arduino-CI/arduino_ci).  If you are using OSX or Linux, you have the additional option of running Arduino CI directly from Docker -- see below.


### Writing Unit Tests

For information on Arduino unit testing with `arduino_ci`, see the [`REFERENCE.md` for Arduino CI's section on unit testing](https://github.com/Arduino-CI/arduino_ci/blob/master/REFERENCE.md#writing-unit-tests-in-test)


### Testing Different Arduino Platforms

By default, any unit tests and example sketches are tested against a modest set of Arduino platforms.  If you have architectures defined in `library.properties`, that will further refine the set of what is tested.  You can further override this configuration in several specific ways; for details, see the [`REFERENCE.md` for Arduino CI's section on CI configuration](https://github.com/Arduino-CI/arduino_ci/blob/master/REFERENCE.md#indirectly-overriding-build-behavior-medium-term-use-and-advanced-options)

The default configuration is [available in the `arduino_ci` project](https://github.com/Arduino-CI/arduino_ci/blob/master/misc/default.yml), and shows how the platforms and packages are configured (including 3rd-party board provider information).


## Immediate Usage / Development Workflow using Docker

The same Docker image used by the GitHub action is available for local testing, and should function properly on Linux and OSX hosts with [Docker](https://www.docker.com/products/docker-desktop) installed.  Choose the command that best matches the state of your project, and use the `-


### Your Arduino Libraries directory has everything set up just right; you just want to get up and running and not worry about dependencies at all

Component                               |Path
----------------------------------------|----
Arduino's "libraries" directory         | `/pathTo/Arduino/libraries`
Your library under test, called `mylib` | `/pathTo/Arduino/libraries/mylib`
A custom library `mylib` depends on     | `/pathTo/Arduino/libraries/custom`


In this situation, you've got a mix of libraries installed locally (the one that will be tested amongst any possible dependencies), and they all work as expected (even though you're not quite sure all of them are up to date, nor whether they have local modifications that aren't part of the official library release).  This setup won't work in CI, but by volume-mounting the libraries directory into the container and using your own library as the working directory, you can ensure that arduino_ci is using the _exact_ same set of dependencies.

> This is also the fastest way to test new versions of dependencies.

You would run the following (substituting your own library's name in place of `mylib`):

```bash
docker run --rm \
  -v "/pathTo/Arduino/libraries:/root/Arduino/libraries" \
  --workdir /root/Arduino/libraries/mylib \
  docker.pkg.github.com/arduino-ci/action/ubuntu
```


### Your Arduino Library uses only "official" library versions as dependencies

Component                               |Path
----------------------------------------|----
Arduino's "libraries" directory         | `/pathTo/Arduino/libraries`
Your library under test, called `mylib` | `/pathTo/Arduino/libraries/mylib`

In this situation, the only libraries you need for your library to work are those that you've downloaded directly from the library manager and no special modifications need to be made.  We simply volume mount the library under test into the container, set that directory to be the working directory, and let the `arduino_ci` test runner install the dependencies directly.

If your project does not include a `library.properties` that defines your project's name, you should change `library_under_test` to `mylib`.

```bash
docker run --rm \
  -v "/pathTo/Arduino/libraries/mylib:/library_under_test" \
  --workdir /library_under_test \
  docker.pkg.github.com/arduino-ci/action/ubuntu
```


### Your Arduino Library uses libraries or versions as dependencies that can't be installed by name from the Arduino library manager (but you wrote a script to install them automatically)

Component                                |Path
-----------------------------------------|----
Arduino's "libraries" directory          | `/pathTo/Arduino/libraries`
Your library under test, called `mylib`  | `/pathTo/Arduino/libraries/mylib`
Shell script to install `custom` library | `/pathTo/Arduino/libraries/mylib/install.sh`
A custom library `mylib` depends on      | `/pathTo/Arduino/libraries/custom`

In this situation, you have a custom library that can't be installed by the library manager.  Fortunately, you've supplied an `install.sh` script that will download and unpack a library to the current working directory (which Arduino CI's test runner will run from inside the container's Arduino libraries directory).  Note the _relative_ path used for `install.sh`.

```bash
docker run --rm \
  -v "/pathTo/Arduino/libraries/mylib:/library_under_test" \
  --workdir /library_under_test \
  --env CUSTOM_INIT_SCRIPT=install.sh \
  docker.pkg.github.com/arduino-ci/action/ubuntu
```


### Your Arduino Library is a subdirectory of a monorepo, you need libraries or versions as dependencies that can't be installed by name from the Arduino library manager, you wrote a script to install them automatically

Component                                |Path
-----------------------------------------|----
Arduino's "libraries" directory          | `/pathTo/Arduino/libraries`
A custom library `mylib` depends on      | `/pathTo/Arduino/libraries/custom`
Your library under test, called `mylib`  | `/pathTo/Monorepo/mylib`
Shell script to install `custom` library | `/pathTo/Monorepo/mylib/install.sh`


All the bells and whistles.  Note that the relative path of `install.sh` is considered _after_ the `USE_SUBDIR` directory has been applied.

```bash
docker run --rm \
  -v "/pathTo/Monorepo:/library_under_test" \
  --workdir /library_under_test \
  --env USE_SUBDIR=mylib \
  --env CUSTOM_INIT_SCRIPT=install.sh \
  docker.pkg.github.com/arduino-ci/action/ubuntu
```
