#! /bin/bash

# find out what status the cluster is in
get_cluster_status(){
    local cluster=$1
    status=$(kubectl get cluster $1 -o json | jq '.status.phase')
    echo $status
}

# get tkg credentials for a cluster
get_creds(){
    local cluster=$1
    ###result=$(tkg get credentials $1)
    kubectl get secret $1-kubeconfig -o jsonpath='{.data.value}' | base64 -d > ./$1-kubeconfig
    echo $result
}

# install post_creation scripts
postcreation(){
    local cluster=$1
    export KUBECONFIG=./$1-kubeconfig
    sleep 60
    #run postcreation steps yaml in the child cluster
    result=$(kubectl apply -f postcreation_steps.yaml --context=$1-admin@$1)
    if [ $? -eq 0 ]; then
        echo "Task Succeeded"
    else
        echo "FAIL"
        arr=($result)
        echo "Writing arguments"
        echo ${arr[0]}
        until [[ ${arr[0]} != Error ]]
        do
            echo "An error occurred. This operation will be retried when the cluster is ready"
            #wait before retrying
            sleep 30
            result=$(kubectl apply -f postcreation_steps.yaml --context=$1-admin@$1)
            arr=($result)
        done
        echo $result
    fi
    #check to make sure the command was successfully executed if not, wait and
    #repeat

}

i=1
clusterstatus=NULL
#timeout at (60 loops * 30 seconds) = 30 minutes
until [ $i -gt 60 ]
do 
    clusterstatus=$(get_cluster_status $1)
    if [[ $clusterstatus == '"Provisioned"' ]]
    then
        echo "Cluster has been provisioned"
        creds=$(get_creds $1)
        postresult=$(postcreation $1)
        echo $postresult
        # Do Other Stuff here ######
        #
        ############################
        break

    else
        echo "Waiting on Cluster..."
    fi
    
    #timeout
    i=$(( i+1 )) 
    sleep 30
done

