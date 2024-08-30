function exiterr() {
    echoerr "$*"
    exit 1
}

function echoerr() {
    printf "%s\n" "$*" >&2;
}

function title() {
    local len=$((${#1}+2))
    printf "\n+"
    printf -- "-%.0s" $(seq 1 $len)
    printf "+\n| $1 |\n+"
    printf -- "-%.0s" $(seq 1 $len)
    printf "+\n\n"
}

function get_kvm_osvariant()
{
    local OSVAR="unknown"
    local DISTRO=${VM_DISTRO}
    case $DISTRO in
        debian10)   OSVAR=$DISTRO ;;
        debian11)   OSVAR=$DISTRO ;;
        debian12)   OSVAR=$DISTRO ;;
        debian13)   OSVAR=$DISTRO ;;
        ubuntu18) OSVAR="ubuntu18.04" ;;
        ubuntu20) OSVAR="ubuntu20.04" ;;
        ubuntu22) OSVAR="ubuntu22.04" ;;
        ubuntu24) OSVAR="ubuntu24.04" ;;
        rhel7)    OSVAR="rhel7-unknown" ;;
        rhel8)    OSVAR="rhel8-unknown" ;;
        rhel9)    OSVAR="rhel9-unknown" ;;
        rhel10)   OSVAR="rhel10-unknown" ;;
        sles12)   OSVAR="sles12-unknown" ;;
        sles15)   OSVAR="sle15-unknown" ;;
        sol114)   OSVAR="solaris11" ;;
        sol10)    OSVAR="solaris10" ;;
    esac
    echo $OSVAR
}
