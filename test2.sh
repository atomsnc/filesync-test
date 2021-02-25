#!/in/bash


FILES=("readme*"
"2011-09-05 10.23.14.jpg"
"2011-09-09 12.31.16.jpg"
"2011-09-11 08.43.12.jpg")

for ((i = 0; i < ${#FILES[@]}; i++))
do
    echo "${FILES[$i]}"
done

