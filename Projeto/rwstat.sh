#!/bin/bash


###############################    Sistemas Operativos    ###############################  


#                                       Trabalho 1                                      #
#                           Estatística de Processos em bash                            #


#                           Nome:Vasco Miguel Fernandes Faria                           #
#                           Nmec: 107323                                                #
                    
#                           Nome: Pedro Miguel Ribeiro Rei                              #
#                           Nmec: 107463                                                #

###############################    Sistemas Operativos    ###############################  





#Options function where it shows all kinds of possible options for arguments

function options(){
    printf "\n"
    echo "'-c': Selection of processes to use through a regular expression" 
    echo "'-s': Selection of processes to view in a time period (minimum date)" 
    echo "'-e': Selection of processes to view in a time period (maximum date)"   
    echo "'-u': Selection of processes to be displayed by user name" 
    echo "'-m': Selection of processes to be visualized through the range of pids( minimum range)"
    echo "'-M': Selection of processes to be visualized through the range of pids( maximum range)"
    echo "'-p': Number of processes to view" 
    echo "'-w': Table sort by writeR"    
    echo "'-r': Reverse sort"     
    echo "Advice!! The last argument must be a number in seconds"
    printf "\n"
}


#Incorrect functions that alerts in case of argument or ordering errors

function IncorrectA(){
    printf "Incorrect arguments\n";
    options
    exit 1;
}

function IncorrectO(){
    printf "Incorrect ordering options\n";
    options
    exit 1;
}

function IncorrectP(){
    printf "Error searching for desired processes\n";
    exit 1;
}

#Function that prints the table header

function Table(){
    printf "%-27s %-7s %13s %16s %16s %16s %16s %20s\n"  "COMM" "USER" "PID" "READB" "WRITEB" "RATER" "RATEW" "DATE";
    printf "\n"
}

#declaration of arrays;

declare -a InitialValues;
declare -a FinalValues;

#declaration of values for input arguments and variables that will be used in the program;

#"-c"

c=0;
c_value='';

#"-s"

s=0;
s_value='';

#"-e"

e=0;
e_value='':

#"-u"
u=0;
u_value='';

#"-m"

m=0;
m_value='';

#"-M"

Ma=0;
Ma_value='';

#"-p"

p=0;
p_value=0;

#"-r"

order='';
r=0;

#variables used

seconds=0;
last='';
cnt=0;
Sort_mode="":


#verification por regular expressions

num='^[0-9]+([.][0-9]+)?$';
numb="^[0-9]+$";
timePattern="^[A-Z][a-z][a-z] ([0-9]{1,2}) [0-2][0-9]:[0-5][0-9]$"


#verification if there is some argument in the terminal line // if not call IncorretA function that print error message

if [[ $# == 0 ]];
then
   IncorrectA
fi

#verification if the last argument is a number // if not call IncorretA function that print error message


if ! [[ ${@: -1} =~ $lastmustbeanumber ]]; then
    IncorrectA
fi

# for cicle that traverse the line of arguments

for i in "$@";
do
    let cnt=cnt+1;
    if [[ $cnt == $# ]]                                                                                         #verification that i is the last argument
    then
    #if the penultimate argument requires a value , the program must print ERRROR message , else last argument is the number of seconds
        if [[ $last == '' && $i =~ $num ]]          
        then
            if [[ $i > 0 ]];
            then
                seconds=$i;
            else 
                IncorrectA
            fi
        else
            IncorrectA
        fi
    fi

    if [[ $last != '' ]] 
    then
        case "$last" in
            ("-c")      
                c=1;                #if the readed argument is -c , we give a value to the c variable to know that this argument was called
                c_value=$i;         #we get the expression 
                last='';            #variable return to ''
                ;;
            ("-s")
                s=1;                #if the readed argument is -s , we give a value to the s variable to know that this argument was called
                if [[ $i =~ $timePattern ]]     #verification of the date
                then
                    s_value=$(date -d "${i}" +"%s");      #we get the starting date
                    if [[ $e == 1 && $s_value -gt $e_value ]];  #if the  starting date is after the  ending date , call function IncorrectA to print Error
                    then
                        IncorrectA
                    fi
                else
                   IncorrectA
                fi
                last='';        #return last to ''
                ;;
            ("-e")
                e=1;            #if the readed argument is -e , we give a value to the e variable to know that this argument was called
                if [[ $i =~ $timePattern ]]     #verification of the date
                then
                    e_value=$(date -d "${i}" +"%s");        #we get the ending date
                    if [[ $s == 1 && $s_value -gt $e_value ]];  #if the  starting date is after the  ending date , call function IncorrectA to print Error
                    then    
                        IncorrectA
                    fi
                else
                    IncorrectA
                fi
                last='';
                ;;
            ("-u")
                u=1;            #if the readed argument is -u , we give a value to the u variable to know that this argument was called
                u_value=$i;     #we get the user name
                last='';        #return last to ''
                ;;
            ("-m")
                m=1;                        #if the readed argument is -m , we give a value to the m variable to know that this argument was called
                if [[ $i =~ $num ]];        #verification of the number
                then 
                    m_value=$i;              #we get the minimum number of pids
                    if [[ $m == 1 ]];
                    then
                        if [[ $Ma == 1 && $m_value -gt $Ma_value  ]];       #if the  minimum number of pids is greater than maximum number of pids , call function IncorrectA to print Error
                        then
                            IncorrectA
                        fi
                    fi
                else
                    IncorrectA
                fi
                last='';        #return last to ''
                ;;
                ("-M")
                Ma=1;                       #if the readed argument is -M , we give a value to the Ma variable to know that this argument was called
                if [[ $i =~ $num ]];        #verification of the number
                then 
                    Ma_value=$i;            #we get the maximum number of pids
                    if [[ $Ma == 1 && $m_value -gt $Ma_value ]];        #if the  minimum number of pids is greater than maximum number of pids , call function IncorrectA to print Error
                    then
                        IncorrectA
                    fi
                else
                    IncorrectA
                fi
                last='';            #return last to ''
                ;;
            ("-p")
                p=1;                            #if the readed argument is -p , we give a value to the p variable to know that this argument was called
                if [[ $i =~ $numb ]]            #verification of the number
                then
                    p_value=$i;                 #we get the number of processes to visualize
                else
                    IncorrectA
                fi
                last='';            #return last to ''
                ;;
            (*)
                IncorrectA
        esac
    else
        last=$i;            #if last != ''
    fi

    case "$i" in
        ("-w")
            if [[ $order != "" ]];  #verification 
            then
                IncorrectO
            fi
            order='w';
            last='';         #return last to ''
            ;;
        ("-r")
            r=1;            #if the readed argument is -r , we give a value to the r variable to know that this argument was called
            last='';        #return last to ''
            ;;
    esac
done


cd /proc;        #open proc diretory

for j in *[0-9];
do

    if [[ -r "$j/status" && -r "$j/io" ]] ;   # open subdirectories  /status e /io
    then

        cd $j;

        proc_COMM=$(cat comm);      #read COMM from process
        # if a regular expression has been passed and the process name does not match it, it is not even worth reading the data
        if [[ $c == 1 && ! $proc_COMM =~ $c_value ]];
        then
            cd ..;
            continue;
        fi
        proc_COMM=$(echo "${proc_COMM//[ ]/_}");

        proc_USER=$(ls -ld | awk '{print $3}');     #read user from process
        # if the user is different form the intended one, it is also not worth continuing
        if [[ $u == 1 && ! $proc_USER == $u_value ]];
        then
            cd ..;
            continue;
        fi

       
        proc_PID=$(grep ^"Pid:" status | awk '{print $2}');     #read PID from process

        Pidslidos=${proc_PID};

        #if the number of pids is smaller than intended, it is also not worth continuing
        if [[ $m == 1 && !  $Pidslidos -gt $m_value ]];   
        then 
            cd ..;
            continue;
        fi

        #if the number of pids is smaller than intended, it is also not worth continuing
        if [[ $Ma == 1 &&  !  $Pidslidos -lt $Ma_value ]];
        then 
            cd ..;
            continue;
        fi

        proc_READB=$(grep "rchar:" io | awk '{print $2}');      #read readed bytes 
        proc_WRITEB=$(grep "wchar:" io | awk '{print $2}');     #read wroted bytes

       


        #if any of the parameters does not exist then it is not to be added to the first_values ​​array
        if [[ $proc_COMM == "" || $proc_COMM == "" || $proc_PID == "" || $proc_READB == "" || $proc_WRITEB == "" ]];
        then
            cd ..;
            continue;
        fi
        

        #Save initial values on an array

        InitialValues[${#InitialValues[@]}]="$proc_COMM $proc_USER $proc_PID  $proc_READB $proc_WRITEB";

        cd ..;

    fi

done

#script stops for s seconds

sleep $seconds;


#script works again 

#for cicle that tranverse the array with the processes infos

for ((g = 0; g < (${#InitialValues[@]}); g++));
do

    list=(${InitialValues[$g]});    #it creates a new array with the process info
    cd ${list[2]};                  # goes to the user directory

    LC_TIME=en_US.UTF-8;
    proc_DATE=$(ls -ld | cut -d\  -f6- | awk '{$4=""; print $0}');      #read date from process
    
    secondsss=$(date -d "${proc_DATE}" +"%s");    

    #if the  starting date is before the date of the process ,  it is also not worth continuing   
    if [[ $s == 1 && ! $secondsss -gt $s_value ]];
    then
        cd ..;
        continue;
    #if the  ending date is after the date of the process ,  it is also not worth continuing 
    elif [[ $e == 1 && ! $secondsss -lt $e_value ]];
    then
        cd ..;
        continue;
    fi

    readsecondtime=$(grep "rchar:" io | awk '{print $2}');      #read readed bytes after the s seconds
    writesecondtime=$(grep "wchar:" io | awk '{print $2}');     #read wroted bytes after the s seconds

    LC_NUMERIC="en_US.UTF-8"
    READB2=$(echo "($readsecondtime - ${list[3]})"| bc -l);       #calculates the readed bytes within the proposed time frame
    WRITEB2=$(echo "($writesecondtime - ${list[4]})" | bc -l);     #calculates the wroted bytes within the proposed time frame
    

    proc_RATER=$(echo "($readsecondtime - ${list[3]}) / $seconds" | bc -l);    #calculates the readed bytes rate
    proc_RATEW=$(echo "($writesecondtime - ${list[4]}) / $seconds" | bc -l);    #calculates the wroted bytes rate

    #if any of the parameters does not exist then it is not to be added to the first_values ​​array
    if [[ $READB2 == "" || $WRITEB2 == "" || $proc_RATER == "" || $proc_RATEW == "" || $proc_DATE == "" ]];
    then
        cd ..;
        continue;
    fi

    #Save final processes and  values on an array 
    
    FinalValues[${#FinalValues[@]}]=$(printf "$(echo "%-20s %-12s %15d %16d %16d %16.02f %16.02f %21s\n"  | awk -v RATER=$proc_RATER '{if (RATER == 0) {$6="%16d"} ; print ; }' | awk -v RATEW=$proc_RATEW '{if (RATEW == 0) {$7="%16d"} ; print ; }')" "${list[0]}" "${list[1]}" "${list[2]}" "$READB2" "$WRITEB2" "$proc_RATER" "$proc_RATEW" "$proc_DATE");
    
    cd ..;

done

cd ..;


#if there isnt any processes readed, calls IncorrectP function that prints error message

if [[ ${#FinalValues[@]} == 0 ]];
then
   IncorrectP
fi



   case "$order" in 
        ("w")
            if [[ $r == 1 ]];
            then 
                Sort_mode="sort -n -k7";    #descending order
            else
                Sort_mode="sort -rn -k7";   #ascending order
            fi
            ;;
        (*)
            if [[ $r == 1 ]];
            then 
                Sort_mode="sort -rn -k1";   #reverse order
            else
                Sort_mode="sort -n -k1";    #default order
            fi
            ;;
    esac

Table           #calls function table to print the table header

if [[ $p == 1 ]];
then
    printf "%s\n" "${FinalValues[@]}"  | ${Sort_mode} | head -${p_value} ;  #print only p processes
else
    printf "%s\n" "${FinalValues[@]}"  | ${Sort_mode};          #print the readed procresses
fi