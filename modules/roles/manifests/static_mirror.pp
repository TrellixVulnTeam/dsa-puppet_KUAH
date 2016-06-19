class roles::static_mirror {

	include roles::static_source
	include apache2::cache

	package { 'libapache2-mod-geoip': ensure => installed, }
	package { 'geoip-database': ensure => installed, }

	include apache2::ssl
	apache2::module { 'include': }
	apache2::module { 'geoip': require => [Package['libapache2-mod-geoip'], Package['geoip-database']]; }

	file { '/usr/local/bin/static-mirror-run':
		source => 'puppet:///modules/roles/static-mirroring/static-mirror-run',
		mode   => '0555',
	}

	file { '/usr/local/bin/static-mirror-run-all':
		source => 'puppet:///modules/roles/static-mirroring/static-mirror-run-all',
		mode   => '0555',
	}

	file { '/srv/static.debian.org':
		ensure => directory,
		owner  => staticsync,
		group  => staticsync,
		mode   => '02755'
	}

	file { '/etc/cron.d/puppet-static-mirror':
			content => "MAILTO=root\nPATH=/usr/local/bin:/usr/bin:/bin\n@reboot staticsync sleep 60; chronic static-mirror-run-all\n",
	}

	$vhost_listen = $::hostname ? {
		klecker    => '130.89.148.14:80 [2001:610:1908:b000::148:14]:80',
		mirror-isc => '149.20.20.22:80 [2001:4f8:8:36::1deb:22]:80',
		mirror-anu => '150.203.164.62:80 [2001:388:1034:2900::3e]:80',
		default    => '*:80',
	}
	$vhost_listen_443 = $::hostname ? {
		klecker    => '130.89.148.14:443 [2001:610:1908:b000::148:14]:443',
		mirror-isc => '149.20.20.22:443 [2001:4f8:8:36::1deb:22]:443',
		mirror-anu => '150.203.164.62:443 [2001:388:1034:2900::3e]:443',
		default    => '*:443',
	}

	apache2::config { 'local-static-vhost.conf':
		content => template('roles/static-mirroring/static-vhost.conf.erb'),
	}

	apache2::site { '010-planet.debian.org':
		site    => 'planet.debian.org',
		ensure  => has_static_component('planet.debian.org') ? { true => "present", false => "absent" },
		content => template('roles/static-mirroring/vhost/planet.debian.org.erb'),
	}

	apache2::site { '010-lintian.debian.org':
		site    => 'lintian.debian.org',
		ensure  => has_static_component('lintian.debian.org') ? { true => "present", false => "absent" },
		content => template('roles/static-mirroring/vhost/lintian.debian.org.erb'),
	}

	apache2::site { '010-static-vhosts-simple':
		site => 'static-vhosts-simple',
		content => template('roles/static-mirroring/vhost/static-vhosts-simple.erb'),
	}

	$wwwdo_document_root = '/srv/static.debian.org/mirrors/www.debian.org/cur'
	apache2::site { '005-www.debian.org':
		site   => 'www.debian.org',
		ensure  => has_static_component('www.debian.org') ? { true => "present", false => "absent" },
		content => template('roles/apache-www.debian.org.erb'),
	}

	ssl::service { 'dsa.debian.org'      : ensure => "ifstatic", notify => Service['apache2'], }
	ssl::service { 'www.debian.org'      : ensure => "ifstatic", notify => Service['apache2'], }
	ssl::service { 'bits.debian.org'     : ensure => "ifstatic", notify => Service['apache2'], }
	ssl::service { 'lintian.debian.org'  : ensure => "ifstatic", notify => Service['apache2'], }
	ssl::service { 'rtc.debian.org'      : ensure => "ifstatic", notify => Service['apache2'], }
	ssl::service { 'appstream.debian.org': ensure => "ifstatic", notify => Service['apache2'], }
	ssl::service { 'd-i.debian.org'      : ensure => "ifstatic", notify => Service['apache2'], }

	# do
	ssl::service { 'backports.debian.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'www.ports.debian.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	# dn
	ssl::service { 'news.debian.net'               : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debaday.debian.net'            : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'timeline.debian.net'           : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	# dc
	ssl::service { 'debconf0.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf1.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf2.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf3.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf4.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf5.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf6.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'debconf7.debconf.org'          : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { '10years.debconf.org'           : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'es.debconf.org'                : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'fr.debconf.org'                : ensure => "ifstatic", notify => Service['apache2'], key => true, }
	ssl::service { 'miniconf10.debconf.org'        : ensure => "ifstatic", notify => Service['apache2'], key => true, }
}
