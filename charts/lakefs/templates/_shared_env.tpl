{{/*
Secret-backed env vars shared by the lakeFS server and the MDS pod.

Both run the same `lakefs` binary and read the same underlying configuration
keys (KV store connection, auth-encrypt key, license path), so this helper
emits the common entries from a single source of truth. The caller wraps
them in its own `env:` block.

`useDevPostgres` short-circuits the secret-backed DB connection string so
the env var is never emitted twice.
*/}}
{{- define "lakefs.sharedSecretEnv" -}}
{{- if .Values.useDevPostgres }}
- name: LAKEFS_DATABASE_TYPE
  value: postgres
- name: LAKEFS_DATABASE_POSTGRES_CONNECTION_STRING
  value: 'postgres://lakefs:lakefs@postgres-server:5432/postgres?sslmode=disable'
{{- else if and .Values.existingSecret .Values.secretKeys.databaseConnectionString }}
- name: LAKEFS_DATABASE_POSTGRES_CONNECTION_STRING
  valueFrom:
    secretKeyRef:
      name: {{ .Values.existingSecret }}
      key: {{ .Values.secretKeys.databaseConnectionString }}
{{- else if and .Values.secrets (.Values.secrets).databaseConnectionString }}
- name: LAKEFS_DATABASE_POSTGRES_CONNECTION_STRING
  valueFrom:
    secretKeyRef:
      name: {{ include "lakefs.fullname" . }}
      key: database_connection_string
{{- end }}
{{- if .Values.existingSecret }}
- name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.existingSecret }}
      key: {{ .Values.secretKeys.authEncryptSecretKey }}
{{- else if and .Values.secrets (.Values.secrets).authEncryptSecretKey }}
- name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "lakefs.fullname" . }}
      key: auth_encrypt_secret_key
{{- else }}
- name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
  value: asdjfhjaskdhuioaweyuiorasdsjbaskcbkj
{{- end }}
{{- if (.Values.enterprise).enabled }}
{{- if or (and .Values.secrets .Values.secrets.licenseContents) (and .Values.existingSecret .Values.secretKeys.licenseContentsKey) }}
- name: LAKEFS_LICENSE_PATH
  value: '/etc/lakefs/license.tkn'
{{- end }}
{{- end }}
{{- end }}
