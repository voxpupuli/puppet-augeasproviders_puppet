[![Puppet Forge Version](http://img.shields.io/puppetforge/v/herculesteam/augeasproviders_puppet.svg)](https://forge.puppetlabs.com/herculesteam/augeasproviders_puppet)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/herculesteam/augeasproviders_puppet.svg)](https://forge.puppetlabs.com/herculesteam/augeasproviders_puppet)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/herculesteam/augeasproviders_puppet.svg)](https://forge.puppetlabs.com/herculesteam/augeasproviders_puppet)
[![Build Status](https://img.shields.io/travis/hercules-team/augeasproviders_puppet/master.svg)](https://travis-ci.org/hercules-team/augeasproviders_puppet)
[![Coverage Status](https://img.shields.io/coveralls/hercules-team/augeasproviders_puppet.svg)](https://coveralls.io/r/hercules-team/augeasproviders_puppet)
[![Gemnasium](https://img.shields.io/gemnasium/hercules-team/augeasproviders_puppet.svg)](https://gemnasium.com/hercules-team/augeasproviders_puppet)


# puppet: types/providers for Puppet files for Puppet

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
