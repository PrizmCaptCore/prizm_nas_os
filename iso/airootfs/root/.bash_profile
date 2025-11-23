# Auto-start NAS installer if kernel parameter is set
if grep -Fqa 'autoinstall' /proc/cmdline &> /dev/null; then
    if [ -f ~/install-nas.sh ]; then
        clear
        ~/install-nas.sh
    fi
else
    # Run automated script from kernel cmdline if present
    if [ -f ~/.automated_script.sh ]; then
        ~/.automated_script.sh
    fi
fi
