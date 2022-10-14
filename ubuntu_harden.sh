#!/bin/bash

sys_upgrades() {
    apt-get --yes --force-yes update
    apt-get --yes --force-yes upgrade
    apt-get --yes --force-yes autoremove
    apt-get --yes --force-yes autoclean
}

unattended_upg() {
    apt-get --yes --force-yes install unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
}


user_pass_expirations() {
    perl -npe 's/PASS_MAX_DAYS\s+99999/PASS_MAX_DAYS 180/' -i /etc/login.defs
    perl -npe 's/PASS_MIN_DAYS\s+0/PASS_MIN_DAYS 1/g' -i /etc/login.defs
    perl -npe 's/PASS_WARN_AGE\s+7/PASS_WARN_AGE 14/g' -i /etc/login.defs
}

disable_root() {
    passwd -l root
}

purge_telnet() {
    apt-get --yes purge telnet
}

purge_nfs() {
    apt-get --yes purge nfs-kernel-server nfs-common portmap rpcbind autofs
}

purge_whoopsie() {
    apt-get --yes purge whoopsie
}

set_av() {
    apt-get --yes install chkrootkit clamav
    chkrootkit
    freshclam
    clamscan -ir --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc /
    }

disable_compilers() {
    chmod 000 /usr/bin/byacc
    chmod 000 /usr/bin/yacc
    chmod 000 /usr/bin/bcc
    chmod 000 /usr/bin/kgcc
    chmod 000 /usr/bin/cc
    chmod 000 /usr/bin/gcc
    chmod 000 /usr/bin/*c++
    chmod 000 /usr/bin/*g++
    # 755 to bring them back online
}

# firewall() {
#     ufw allow ssh
#     ufw allow http
#     ufw deny 23
#     ufw default deny
#     ufw enable
#     }

# harden_ssh_brute() {
#     # Many attackers will try to use your SSH server to brute-force passwords.
#     # This will only allow 6 connections every 30 seconds from the same IP address.
#     ufw limit OpenSSH
# }

purge_atd() {
    apt-get --yes purge at
}

disable_avahi() {
    update-rc.d avahi-daemon disable
}

process_accounting() {
    apt-get --yes --force-yes install acct
    cd /
    touch /var/log/wtmp
    cd
    }

fix_file_permissions() {
    cat fileperms.txt | bash 2>/dev/null
}

kernel_tuning() {
    sysctl kernel.randomize_va_space=1
    sysctl kernel.kptr_restrict=1
    sysctl -w fs.protected_hardlinks=1
    sysctl -w fs.protected_symlinks=1
    sysctl -w fs.suid_dumpable=0
    sysctl net.ipv6.conf.all.disable_ipv6=1
    sysctl net.ipv6.conf.default.disable_ipv6=1
    sysctl net.ipv6.conf.lo.disable_ipv6=1
    sysctl net.ipv6.conf.all.rp_filter=1
    sysctl net.ipv4.conf.all.rp_filter=1
    sysctl net.ipv4.conf.all.accept_source_route=0
    sysctl net.ipv4.icmp_echo_ignore_broadcasts=1
    sysctl net.ipv4.conf.all.log_martians=1
    sysctl net.ipv4.conf.default.log_martians=1
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl kernel.sysrq=0
    sysctl net.ipv4.tcp_timestamps=0
    sysctl net.ipv4.tcp_syncookies=1
    sysctl net.ipv4.icmp_ignore_bogus_error_responses=1
    sysctl net.ipv4.tcp_syn_retries=2
    sysctl net.ipv4.tcp_synack_retries=2
    sysctl net.ipv4.tcp_max_syn_backlog=2048
    sysctl net.ipv4.tcp_rfc1337=1
    sysctl -p
}

main() {
    sys_upgrades
    unattended_upg
    disable_root
    purge_telnet
    purge_nfs
    purge_whoopsie
    set_av
    process_accounting
    purge_atd
    disable_avahi
    kernel_tuning
    fix_file_permissions
    disable_compilers
}

main "$@"
