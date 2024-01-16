{{/*
fluffy resource full name
*/}}
{{- define "fluffy.fullname" -}}
{{- $name := include "lakefs.fullname" . }}
{{- printf "%s-fluffy" $name  | trunc 63 }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fluffy.labels" -}}
helm.sh/chart: {{ include "lakefs.chart" . }}
{{ include "fluffy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fluffy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lakefs.name" . }}-fluffy
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fluffy.serviceAccountName" -}}
{{- $lakeFSAcc := include "lakefs.serviceAccountName" . }}
{{- default $lakeFSAcc .Values.fluffy.serviceAccountName }}
{{- end }}

{{/*
fluffy SSO service name
*/}}
{{- define "fluffy.ssoServiceName" -}}
{{- printf "fluffy-sso" }}
{{- end }}

{{/*
fluffy Authorization service name
*/}}
{{- define "fluffy.rbacServiceName" -}}
{{- printf "fluffy-rbac" }}
{{- end }}


{{/*
Fluffy environment variables
*/}}

{{- define "fluffy.env" -}}
env:
  {{- if (.Values.fluffy.sso).enabled }}
  {{- if and .Values.ingress.enabled (.Values.fluffy.sso.saml).enabled }}
  - name: FLUFFY_AUTH_SAML_ENABLED
    value: "true"
  - name: FLUFFY_AUTH_LOGOUT_REDIRECT_URL
    value: {{ .Values.fluffy.sso.saml.lakeFSServiceProviderIngress }}
  - name: FLUFFY_AUTH_POST_LOGIN_REDIRECT_URL
    value: {{ .Values.fluffy.sso.saml.lakeFSServiceProviderIngress }}
  - name: FLUFFY_AUTH_SAML_SP_ROOT_URL
    value: {{ .Values.fluffy.sso.saml.lakeFSServiceProviderIngress }}
  - name: FLUFFY_AUTH_SAML_SP_X509_KEY_PATH
    value: '/etc/saml_certs/rsa_saml_private.key'
  - name: FLUFFY_AUTH_SAML_SP_X509_CERT_PATH
    value: '/etc/saml_certs/rsa_saml_public.pem'
  {{- end }}
  {{- if (.Values.fluffy.sso.oidc).enabled }}
  - name: FLUFFY_AUTH_POST_LOGIN_REDIRECT_URL
    value: '/'
  {{- if (.Values.fluffy.sso.oidc).client_secret }}
  - name: FLUFFY_AUTH_OIDC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ include "fluffy.fullname" . }}
        key: oidc_client_secret
  {{- end }}
  {{- end }}
  {{- if (.Values.fluffy.sso.ldap).enabled }}
  - name: FLUFFY_AUTH_LDAP_BIND_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "fluffy.fullname" . }}
        key: ldap_bind_password
  {{- end }}
  {{- end }}
  {{- if .Values.existingSecret }}
  - name: FLUFFY_AUTH_ENCRYPT_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ .Values.existingSecret }}
        key: {{ .Values.secretKeys.authEncryptSecretKey }}
  {{- else if and .Values.secrets (.Values.secrets).authEncryptSecretKey }}
  - name: FLUFFY_AUTH_ENCRYPT_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: auth_encrypt_secret_key
  {{- else }}
  - name: FLUFFY_AUTH_ENCRYPT_SECRET_KEY
    value: asdjfhjaskdhuioaweyuiorasdsjbaskcbkj
  {{- end }}
  {{- if and (.Values.fluffy.rbac).enabled }}
  - name: FLUFFY_AUTH_SERVE_LISTEN_ADDRESS
    value: {{ printf ":%s" (include "fluffy.rbac.containerPort" .) }}
  {{- end }}
  {{- if and .Values.existingSecret .Values.secretKeys.databaseConnectionString }}
  - name: FLUFFY_DATABASE_POSTGRES_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: {{ .Values.existingSecret }}
        key: {{ .Values.secretKeys.databaseConnectionString }}
  {{- else if and .Values.secrets (.Values.secrets).databaseConnectionString }}
  - name: FLUFFY_DATABASE_POSTGRES_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: database_connection_string
  {{- else if and .Values.useDevPostgres (.Values.fluffy.rbac).enabled }}
  - name: FLUFFY_DATABASE_TYPE
    value: postgres
  - name: FLUFFY_DATABASE_POSTGRES_CONNECTION_STRING
    value: 'postgres://lakefs:lakefs@postgres-server:5432/postgres?sslmode=disable'
  {{- end }}
  {{- if .Values.fluffy.extraEnvVars }}
  {{- toYaml .Values.fluffy.extraEnvVars | nindent 2 }}
  {{- end }}
{{- if .Values.fluffy.extraEnvVarsSecret }}
envFrom:
  - secretRef:
      name: {{ .Values.fluffy.extraEnvVarsSecret }}
{{- end }}
{{- end }}

{{- define "fluffy.volumes" -}}
{{- if .Values.fluffy.extraVolumes }}
{{ toYaml .Values.fluffy.extraVolumes }}
{{- end }}
{{- if not .Values.fluffy.fluffyConfig }}
- name: {{ .Chart.Name }}-local-data
{{- end}}
{{- if (.Values.fluffy.sso.saml).enabled }}
- name: secret-volume
  secret:
    secretName: saml-certificates
{{- end }}
{{- if .Values.fluffy.fluffyConfig }}
- name: {{ include "fluffy.fullname" . }}-config
  configMap:
    name: {{ include "fluffy.fullname" . }}-config
    items:
      - key: config.yaml
        path: config.yaml
{{- end }}
{{- end }}

{{- define "fluffy.ingressOverrides" -}}
{{- $serviceName :=  include "fluffy.ssoServiceName" . -}}
{{- $gitVersion := .Capabilities.KubeVersion.GitVersion  -}}
{{- $pathsOverrides := list "/oidc/" "/api/v1/oidc/" "/saml/" "/sso/" "/api/v1/ldap/" }}
{{- range $pathsOverrides }}
- path: {{ . }}
{{- if semverCompare ">=1.19-0" $gitVersion }}
  pathType: Prefix
  backend:
    service:
      name: {{ $serviceName }}
      port: 
        number: 80
{{- else }} 
  backend:
    serviceName: {{ $serviceName }}
    servicePort: 80
{{- end }}
{{- end }}
{{- end }}

{{- define "fluffy.dockerConfigJson" }}
{{- $token := .Values.fluffy.image.privateRegistry.secretToken }}
{{- $username := "externallakefs" }}
{{- $registry := "https://index.docker.io/v1/" }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" $registry $username $token (printf "%s:%s" $username $token | b64enc) | b64enc }}
{{- end }}

{{- define "fluffy.sso.serviceType" }}
{{- default "ClusterIP" (.Values.fluffy.sso.service).type }}
{{- end }}
{{- define "fluffy.rbac.serviceType" }}
{{- default "ClusterIP" (.Values.fluffy.rbac.service).type }}
{{- end }}

{{- define "fluffy.sso.port" }}
{{- default 80 (.Values.fluffy.sso.service).port }}
{{- end }}
{{- define "fluffy.rbac.port" }}
{{- default 80 (.Values.fluffy.rbac.service).port }}
{{- end }}

{{- define "fluffy.sso.containerPort" }}
{{- default 8000 (.Values.fluffy.sso.service).containerPort }}
{{- end }}
{{- define "fluffy.rbac.containerPort" }}
{{- default 9000 (.Values.fluffy.rbac.service).containerPort }}
{{- end }}
