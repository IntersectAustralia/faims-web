#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    error "This script should not be run using sudo or as the root user"
    exit 1
fi

APP_ROOT=/var/www/faims

# Update packages
sudo apt-get update

# Install common packages
sudo apt-get -y install git puppet libreadline-dev

# Install puppet modules
if [ ! -d "$HOME/.puppet/modules/stdlib" ]; then
    puppet module install puppetlabs-stdlib
fi

if [ ! -d "$HOME/.puppet/modules/apt" ]; then
    puppet module install puppetlabs-apt
fi

if [ ! -d "$HOME/.puppet/modules/vcsrepo" ]; then
    puppet module install puppetlabs-vcsrepo
fi

# Clone webapp
if [ ! -d "$APP_ROOT" ]; then
    sudo git clone https://github.com/IntersectAustralia/faims-web.git $APP_ROOT
    sudo chown -R $USER:$USER $APP_ROOT
    cd $APP_ROOT && git checkout production
fi

if [ ! -h "/etc/puppet/hiera.yaml" ]; then
    sudo ln -s $APP_ROOT/puppet/hiera.yaml /etc/puppet/hiera.yaml
fi

# Configure puppet
sed -i "s/webapp_user:.*/webapp_user: $USER/g" $APP_ROOT/puppet/data/common.yaml

# Update repo
sudo puppet apply --pluginsync $APP_ROOT/puppet/repo.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules

# Update server
sudo puppet apply --pluginsync $APP_ROOT/puppet/update.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules

# Restart services
sudo puppet apply --pluginsync $APP_ROOT/puppet/restart.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules
