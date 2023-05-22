#!/bin/bash

# Thanks to seakintruth for this! <3
# https://askubuntu.com/a/257766/862557

show_menu(){
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    printf "\n${menu}*********************************************${normal}\n"
    printf "\n${menu}DELETE ALL PODS FROM ALL NAMESPACES WITH POD STATUS:${normal}\n"
    printf "\n${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 0)${menu} CrashLoopBackOff ${normal}\n"
    printf "${menu}**${number} 1)${menu} Completed ${normal}\n"
    printf "${menu}**${number} 2)${menu} Error ${normal}\n"
    printf "${menu}**${number} 3)${menu} ErrImagePull ${normal}\n"
    printf "${menu}**${number} 4)${menu} ImagePullBackOff ${normal}\n"
    printf "${menu}**${number} 5)${menu} NodeAffinity ${normal}\n"
    printf "${menu}**${number} 6)${menu} NodeShutdown ${normal}\n"
    printf "${menu}**${number} 7)${menu} Pending ${normal}\n"
    printf "${menu}**${number} 8)${menu} Terminated ${normal}\n"
    printf "${menu}**${number} 9)${menu} ContainerStatusUnknown ${normal}\n"
    printf "${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 10)${menu}  DELETE ALL ReplicaSets FROM ALL NAMESPACES WITH DESIRED PODs=0 ${normal}\n"
    printf "Please enter a menu option and enter or ${fgred}x to exit. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}

del_pod(){
    for ns in $NAMESPACES
      do 
        kubectl -n $ns get po | grep $POD_STATUS | awk '{print $1}' | xargs kubectl -n $ns delete pod  >> delpods.log 2>&1
     done
}

del_rs(){
    for ns in $NAMESPACES
      do 
      kubectl -n $ns get rs | grep 0 | awk '{print $1}' | xargs kubectl -n $ns delete rs >> delrs.log 2>&1
      done
}

clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        0) clear;
           option_picked "About to delete CrashLoopBackOff pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="CrashLoopBackOff"
           del_pod;
           show_menu;
        ;;
        1) clear;
           option_picked "About to delete Completed pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="Completed"
           del_pod;
           show_menu;
        ;;
        2) clear;
           option_picked "About to delete Error pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="Error"
           del_pod;
           show_menu;
        ;;
        3) clear;
           option_picked "About to delete ErrImagePull pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="ErrImagePull"
           del_pod;
           show_menu;
        ;;
        4) clear;
           option_picked "About to delete ImagePullBackOff pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="ImagePullBackOff"
           del_pod;
           show_menu;
        ;;
        5) clear;
           option_picked "About to delete NodeAffinity pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="NodeAffinity"
           del_pod;
           show_menu;
        ;;
        6) clear;
           option_picked "About to delete NodeShutdown pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="NodeShutdown"
           del_pod;
           show_menu;
        ;;
        7) clear;
           option_picked "About to delete Pending pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="Pending"
           del_pod;
           show_menu;
        ;;
        8) clear;
           option_picked "About to delete Terminated pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="Terminated"
           del_pod;
           show_menu;
        ;;
        9) clear;
           option_picked "About to delete ContainerStatusUnknown pods from all ns";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           POD_STATUS="ContainerStatusUnknown"
           del_pod;
           show_menu;
        ;;      
        10) clear;
           option_picked "About to delete all ReplicaSets from all ns with DESIRED PODS=0";
           NAMESPACES=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
           del_rs;
           show_menu;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Pick an option from the menu";
            show_menu;
        ;;
      esac
    fi
done
