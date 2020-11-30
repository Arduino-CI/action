# Arduino-CI GitHub Action

This repository is for the **GitHub Action** to run [`arduino_ci`](https://github.com/Arduino-CI/arduino_ci) on a repository containing an Arduino library.

## Why you should use this action

- Contributions to your Arduino library are tested automatically, _without_ the need for hardware present
- Example sketches in your `examples/` directory are compiled automatically, to detect broken code in the default branch

## Enabling it on your own project

1. Create a new file in your repository called `.github/workflows/arduino_ci.yml`
2. Copy the example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Merge into your default branch to enable testing of all following pull requests

Contents of `.github/workflows/arduino_ci.yml`

```yml
---
name: Arduino CI

on: [push, pull_request]

jobs:
  arduino_ci:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - uses: Arduino-CI/action@0.1.0
```

### Add badge in your repository README

You can show Super-Linter status with a badge in your repository README

```markdown
[![Arduino CI](https://github.com/<OWNER>/<REPOSITORY>/workflows/Arduino%20CI/badge.svg)](https://github.com/marketplace/actions/arduino_ci)
```

> Note that `Arduino%20CI` in the URL matches the `name: Arduino CI` line in the YAML file above
