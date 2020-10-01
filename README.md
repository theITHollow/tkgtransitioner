# TKG transitioner
Apply Post Creation Configs to a TKG Workload cluster once CAPI has provisioned it

When a TKG cluster is created via YAML files deployed to a management cluster, the 
workload clusters do not get a CNI installed by default. This isn't the case when
creating a TKG workload cluster through the TKG cli.

This project is meant to bridget the gap between a mostly provisioned workload cluster
and a fully provisioned cluster by using YAML manifests.

The Dockerfile within this repo will allow you to deploy a Kubernetes Job alongside 
the cluster config manifests. The job will listen for a workload cluster to have a
status of "provisioned" at which point it will attempt to deploy the Calico CNI configs
to the workload cluster to finish the provisioning.

This container/script can be modified to add the cluster to ArgoCD or other tasks needed
once the cluster is in a "provisioned" state.

Adding the attached Kubernetes manifest to a helm chart would allow for the cluster names
to be variablized and used for multiple clusters.
