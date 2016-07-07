# Class: nodejs::modules::jshint
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Usage:
#
class nodejs::modules::jshint (
  $ensure = present,
) {
  include ::nodejs

  package { 'jshint':
    ensure   => $ensure,
    provider => 'npm',
    require  => Class['::nodejs'],
  }
}
