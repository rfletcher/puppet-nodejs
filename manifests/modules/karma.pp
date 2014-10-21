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
}
