# puppet: types/providers for Puppet files for Puppet

[![License](https://img.shields.io/github/license/voxpupuli/puppet-augeasproviders_puppet.svg)](https://github.com/voxpupuli/puppet-augeasproviders_puppet/blob/master/LICENSE)
[![Puppet Forge Version](http://img.shields.io/puppetforge/v/puppet/augeasproviders_puppet.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_puppet)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppet/augeasproviders_puppet.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_puppet)
[![Build Status](https://github.com/voxpupuli/puppet-augeasproviders_puppet/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_puppet/actions?query=workflow%3ACI)
[![Donated by Herculesteam](https://img.shields.io/badge/donated%20by-herculesteam-fb7047.svg)](#transfer-notice)

This module provides a new type/provider for Puppet to read and modify Puppet
config files using the Augeas configuration library.

The advantage of using Augeas over the default Puppet `parsedfile`
implementations is that Augeas will go to great lengths to preserve file
formatting and comments, while also failing safely when needed.

This provider will hide *all* of the Augeas commands etc., you don't need to
know anything about Augeas to make use of it.

## Requirements

Ensure both Augeas and ruby-augeas 0.3.0+ bindings are installed and working as
normal.

See [Puppet/Augeas pre-requisites](http://docs.puppetlabs.com/guides/augeas.html#pre-requisites).

## Installing

On Puppet 2.7.14+, the module can be installed easily ([documentation](http://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)):

    puppet module install herculesteam/augeasproviders_puppet

You may see an error similar to this on Puppet 2.x ([#13858](http://projects.puppetlabs.com/issues/13858)):

    Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type `puppet_auth` at ...

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Compatibility

### Puppet versions

Minimum of Puppet 2.7.

### Augeas versions

Augeas Versions           | 0.10.0  | 1.0.0   | 1.1.0   | 1.2.0   |
:-------------------------|:-------:|:-------:|:-------:|:-------:|
**PROVIDERS**             |
puppet\_auth              | **yes** | **yes** | **yes** | **yes** |

## Documentation and examples

Type documentation can be generated with `puppet doc -r type` or viewed on the
[Puppet Forge page](http://forge.puppetlabs.com/herculesteam/augeasproviders_puppet).


### puppet_auth provider

This is a custom type and provider supplied by `augeasproviders`.

It requires the `Puppet_Auth.lns` lens, which is provided with versions of Augeas strictly greater than 0.10.0.

#### manage simple entry

    puppet_auth { 'Deny /facts':
      ensure        => present,
      path          => '/facts',
      authenticated => 'any',
    }

#### manage regex entry

    puppet_auth { 'Deny ~ ^/facts/([^/]+)$':
      ensure        => present,
      path          => '^/facts/([^/]+)$',
      path_regex    => true,
      authenticated => 'any',
    }

#### add multiple environments

    puppet_auth { 'Allow /facts for prod and dev environments from same client':
      ensure        => present,
      path          => '/facts',
      authenticated => 'any',
      allow         => '$1',
      environments  => ['prod', 'dev'],
    }

#### ensure an entry is before a given path

`ins_after` provides the opposite functionality, so an entry is created after a
given path.

    puppet_auth { 'Allow /facts before first denied rule':
      ensure        => present,
      path          => '/facts',
      authenticated => 'any',
      allow         => '*',
      ins_before    => 'first deny',
    }

#### delete entry

    puppet_auth { 'Remove /facts':
      ensure => absent,
      path   => '/facts',
    }

## Issues

Please file any issues or suggestions [on GitHub](https://github.com/hercules-team/augeasproviders_puppet/issues).

## Supported OS

See [metadata.json](metadata.json) for supported OS versions.

## Dependencies

See [metadata.json](metadata.json) for dependencies.

## Puppet

The supported Puppet versions are listed in the [metadata.json](metadata.json)

## REFERENCES

Please see [REFERENCE.md](https://github.com/voxpupuli/puppet-augeasproviders_puppet/blob/master/REFERENCE.md) for more details.

## Contributing

Please report bugs and feature request using [GitHub issue tracker](https://github.com/voxpupuli/puppet-augeasproviders_puppet/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/puppetlabs/puppet-lint/) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](https://www.puppet.com/docs/puppet/latest/style_guide.html).

## Transfer Notice

This plugin was originally authored by [Hercules Team](https://github.com/hercules-team).
The maintainer preferred that Puppet Community take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of Hercules Team.
