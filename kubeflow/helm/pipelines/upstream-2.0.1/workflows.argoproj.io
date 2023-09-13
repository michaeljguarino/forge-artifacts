apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    internal.kpt.dev/upstream-identifier: apiextensions.k8s.io|CustomResourceDefinition|default|workflows.argoproj.io
  labels:
    application-crd-id: kubeflow-pipelines
  name: workflows.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: Workflow
    listKind: WorkflowList
    plural: workflows
    shortNames:
      - wf
    singular: workflow
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - description: Status of the workflow
          jsonPath: .status.phase
          name: Status
          type: string
        - description: When the workflow was started
          format: date-time
          jsonPath: .status.startedAt
          name: Age
          type: date
      name: v1alpha1
      schema:
        openAPIV3Schema:
          properties:
            apiVersion:
              type: string
            kind:
              type: string
            metadata:
              type: object
            spec:
              type: object
              x-kubernetes-map-type: atomic
              x-kubernetes-preserve-unknown-fields: true
            status:
              type: object
              x-kubernetes-map-type: atomic
              x-kubernetes-preserve-unknown-fields: true
          required:
            - metadata
            - spec
          type: object
      served: true
      storage: true
      subresources: {}
