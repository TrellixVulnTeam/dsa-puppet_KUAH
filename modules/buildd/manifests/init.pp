class buildd {
    package {
        "schroot": ensure => installed;
        "sbuild": ensure => installed;
        "buildd": ensure => installed;
        "buildd-builder-meta": ensure => installed;
        "apt-transport-https": ensure => installed;
        "debootstrap": ensure => installed;
        "dupload": ensure => installed;
    }
   
    file {
        "/etc/apt/preferences.d/buildd":
             source  => "puppet:///modules/buildd/apt-preferences",
             ;

        "/etc/apt/sources.list.d/buildd.list":
             content => template("buildd/etc/apt/sources.list.d/buildd.list.erb"),
             require => Package["apt-transport-https"],
             notify  => Exec["apt-get update"],
             ;
       
        "/etc/apt/trusted-keys.d/buildd.debian.org.asc":
             source  => "puppet:///modules/buildd/buildd.debian.org.asc",
             mode    => 664,
             notify  => Exec["apt-keys-update"],
             ;
        "/etc/schroot/mount-defaults":
             content => template("buildd/etc/schroot/mount-defaults.erb"),
             require => Package["sbuild"]
             ;
        "/etc/cron.d/dsa-buildd":
             source => "puppet:///modules/buildd/cron.d-dsa-buildd",
             require => Package["debian.org"]
             ;
        "/etc/dupload.conf":
             source => "puppet:///modules/buildd/dupload.conf",
             require => Package["dupload"]
             ;
        "/etc/default/schroot":
             source => "puppet:///modules/buildd/default-schroot",
             require => Package["schroot"]
             ;
    }

    case $kernel {
        Linux: { linux_module { "dm_snapshot": ensure => present; } }
    }

}
# vim:set et:
# vim:set sts=4 ts=4:
# vim:set shiftwidth=4:
