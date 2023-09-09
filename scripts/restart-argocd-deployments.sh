#!/usr/bin/env bash

kubectl -n argocd rollout restart deployment argocd-applicationset-controller argocd-notifications-controller argocd-redis argocd-repo-server argocd-server

# https://github.com/argoproj/argo-cd/discussions/11082#discussioncomment-4173381
#kind: Job
#apiVersion: batch/v1
#metadata:
#  name: argocd-bouncer
#  annotations:
#    argocd.argoproj.io/hook: PostSync
#    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
#  labels:
#    app.kubernetes.io/part-of: argocd
#spec:
#  backoffLimit: 1
#  template:
#    spec:
#      serviceAccountName: argocd-bouncer
#      restartPolicy: OnFailure
#      containers:
#        - name: argocd-bouncer
#          image: rancher/kubectl:v1.20.15
#          resources:
#            requests:
#              cpu: 100m
#              memory: 50Mi
#            limits:
#              memory: 50Mi
#          args:
#            - rollout
#            - restart
#            - deployment
#            - argocd-applicationset-controller
#            - argocd-notifications-controller
#            - argocd-redis
#            - argocd-repo-server
#            - argocd-server
#          securityContext:
#            runAsUser: 65534
#            runAsNonRoot: true
#            readOnlyRootFilesystem: true