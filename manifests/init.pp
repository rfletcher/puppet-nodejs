# Class: nodejs
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Usage:
#
class nodejs(
  $manage_repo = false,
  $proxy       = '',
  $version     = 'present'
) inherits nodejs::params {
  #input validation
  validate_bool($manage_repo)

  $release_line = $version ? {
    /^7/    => '7.x',
    default => '6.x',
  }

  case $::operatingsystem {
    'Debian': {
      if $manage_repo {
        #only add apt source if we're managing the repo
        include 'apt'
        apt::source { 'sid':
          location    => 'http://ftp.us.debian.org/debian/',
          release     => 'sid',
          repos       => 'main',
          pin         => 100,
          include_src => false,
          before      => Anchor['nodejs::repo'],
        }

        Class['apt::update'] -> Package['nodejs']
      }
    }

    'Ubuntu': {
      if $manage_repo {
        # Only add apt source if we're managing the repo
        include 'apt'

        ::apt::key { '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280':
          source => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
        } ->

        ::apt::pin { 'nodejs':
          originator => "Node Source",
          priority   => 600,
        } ->

        ::apt::source { 'nodejs':
          location => "https://deb.nodesource.com/node_${release_line}",
        }

        Class['apt::update'] -> Package['nodejs']
      }
    }

    'Fedora', 'RedHat', 'Scientific', 'CentOS', 'OEL', 'OracleLinux', 'Amazon': {
      if $manage_repo {
        package { 'nodejs-stable-release':
          ensure => absent,
          before => Yumrepo['nodejs-stable'],
        }
        yumrepo { 'nodejs-stable':
          descr    => 'Stable releases of Node.js',
          baseurl  => $nodejs::params::baseurl,
          enabled  => 1,
          gpgcheck => $nodejs::params::gpgcheck,
          gpgkey   => 'http://patches.fedorapeople.org/oldnode/stable/RPM-GPG-KEY-tchol',
          before   => Anchor['nodejs::repo'],
        }
        file {'nodejs_repofile':
          ensure  => 'file',
          before  => Anchor['nodejs::repo'],
          group   => 'root',
          mode    => '0444',
          owner   => 'root',
          path    => '/etc/yum.repos.d/nodejs-stable.repo',
          require => Yumrepo['nodejs-stable']
        }
      }
    }

    'Gentoo': {
      # Gentoo does not need any special repos for nodejs
    }

    default: {
      fail("Class nodejs does not support ${::operatingsystem}")
    }
  }

  # anchor resource provides a consistent dependency for prereq.
  anchor { 'nodejs::repo': }

  package { 'nodejs':
    name    => $nodejs::params::node_pkg,
    ensure  => $version,
    require => Anchor['nodejs::repo']
  }

  case $::operatingsystem {
    'Ubuntu': {
      # The PPA we are using on Ubuntu includes NPM in the nodejs package, hence
      # we must not install it separately
      $manage_npm_package = $::lsbdistcodename ? {
        'trusty' => false,
        default  => $manage_repo ? { false => true, default => false },
      }
    }

    'Gentoo': {
      $manage_npm_package = false

      # Gentoo installes npm with the nodejs package when configured properly.
      # We use the gentoo/portage module since it is expected to be
      # available on all gentoo installs.
      package_use { $nodejs::params::node_pkg:
        ensure  => present,
        use     => 'npm',
        require => Anchor['nodejs::repo'],
      }
    }

    default: {
      $manage_npm_package = true
    }
  }

  if $manage_npm_package {
    package { 'npm':
      name    => $nodejs::params::npm_pkg,
      ensure  => present,
      require => [
        Anchor['nodejs::repo'],
        Package['nodejs'],
      ],
    }
  }

  if $proxy {
    exec { 'npm_proxy':
      command => "npm config set proxy ${proxy}",
      path    => $::path,
      require => Package['npm'],
    }
  }
}
