## Setup

1. Edit hosts.ini
2. Edit vars.yml
3. Edit host_vars/*
4. Edit group_vars/*

`ansible-playbook -i hosts.ini --ask-pass setup.yml`

`ansible-playbook -i hosts.ini provision.yml`

## Notes

* systemd: https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal
