FROM inossidabile/provisionable

RUN ansible-galaxy install laggyluke.nodejs rvm_io.rvm1-ruby mivok0.users
ADD roles /provisioning/
ADD ansible.yml /provisioning/
ADD ansible.hosts /etc/ansible/hosts
RUN apt-get update
RUN provision

ADD profile/key.pub /root/.ssh/authorized_keys
ADD profile/ssh /root/.profile

CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
