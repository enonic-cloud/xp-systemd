<h1>Enonic XP systemd setup</h1>

- [Tested with](#tested-with)
- [Explanation of the setup](#explanation-of-the-setup)
- [Using ansible-playbook](#using-ansible-playbook)
- [Using sh script](#using-sh-script)
- [Testing with vagrant](#testing-with-vagrant)

## Tested with

| Linux distro   | Verified it works  |
| -------------- | ------------------ |
| Ubuntu 20.04   | :white_check_mark: |
| Amazon Linux 2 | :white_check_mark: |

## Explanation of the setup

What we want to achieve to setup XP with systemd, that is easy to install, upgrade, rollback and backup. These examples do the following:

1. Set correct `vm.max_map_count`.
2. Create a user and group for XP.
3. Download and extract the desired disto into `/opt/enonic/distros`.
4. Setup the XP home folder at `/opt/enonic/home`.
5. Create a systemd service file using the desired distro.
6. Start systemd service (ansible only).

## Using ansible-playbook

Use ansible playbook:

```console
$ ansible-playbook -i <INVENTORY> xp-systemd.yml
```

## Using sh script

You can use the sh script. First copy the script to the server and then run as root:

```console
$ ./xp-systemd.sh
$ systemctl daemon-reload
$ systemctl enable --now xp.service
```

## Testing with vagrant

Vagrant will automatically provision the systemd service when you create

```console
$ vagrant up
```