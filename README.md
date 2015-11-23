# EUC Portal

## Provisioning

The provisioning is done with [Ansible](http://docs.ansible.com).

### Prerequisites

Make sure you have Ansible [installed](http://docs.ansible.com/intro_installation.html). Then install the following Galaxy Roles:

```
sudo ansible-galaxy install laggyluke.nodejs rvm_io.rvm1-ruby mivok0.users DavidWittman.redis ANXS.postgresql MichaelRigart.passenger-nginx
```

For every server that is configured for staging/production you have to have a key-based access to the root user.

### Running

The root playbook is located at `provision/ansible.yml`. Inventory files are located at `provision/ansible.hosts.stage` and `provision/ansible.hosts.production`. They contain actual list of servers that provisioning will run onto. Whenever servers are changed make sure to also update Capistrano deployment configuration.

To provision staging servers run:

```
./bin/provision_staging
```

To provision production servers run:

```
./bin/provision_production
```

## Deployment

Deployment is done with [Capistrano](https://github.com/capistrano/capistrano) and is configured to run seamlessly on provisioned servers. 

To deploy to staging servers run:

```
bundle exec cap staging deploy
```

To deploy to production servers run:

```
bundle exec cap production deploy
```

## Design notes

### Adding service column

Service status columns are designed to be set to `provisioning` by default. They are then overriden by state machine to be set to `deprovisioned` unless available. It means that when you add new `*_status` column it has to be added with the default value equal to `deprovisioned` (-1) and after that the default value has to be changed to 0. Then existing customers will properly default to not having the service while new customers will be arranged by state machine.