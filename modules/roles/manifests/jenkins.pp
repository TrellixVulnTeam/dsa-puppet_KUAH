class roles::jenkins {
	apache2::module { 'ssl': }
	apache2::module { 'proxy_http': }

	apache2::site { '010-jenkins.debian.org':
		site    => 'jenkins.debian.org',
		source => 'puppet:///modules/roles/jenkins/jenkins.debian.org',
	}

	ssl::service { 'jenkins.debian.org':
		notify => Service['apache2'],
	}
}
