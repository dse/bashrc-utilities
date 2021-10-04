# -*- mode: sh; sh-shell: bash -*-

export-or-unexport () {
    local var
    for var ; do
        if [[ "${!var}" != "" ]] ; then
            export $var
        else
            export -n $var
        fi
    done
}
