{{- define "lakefs.env" -}}
env:
  {{- if .Values.secrets }}
  - name: LAKEFS_DATABASE_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: database_connection_string
  - name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: auth_encrypt_secret_key
  {{- else if not .Values.lakefsConfig }}
  - name: LAKEFS_DATABASE_CONNECTION_STRING
    value: postgres://postgres:password@localhost:5432/postgres?sslmode=disable
  - name: LAKEFS_AUTH_ENCRYPT_SECRET_KEY
    value: asdjfhjaskdhuioaweyuiorasdsjbaskcbkj
  {{- end }}
  {{- if not .Values.lakefsConfig }}
  - name: LAKEFS_BLOCKSTORE_LOCAL_PATH
    value: /lakefs/data
  {{- end }}
{{- if .Values.extraEnvVarsSecret }}
envFrom:
  - secretRef:
    name: {{ .Values.extraEnvVarsSecret }}
{{- end }}
{{- end }}

{{- define "lakefs.volumes" -}}
{{- if not .Values.lakefsConfig }}
- name: {{ .Chart.Name }}-postgredb
- name: {{ .Chart.Name }}-local-data
{{- else }}
- name: config-volume
  configMap:
    name: {{ include "lakefs.fullname" . }}
    items:
      - key: config.yaml
        path: config.yaml
{{- end }}
{{- end }}
