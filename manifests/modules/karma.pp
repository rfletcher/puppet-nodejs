# Class: nodejs::modules::karma
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Usage:
#
class nodejs::modules::karma (
  $ensure = present,
) {
  include ::nodejs

  package { 'karma':
    ensure   => $ensure,
    provider => 'npm',
    require  => Class['::nodejs'],
  }

  # annoyingly, karma doesn't link itself into the path like other npm modules
  if $ensure == 'present' {
    file { '/usr/bin/karma':
      ensure  => link,
      target  => '/usr/lib/node_modules/karma/bin/karma',
      require => Package['karma'],
    }
  } else {
    file { '/usr/bin/karma':
      ensure => $ensure,
    }
  }
}
