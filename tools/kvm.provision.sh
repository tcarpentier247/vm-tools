#!/bin/bash

set -a

PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 2>/dev/null|| echo $0));pwd)"
cd $PATH_SCRIPT

. ../configs/environment || exit 1

# $1 hostname
# $2 distrib
# $3 installfolder
#
# example
# ./kvm.provision.sh c2n1 ubuntu22 /data/tmp

VM_NAME=$1
VM_DISTRO=$2
VM_ROOT=$3

VM_BASE_IMAGE="${IMAGES[$VM_DISTRO]}"
VM_DISTRO_KIND="${VM_DISTRO%%+([[:digit:]])}"
VM_CONFIGS="$CONFIGS/machines/$VM_NAME"

# empty if not vdc
VM_IP=$(grep -w ^$VM_NAME ${NODES} | sort -u | awk '{print $3}')
VM_CID=$(grep -w ^$VM_NAME ${NODES} | sort -u | awk '{print $2}')
VM_2DGCID=$(printf "%02d" "$VM_CID")
VM_HEXCID=$(printf "%02x" "$VM_CID")

# c1n1 ssh => 20111   vnc => 20161
# c6n2 ssh => 20612   vnc => 20662
VM_SSHPORT=3$VM_2DGCID$VM_IP
[[ -z "$VM_VNCPORT" ]] && {
    let VM_VNCPORT=$VM_SSHPORT+50
}

for FILE in environment secrets
do
    [[ -f $VM_CONFIGS/$FILE ]] && {
        echo "Loading $VM_CONFIGS/$FILE custom configuration"
        . $VM_CONFIGS/$FILE
    }
done

VM_NIC=${VM_NIC:-eth0}
VM_AUDIO=${VM_AUDIO:-none}
[[ "$VM_DISTRO" =~ ^debian.* ]] && VM_NIC="enp1s0"
[[ "$VM_DISTRO" =~ ^ubuntu.* ]] && VM_NIC="enp1s0"

VM_BRIDGE=${VM_BRIDGE:-br0}
VM_VNCPASSWORD=${VM_VNCPASSWORD:-password}

function check_prerequisites() {
    title Begin:$FUNCNAME
    [[ -z "$VM_NAME" ]] && exiterr "VM_NAME is not defined"
    [[ -z "$VM_DISTRO" ]] && exiterr "VM_DISTRO is not defined"
    [[ -z "$VM_ROOT" ]] && exiterr "VM_ROOT is not defined"
    [[ ! -v "IMAGES[$VM_DISTRO]" ]] && exiterr "VM_DISTRO $VM_DISTRO is not available"
    [[ -z "$VM_SYS_SIZE" ]] && exiterr "VM_SYS_SIZE is not defined"
    [[ -z "$VM_DATA_SIZE" ]] && exiterr "VM_DATA_SIZE is not defined"
    title End:$FUNCNAME
}

function prepare()
{
    title Begin:$FUNCNAME
    [[ ! -d $VM_ROOT ]] && mkdir -p $VM_ROOT
    title End:$FUNCNAME
} 

function copy_base_image()
{
    title Begin:$FUNCNAME
    [[ ! -f $KVM_IMAGES_ROOT/$VM_BASE_IMAGE ]] && exiterr "kvm image $KVM_IMAGES_ROOT/$VM_BASE_IMAGE not found"
    [[ ! -f $VM_ROOT/$VM_BASE_IMAGE ]] && cp $KVM_IMAGES_ROOT/$VM_BASE_IMAGE $VM_ROOT/$VM_BASE_IMAGE
    title End:$FUNCNAME
}

function create_vmdisks()
{
    title Begin:$FUNCNAME
    [[ -f $VM_ROOT/system.qcow2 ]] && exiterr "$VM_ROOT/system.qcow2 already exist"
    [[ -f $VM_ROOT/data.qcow2 ]] && exiterr "$VM_ROOT/data.qcow2 already exist"
    qemu-img create -f qcow2 -F qcow2 -o backing_file=$VM_ROOT/$VM_BASE_IMAGE $VM_ROOT/system.qcow2 && \
        qemu-img resize $VM_ROOT/system.qcow2 $VM_SYS_SIZE
    qemu-img create -f qcow2 $VM_ROOT/data.qcow2 $VM_DATA_SIZE
    title End:$FUNCNAME
}

function substitute_patterns()
{
    title Begin:$FUNCNAME 

    local FILES="$VM_ROOT/meta-data $VM_ROOT/user-data"

    sed -i "s@VM_NAME@$VM_NAME@g" $FILES
    sed -i "s@VM_NIC@$VM_NIC@g" $FILES
    sed -i "s@VM_HEXCID@$VM_HEXCID@g" $FILES
    sed -i "s@VM_2DGCID@$VM_2DGCID@g" $FILES
    sed -i "s@VM_CID@$VM_CID@g" $FILES
    sed -i "s@VM_IP@$VM_IP@g" $FILES
    sed -i "s@RH_ORG_ID@$RH_ORG_ID@g" $FILES
    sed -i "s@RH_ACTIVATION_KEY@$RH_ACTIVATION_KEY@g" $FILES
    sed -i "s/SUSE_ORGANISATION_MAIL/$SUSE_ORGANISATION_MAIL/g" $FILES
    sed -i "s@SUSE_REGISTRATION_KEY@$SUSE_REGISTRATION_KEY@g" $FILES
    title End:$FUNCNAME
}

function gen_cloud_init_files()
{
    title Begin:$FUNCNAME 
    local CUSTOMIZE_META_DATA=true
    local CUSTOMIZE_USER_DATA=true
    
    # custom meta-data
    [[ -f $VM_CONFIGS/meta-data ]] && {
            cp -f $VM_CONFIGS/meta-data $VM_ROOT/
            CUSTOMIZE_META_DATA=false
    }

    # custom user-data
    [[ -f $VM_CONFIGS/user-data ]] && {
            cp -f $VM_CONFIGS/user-data $VM_ROOT/
            CUSTOMIZE_USER_DATA=false
    }

    if [ "$CUSTOMIZE_META_DATA" = true ] ; then
        cp -f $TEMPLATES/meta-data.common $VM_ROOT/meta-data
    fi

    if [ "$CUSTOMIZE_USER_DATA" = true ] ; then
        cp -f $TEMPLATES/user-data.common $VM_ROOT/user-data
        for SECTION in write_files run_cmd
        do
            cat $TEMPLATES/user-data.$SECTION.$VM_DISTRO >> $VM_ROOT/user-data
        done
    fi

    substitute_patterns
    title End:$FUNCNAME
}

function create_seed() {
	title Begin:$FUNCNAME
    gen_cloud_init_files
    genisoimage -input-charset utf-8 -output $VM_ROOT/seed.iso -volid cidata -joliet -rock $VM_ROOT/user-data $VM_ROOT/meta-data || \
        exiterr "error while creating seed.iso"
    title End:$FUNCNAME
}

function create_uefi() {
    title Begin:$FUNCNAME
    # UEFI based images
    [[ "$VM_BASE_IMAGE" =~ .*uefi.* ]] && {
        UEFI_SECURE_LOADER=${UEFI_SECURE_LOADER:-no}
        UEFI_LOADER="${UEFI_LOADER}"
        [[ -z "$UEFI_LOADER" ]] && {
            # no loader definition set in VM_CONFIGS
            [[ -f $VM_ROOT/uefi.loader.fd ]] && {
                UEFI_LOADER="$VM_ROOT/uefi.loader.fd"
            } || {
                UEFI_LOADER="/usr/share/OVMF/OVMF_CODE_4M.fd"
            }
        }
    
        UEFI_VARS="${UEFI_VARS}"
        [[ -z "$UEFI_VARS" ]] && {
            # no vars definition set in VM_CONFIGS
	    [[ -f $KVM_IMAGES_ROOT/$VM_DISTRO.efivars.fd ]] && {
                echo "Copying $KVM_IMAGES_ROOT/$VM_DISTRO.efivars.fd to $VM_ROOT/uefi.vars.fd"
	        cp $KVM_IMAGES_ROOT/$VM_DISTRO.efivars.fd $VM_ROOT/uefi.vars.fd
	    }
            [[ -f $VM_ROOT/uefi.vars.fd ]] && {
                UEFI_VARS="$VM_ROOT/uefi.vars.fd"
            } || {
                UEFI_VARS="/usr/share/OVMF/OVMF_VARS_4M.fd"
            }
        }
        VM_VIRTINSTALL_OPTS="${VM_VIRTINSTALL_OPTS} --boot loader=$UEFI_LOADER,loader.readonly=yes,loader.type=pflash,nvram.template=$UEFI_VARS,loader_secure=$UEFI_SECURE_LOADER,bootmenu.enable=on,bios.useserial=on"
    } || echo "non uefi image"

    title End:$FUNCNAME
}

# bridge name
# cpu
# ram

function execute_virtinstall()
{
	title Begin:$FUNCNAME
	VM_CPU=${VM_CPU:-2}
	VM_RAM=${VM_RAM:-2048}
    VM_OSVARIANT=$(get_kvm_osvariant)
	VM_CONSOLE_KEYMAP=${VM_CONSOLE_KEYMAP:-fr}
	VM_VIRTINSTALL_OPTS=${VM_VIRTINSTALL_OPTS}
    
    grep -q '22:23:24:' $VM_ROOT/user-data && {
        # found vdc mac addresses
        # we have to connect 3 nics
        VM_VIRTINSTALL_OPTS="${VM_VIRTINSTALL_OPTS} --network=bridge:br-$VM_CID-0,model=virtio,mac=22:23:24:$VM_HEXCID:00:$VM_IP"
        VM_VIRTINSTALL_OPTS="${VM_VIRTINSTALL_OPTS} --network=bridge:br-$VM_CID-1,model=virtio,mac=22:23:24:$VM_HEXCID:01:$VM_IP"
        VM_VIRTINSTALL_OPTS="${VM_VIRTINSTALL_OPTS} --network=bridge:br-$VM_CID-2,model=virtio,mac=22:23:24:$VM_HEXCID:02:$VM_IP"
    } || {
        # standard cnx
        VM_VIRTINSTALL_OPTS="${VM_VIRTINSTALL_OPTS} --network=bridge:$VM_BRIDGE,model=virtio"
    }

    [[ "$VM_DISTRO" =~ .*\.qcow2 ]] && VM_VIRTINSTALL_OPTS="${VM_VIRTINSTALL_OPTS} --import"
	
    virt-install \
    --connect qemu:///system \
    --audio $VM_AUDIO \
    --graphics vnc,keymap=$VM_CONSOLE_KEYMAP,listen=0.0.0.0,port=$VM_VNCPORT,password=$VM_VNCPASSWORD \
    --virt-type kvm \
    --name $VM_NAME \
    --ram $VM_RAM \
    --vcpus=$VM_CPU \
    --os-variant $VM_OSVARIANT \
    --disk path=$VM_ROOT/system.qcow2,format=qcow2 \
    --disk path=$VM_ROOT/data.qcow2,format=qcow2 \
    --disk $VM_ROOT/seed.iso,device=cdrom \
    --noautoconsole \
    --console pty,target_type=serial,log.file=$VM_ROOT/console.log $VM_VIRTINSTALL_OPTS
    title End:$FUNCNAME
}

check_prerequisites
prepare
copy_base_image
create_vmdisks
create_seed
create_uefi
execute_virtinstall
