# -*- mode: sh; sh-shell: bash -*-

# .usage:
#     path-set <varname> <dir> ...
# .description:
#     Set the specified colon-separated path variable
#     to a colon-separated list of the specified directories.
path-set () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    var=""
    for dir in "${@}" ; do
        var="${var}:${dir}"
    done
    var="${var#:}"
}

# .usage:
#     path-prepend <varname> <dir> ...
# .description:
#     For each directory specified, in the order specified,
#     prepend it to the spedcified colon-separated path variable
#     if it's not already a member.
path-prepend () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    for dir in "${@}" ; do
        if [[ -d "${dir}" ]] ; then
            if [[ "${var}" != "${dir}" ]] && [[ "${var}" != *:"${dir}" ]] &&
                   [[ "${var}" != "${dir}":* ]] && [[ "${var}" != *:"${dir}":* ]] ; then
                var="${dir}${var:+:${var}}"
            fi
        fi
    done
}

# .usage:
#     path-prepend <varname> <dir> ...
# .description:
#     For each directory specified, in the order specified,
#     append it to the spedcified colon-separated path variable
#     if it's not already a member.
path-append () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    for dir in "${@}" ; do
        if [[ -d "${dir}" ]] ; then
            if [[ "${var}" != "${dir}" ]] && [[ "${var}" != *:"${dir}" ]] &&
                   [[ "${var}" != "${dir}":* ]] && [[ "${var}" != *:"${dir}":* ]] ; then
                var="${var:+${var}:}${dir}"
            fi
        fi
    done
}

# .usage:
#     path-check <varname> <dir> ...
# .description:
#     If the specified colon-separated path variable
#     contains one or more of the specified directories
#     as member(s), return 0 indicating success.
#     Otherwise, return 1 indicating failure.
path-check () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    for dir in "${@}" ; do
        if [[ "${var}" != "${dir}" ]] && [[ "${var}" != *:"${dir}" ]] &&
               [[ "${var}" != "${dir}":* ]] && [[ "${var}" != *:"${dir}":* ]] ; then
            return 1            # fail if any directory is not listed
        fi
    done
    return 0
}

# .usage:
#     path-remove <varname> <dir> ...
# .description:
#     Remove any and all instances of any of the specified
#     directories from the specified colon-separated path
#     variable.
path-remove () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    for dir in "${@}" ; do
        while true ; do
            if [[ "${var}" = "${dir}" ]] ; then
                # not sure of appropriate solution, given
                # what happens when a PATH is empty.
                var=""
                break
            elif [[ "${var}" = *:"${dir}" ]] ; then
                var="${var%:${dir}}"
            elif [[ "${var}" = "${dir}":* ]] ; then
                var="${var#${dir}:}"
            elif [[ "${var}" = *:${dir}:* ]] ; then
                var="${var%:${dir}:*}:${var##*:${dir}:}"
            else
                break
            fi
        done
    done
}

# .usage:
#     path-cleanup <varname>
# .description:
#     Remove duplicates from the specified colon-separated
#     path variable.
path-cleanup () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    local -a oldpath; mapfile -d : -t oldpath < <(echo -n "${var}")

    local -a newpatharray=()
    local oldpathelement
    local newpathelement
    local -i match

    for oldpathelement in "${oldpath[@]}" ; do
        match=0
        for newpathelement in "${newpatharray[@]}" ; do
            if [[ "${oldpathelement}" = "${newpathelement}" ]] ; then
                match=1
                break
            fi
        done
        if (( ! match )) ; then
            newpatharray+=("${oldpathelement}")
        fi
    done

    path-set "${varname}" "${newpatharray[@]}"
}

# .usage:
#     path-remove-tree <varname> <dir> ...
# .description:
#     Remove each of the specified directories, and any of their
#     subdirectories, from the specified colon-separated path
#     variable.
path-remove-tree () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    local -a oldpath; mapfile -d : -t oldpath < <(echo -n "${var}")

    local -a newpatharray=()
    local oldpathelement
    local -i match
    local dir

    for oldpathelement in "${oldpath[@]}" ; do
        match=0
        for dir in "${@}" ; do
            if [[ "${oldpathelement}" = "${dir}" ]] || [[ "${oldpathelement}" = "${dir}"/* ]] ; then
                match=1
                break
            fi
        done
        if (( match )) ; then
            :
        else
            newpatharray+=("${oldpathelement}")
        fi
    done

    path-set "${varname}" "${newpatharray[@]}"
}

# .usage:
#     path-force-prepend <varname> <dir> ...
# .description:
#     For each specified directory, in the order specified,
#     prepend it to the specified colon-separated path
#     variable, removing any existing instances.
path-force-prepend () {
    local varname="$1"; shift; varname="${varname:-PATH}"

    path-remove "${varname}" "$@"
    path-prepend "${varname}" "$@"
}

# .usage:
#     path-force-append <varname> <dir> ...
# .description:
#     for each specified directory, in the order specified,
#     append it to the specified colon-separated path
#     variable, removing any existing instances.
path-force-append () {
    local varname="$1"; shift; varname="${varname:-PATH}"

    path-remove "${varname}" "$@"
    path-append "${varname}" "$@"
}

# .usage:
#     path-list <varname>
# .description:
#     for each specified variable name, print a list of
#     its colon-separated components, one on each line.
path-list () {
    local varname="$1"; shift; varname="${varname:-PATH}"
    local -n var="${varname}"

    local -a path; mapfile -d : -t path < <(echo -n "${var}")

    for i in "${path[@]}" ; do
        echo "$i"
    done
}

path () {
    local varname="$1"; shift; varname="${varname:-PATH}"

    path-list "${varname}"
}
