{{/*
fluffy resource full name
*/}}
{{- define "fluffy.fullname" -}}
{{- $name := include "lakefs.fullname" }}
{{- printf "%s-fluffy" $name  | trunc 63 | trimSuffix "-" }}
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
{{- lakeFSAcc := include "lakefs.serviceAccountName" . }}
{{- default $lakeFSAcc .Values.fluffy.serviceAccountName }}
{{- end }}
{{- end }}


{{/*
Fluffy environment variables
*/}}

{{- define "fluffy.env" -}}
env:
  {{- if and .Values.fluffy.sso.enabled (.Values.fluffy.sso.oidc).client_secret }}
  - name: FLUFFY_AUTH_OIDC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ include "fluffy.fullname" . }}
        key: oidc_client_secret
  {{- end }}
  {{- if and .Values.secrets (.Values.secrets).authEncryptSecretKey }}
  - name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: auth_encrypt_secret_key
  {{- else }}
  - name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
    value: asdjfhjaskdhuioaweyuiorasdsjbaskcbkj
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
{{- if and .Values.fluffy.sso.enabled (.Values.fluffy.sso.saml).enabled }}
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