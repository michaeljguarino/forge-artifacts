{{ $argocdNamespace := namespace "argo-cd" }}
{{ $creds := secret $argocdNamespace "argocd-initial-admin-secret" }}
You can view your installation at https://{{ .Values.hostname }}

{{ if .OIDC }}
It looks like you've enabled OIDC!  Login will be managed by plural from now on,
feel free to add your teammembers in the OIDC configuration page in the plural UI.
{{ else }}
Your initial admin credentials are:

Username: admin
Password: {{ $creds.password }}

It's strongly recommended to rotate this password immediately if you intend to share this repository.
{{ end }}