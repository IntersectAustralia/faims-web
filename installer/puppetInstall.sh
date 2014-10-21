#!/bin/bash

APP_ROOT=/var/www/faims

# Update packages
sudo apt-get update

# Install common packages
sudo apt-get -y install git

# Install puppet
sudo apt-get -y install puppet

# Install puppet modules
if [ ! -d "$HOME/.puppet/modules/stdlib" ]; then
    puppet module install puppetlabs-stdlib
fi

if [ ! -d "$HOME/.puppet/modules/apt" ]; then
    puppet module install puppetlabs-apt
fi

# Clone webapp
if [ ! -d "$APP_ROOT" ]; then
    sudo git clone https://github.com/IntersectAustralia/faims-web.git $APP_ROOT
    sudo chown -R $USER:$USER $APP_ROOT
fi

# Configure puppet
sed -i "s/webapp_user:.*/webapp_user: $USER/g" $APP_ROOT/puppet/data/common.yaml

if [ ! -h "/etc/puppet/hiera.yaml" ]; then
    sudo ln -s $APP_ROOT/puppet/hiera.yaml /etc/puppet/hiera.yaml
fi

# Run puppet site.pp
sudo puppet apply --pluginsync $APP_ROOT/puppet/site.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules