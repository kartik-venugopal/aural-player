#!/bin/sh

export basedir=/Users/kven/Projects/xcode/Aural/Source
#export basedir=~/Src

function iterateDir {

    dir=$1
    cd $dir
    pwd

    for child in *; do

        if [[ -d "$dir/$child" ]]; then
        
            if [[ "$child" != "result" ]]; then
                iterateDir ${dir}/${child} &
            fi

        elif [[ -f $child ]]; then

            case $child in *.xib)

                { head -n 1 $child; echo "<!--\n\n    ${child}\n    Aural\n\n    Copyright © 2025 Kartik Venugopal. All rights reserved.\n\n    This software is licensed under the MIT software license.\n    See the file \"LICENSE\" in the project root directory for license terms.\n\n-->"; tail -n +2 $child; } > "tmp-${child}"
                mv $child "old-${child}"
                mv "tmp-${child}" ${child}
                rm "old-${child}"

            esac

        fi

    done
}

iterateDir $basedir
wait
