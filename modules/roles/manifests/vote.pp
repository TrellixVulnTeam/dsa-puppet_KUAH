class roles::vote {
	ssl::service { 'vote.debian.org':
		notify  => Exec['service apache2 reload'],
		tlsaport => 0,
	}
}
