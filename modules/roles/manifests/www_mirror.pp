class roles::www_mirror {

	apache2::site { '010-www.debian.org':
		site   => 'www.debian.org',
		source => 'puppet:///modules/roles/www_mirror/www.debian.org',
	}
}
