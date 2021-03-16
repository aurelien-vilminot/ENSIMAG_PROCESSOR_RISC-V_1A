#! /bin/bash

# $1 : liste des tags
# $2 : liste des tests

# Upper case transformation
tags=${1^^} 

for tag in $tags
do
    if [[ "$tag" != "" ]] ;
    then
        l=""
        final_res="PASSED"
        file_list_ko=""
        file_list=""
        for file in $2
        do
            test_tag=$(awk 'BEGIN{IGNORECASE=1} /# *TAG *= *([^\r\n]*)/{print gensub(/.*# *TAG *= *([^ \r]+) *\r*/, "\\1", "g")}' $file)
            if [[ ${test_tag^^} == ${tag} ]] ; then
                l="$l $file"
                test="^$(basename ${file} .s)$"
            
                res=$(awk -v test="$test" 'BEGIN{IGNORECASE=1}$1~test{print $2}' autotest.res)
                if [[ $res != "PASSED" ]] ; then
                    final_res="${res}"
                fi
                file_list="${file_list} $(basename ${file})"
                file_list_ko="${file_list_ko} $(basename ${file})=${res}"
            fi
        done
        if [[ "${file_list}" == "" ]] ; then
            final_res="NO_TEST_FOUND"
        fi
        file_list=$(echo -e "${file_list}" | sed -e 's/^[[:space:]]*//')
        file_list_ko=$(echo -e "${file_list_ko}" | sed -e 's/^[[:space:]]*//')
        if [[ ${final_res} == "PASSED" ]] ; then
            echo "${tag} ${final_res} (${file_list})"
        else
            echo "${tag} ${final_res} (${file_list_ko})"
        fi
    fi
done 



