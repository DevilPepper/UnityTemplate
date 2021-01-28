# Unity Template for Github

This project template follows the tutorials from [GameCI](https://game.ci/docs) using the simple example (one platform) and a Personal License.

## How to use

- Clone this repo and `git reset --hard 0.0.0`.

> commits after tag `0.0.0` add this readme and a dummy project to have a successful build

- Create Unity project in this directory
- Change these settings if needed (in Edit -> Project Settings):
  - Version Control -> Mode: **Visible Meta Files** (Should be default)
  - Editor -> Asset Serialization -> Mode: **Force Text** (Should be default)
  - Player -> Resolution and Presentation -> Run In Background: **Checked** (Test step toggles this on for some reason and build step fails if that's a change because the working directory is dirty...)

### Activate License

You also need to activate a Unity license once to use this.
Go to `Github` > `<Your repository>` > `Actions` > `Acquire activation file (One time per repo)`
and run this workflow. Once it's done, follow these steps:

> Copied from <https://game.ci/docs/github/activation>

- Download the manual activation file that now appeared as an artifact.
- Visit [license.unity3d.com](https://license.unity3d.com/manual) and upload it.
- You should now receive your license file (Unity_v20XX.x.ulf) as a download.
- Open `Github` > `<Your repository>` > `Settings` > `Secrets`.
- Create a secret called `UNITY_LICENSE` and copy the contents your license file into it.

## Limitations

1. To use GameCI for Unity version > 2019.2, this template uses GameCI actions that are still in alpha. This is probably why Test and Build steps build a new Docker image every time...
2. Test step takes forever even with 0 tests! This is probably due to it downloading assets, which should probably be done in a previous step.
3. Due to the long duration of the main workflow you probably don't want to run this in PR, especially during a game jam.
