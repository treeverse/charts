{{- define "lakefs.env" -}}
env:
  {{- if and .Values.secrets (.Values.secrets).databaseConnectionString }}
  - name: LAKEFS_DATABASE_POSTGRES_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: database_connection_string
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
  {{- if and (.Values.fluffy).enabled (.Values.fluffy.rbac).enabled }}
  - name: LAKEFS_AUTH_API_ENDPOINT
    value: {{ printf "http://%s/api/v1" (include "fluffy.rbacServiceName" .) | quote }}
  - name: LAKEFS_AUTH_UI_CONFIG_RBAC
    value: internal
  {{- end }}
  {{- if .Values.s3Fallback.enabled }}
  - name: LAKEFS_GATEWAYS_S3_FALLBACK_URL
    value: http://localhost:7001
  {{- end }}
  {{- if .Values.committedLocalCacheVolume }}
  - name: LAKEFS_COMMITTED_LOCAL_CACHE_DIR
    value: /lakefs/cache
  {{- end }}
  {{- if .Values.useDevPostgres }}
  - name: LAKEFS_DATABASE_TYPE
    value: postgres
  - name: LAKEFS_DATABASE_POSTGRES_CONNECTION_STRING
    value: 'postgres://lakefs:lakefs@postgres-server:5432/postgres?sslmode=disable'
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

{{- define "lakefs.volumes" -}}
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes }}
{{- end }}
{{- if .Values.committedLocalCacheVolume }}
- name: committed-local-cache
{{- toYaml .Values.committedLocalCacheVolume | nindent 2 }}
{{- end }}
{{- if not .Values.lakefsConfig }}
- name: {{ .Chart.Name }}-local-data
{{- end}}
{{- if .Values.lakefsConfig }}
- name: config-volume
  configMap:
    name: {{ include "lakefs.fullname" . }}
    items:
      - key: config.yaml
        path: config.yaml
{{- end }}
{{- end }}
