#!/bin/sh

#  copyright.sh
#  Aural
#
#  Copyright © 2024 Kartik Venugopal. All rights reserved.

export basedir=/Users/kven/Projects/xcode/Aural/Tests
#export basedir=~/Src

function iterateDir {

    dir=$1
    cd $dir
    pwd
    mkdir result

    for child in *; do

        if [[ -d "$dir/$child" ]]; then
        
            if [[ "$child" != "result" ]]; then
                iterateDir ${dir}/${child} &
            fi

        elif [[ -f $child ]]; then

            case $child in *.swift)

                echo "//\n//  ${child}\n//  Aural" > "result/filename-${child}.txt"
                cat "result/filename-${child}.txt" "/Users/kven/copyright.txt" ${child} > "tmp-${child}"
                mv $child "old-${child}"
                mv "tmp-${child}" ${child}
                rm "old-${child}"

            esac

        fi

    done
    
    rm -rf result
    wait
}

iterateDir $basedir
