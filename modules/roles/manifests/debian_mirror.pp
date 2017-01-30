class roles::debian_mirror {
	$vhost_listen = $::hostname ? {
		klecker    => '130.89.148.12:80 2001:610:1908:b000::148:12:80',
		mirror-isc => '149.20.4.15:80 [2001:4f8:1:c::15]:80',
		default => '*:80',
	}
	$onion_v4_addr = $::hostname ? {
		bilbao     => '5.153.231.37',
		klecker    => '130.89.148.12',
		mirror-isc => '149.20.4.15',
		default    => undef,
	}
	$archive_root = $::hostname ? {
		default    => '/srv/mirrors/debian,
	}

	apache2::site { '010-ftp.debian.org':
		site   => 'ftp.debian.org',
		content => template('roles/apache-ftp.debian.org.erb'),
	}

	if has_role('debian_mirror_onion') {
		if ! $onion_v4_addr {
			fail("Do not have an onion_v4_addr set for $::hostname.")
		}

		onion::service { 'ftp.debian.org':
			port => 80,
			target_port => 80,
			target_address => $onion_v4_addr,
		}
	}
}
