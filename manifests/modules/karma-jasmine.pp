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
class nodejs::modules::karma-jasmine (
  $ensure = present,
) {
  include ::nodejs

  package { 'karma-jasmine':
    ensure   => $ensure,
    provider => 'npm',
    require  => Class['::nodejs'],
  }
}
