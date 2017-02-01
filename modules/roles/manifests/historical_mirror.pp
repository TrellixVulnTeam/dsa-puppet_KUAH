class roles::historical_mirror {
	include apache2::expires

	$vhost_listen = $::hostname ? {
		default => '*:80',
	}
	$onion_v4_addr = $::hostname ? {
		default    => undef,
	}
	$archive_root = $::hostname ? {
		default    => '/srv/mirrors/debian-archive',
	}

	apache2::site { '010-archive.debian.org':
		site   => 'archive.debian.org',
		content => template('roles/apache-archive.debian.org.erb'),
	}

	if has_role('historical_mirror_onion') {
		if ! $onion_v4_addr {
			fail("Do not have an onion_v4_addr set for $::hostname.")
		}

		onion::service { 'archive.debian.org':
			port => 80,
			target_port => 80,
			target_address => $onion_v4_addr,
		}
	}
}
