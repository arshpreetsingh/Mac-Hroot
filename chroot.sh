#!/bin/sh

MACJAIL=${1:-"$PWD/mac-jail"}
MACJAIL=${MACJAIL%/}
test -d $MACJAIL || { echo "Directory $MACJAIL not found!"; exit 1; }
JAILHOME=$MACJAIL$HOME
JAILSOCK=$MACJAIL/${SSH_AUTH_SOCK%/*}

mycp() {
  FROM=$1
  BN=${FROM##*/}
  DN=${FROM%/*}
  TO=$MACJAIL/$DN
  test -r $TO/$BN && return 0
  echo $FROM
  mkdir -p "${TO}"
  cp "$FROM" "$TO"
}

mymkdir() {
  test -d $1 || mkdir -pv $1
}

mymkdir $JAILHOME
mymkdir $JAILSOCK
mymkdir $MACJAIL/var/run
mycp /etc/resolv.conf
mycp /etc/hosts
ln -f /var/run/mDNSResponder $MACJAIL/var/run/
ln -f $SSH_AUTH_SOCK $JAILSOCK
env -i \
  TERM=$TERM \
  PS1="${MACJAIL##*/}\$ " \
  SHELL=$SHELL \
  HOME=$HOME \
  PATH=$PATH \
  sudo /usr/sbin/chroot -u $LOGNAME $MACJAIL $SHELL
