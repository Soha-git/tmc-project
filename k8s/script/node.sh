#!/bin/bash
rsync -av -e "ssh -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa" vagrant@10.10.0.10:/home/vagrant/join.sh /home/vagrant/

/bin/bash /home/vagrant/join.sh -v

rm -R /home/vagrant/.ssh/id_rsa