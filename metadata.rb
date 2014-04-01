name             'bb-db'
maintainer       'Rackspace, hosting inc'
maintainer_email 'nielsen.pierce@rackspace.co.uk'
license          'All rights reserved'
description      'Installs/Configures bb-db'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "rackspace_mysql"
depends "rackspace_apt"
depends "rackspace_iptables"
depends "cron"

