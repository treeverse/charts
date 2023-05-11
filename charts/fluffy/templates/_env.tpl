{{- define "fluffy.env" -}}
env:
  {{- if and .Values.secrets (.Values.secrets).databaseConnectionString }}
  - name: FLUFFY_DATABASE_POSTGRES_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: {{ include "fluffy.fullname" . }}
        key: database_connection_string
  {{- end }}
  {{- if and .Values.sso.enabled (.Values.sso.oidc).client_secret }}
  - name: FLUFFY_AUTH_OIDC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ include "fluffy.fullname" . }}
        key: oidc_client_secret
  {{- end }}
  {{- if and .Values.secrets (.Values.secrets).authEncryptSecretKey }}
  - name: FLUFFY_AUTH_ENCRYPT_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "fluffy.fullname" . }}
        key: auth_encrypt_secret_key
  {{- else }}
  - name: FLUFFY_AUTH_ENCRYPT_SECRET_KEY
    value: asdjfhjaskdhuioaweyuiorasdsjbaskcbkj
  {{- end }}
  {{- if .Values.extraEnvVars }}
  {{- toYaml .Values.extraEnvVars | nindent 2 }}
  {{- end }}
{{- if .Values.extraEnvVarsSecret }}
envFrom:
  - secretRef:
      name: {{ .Values.extraEnvVarsSecret }}
{{- end }}
{{- end }}

{{- define "fluffy.volumes" -}}
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes }}
{{- end }}
{{- if not .Values.fluffyConfig }}
- name: {{ .Chart.Name }}-local-data
{{- end}}
{{- if .Values.fluffyConfig }}
- name: {{ include "fluffy.fullname" . }}-config
  configMap:
    name: {{ include "fluffy.fullname" . }}-config
    items:
      - key: config.yaml
        path: config.yaml
{{- end }}
{{- end }}