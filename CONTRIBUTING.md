# Contributing to the Arduino CI GitHub Action

`ArduinoCI/action` uses a very standard GitHub workflow.

1. Fork the repository on github
2. Make your desired changes on top of the latest `master` branch, document them in [CHANGELOG.md](CHANGELOG.md)
3. Push to your personal fork
4. Open a pull request
    * If you are submitting code, use `master` as the base branch
    * If you are submitting broken unit tests (illustrating a bug that should be fixed), use `tdd` as the base branch.


## Maintaining the Action

* Merge pull request with new features
* `git stash save` (at least before the push step, but easiest here).
* `git pull --rebase`
* Update the sections of `CHANGELOG.md`
* `git add README.md CHANGELOG.md`
* `git commit -m "vVERSION bump"`
* `git tag -a vVERSION -m "Released version VERSION"`
* `git push upstream`
* `git push -f upstream master:latest`
* `git push -f upstream master:stable-1.x`
* `git push upstream --tags`
* `git checkout master`
* `git stash pop`
