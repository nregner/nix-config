# while [ -z "$(socat -T2 stdout tcp:enceladus:22,connect-timeout=10,readbytes=1 2>/dev/null)" ]; do
#   wol 60:3e:5f:4e:4e:bc
#   date
#   sleep 5
# done

ssh -o ControlMaster=yes -o ControlPersist=3600 -o ControlPath=/tmp/ssh-%u-%h-%p-%r -Nf enceladus

trap "ssh -o ControlPath=/tmp/ssh-%u-%h-%p-%r enceladus -O exit" exit
