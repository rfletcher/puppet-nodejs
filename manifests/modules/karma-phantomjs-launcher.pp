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
class nodejs::modules::karma-phantomjs-launcher (
  $ensure = present,
) {
  include ::nodejs

  package { 'karma-phantomjs-launcher':
    ensure   => $ensure,
    provider => 'npm',
    require  => Class['::nodejs'],
  }  
}
