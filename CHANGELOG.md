# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2020-02-21
### Changed
- Mix tasks internal templates paths
## [0.4.1] - 2020-02-21
### Added
- Entrance.User.create!/2 function
## [0.4.0] - 2020-02-16
### Added
- Add tests templates for entrance mix tasks
## [0.3.2] - 2020-02-15
### Changed
- Entrance.User.changeset to Entrance.User.create_changeset
- Sets create_changeset nomenclature as default to create user actions
- Docs and readme updates
## [0.3.1] - 2020-02-15
### Added
- Entrance.User
- Mix tasks (gen.user_controller, gen.session_controller, gen.require_login, gen.modules)
## [0.3.0] - 2020-01-31
### Added
- Entrance.auth_one/3
- Entrance.auth_one_by/4
- Our logo :)
### Changed
- Some code and documentation refactor
## [0.2.0] - 2020-01-24
### Added
- default_authenticable_field. Now it's possible to set any user schema field to be the default_authenticable_field in Entrance.auth/3 function
- Entrance.auth_by/3 function. Now it's possible to authenticate using more than one field of user schema
### Changed
- Functions nomenclature from "authenticate" to "auth"
- Do some code refactors
- Make the Mix.Config nomenclature to a more legible.

## [0.1.0] - 2020-01-23
### Added
- Firt version of the project in GitHub repository 
### Changed
- Update the source code of [Doorman](https://github.com/BlakeWilliams/doorman) with the last versions of dependencies, remove deprecations and ajust tests.









