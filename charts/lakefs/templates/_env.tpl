{{- define "lakefs.env" -}}
env:
  {{- if and .Values.existingSecret .Values.secretKeys.databaseConnectionString }}
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
  {{- if (.Values.fluffy).enabled }}
  - name: LAKEFS_USAGE_REPORT_ENABLED
    value: "true"
  {{- if (.Values.fluffy.sso).enabled }}
  - name: LAKEFS_AUTH_AUTHENTICATION_API_ENDPOINT
    value: {{ printf "http://%s/api/v1" (include "fluffy.ssoServiceName" .) | quote }}
  {{- if and .Values.ingress.enabled (.Values.fluffy.sso.saml).enabled }}
  - name: LAKEFS_AUTH_COOKIE_AUTH_VERIFICATION_AUTH_SOURCE
    value: saml
  - name: LAKEFS_AUTH_UI_CONFIG_LOGIN_URL
    value: {{ printf "%s/sso/login-saml" .Values.fluffy.sso.saml.lakeFSServiceProviderIngress }}
  - name: LAKEFS_AUTH_UI_CONFIG_LOGOUT_URL
    value: {{ printf "%s/sso/logout-saml" .Values.fluffy.sso.saml.lakeFSServiceProviderIngress }}
  {{- end }}
  {{- if (.Values.fluffy.sso.oidc).enabled }}
  - name: LAKEFS_AUTH_UI_CONFIG_LOGIN_URL
    value: '/oidc/login'
  - name: LAKEFS_AUTH_UI_CONFIG_LOGOUT_URL
    value: '/oidc/logout'
  {{- end }}
  {{- if (.Values.fluffy.sso.ldap).enabled }}
  - name: LAKEFS_AUTH_REMOTE_AUTHENTICATOR_ENDPOINT
    value: {{ default (printf "http://%s/api/v1/ldap/login" (include "fluffy.ssoServiceName" .) | quote) (.Values.fluffy.sso.ldap).endpointOverride }}
  - name: LAKEFS_AUTH_UI_CONFIG_LOGOUT_URL
    value: /logout
  {{- end }}
  {{- end }}
  {{- if (.Values.fluffy.rbac).enabled }}
  - name: LAKEFS_AUTH_API_ENDPOINT
    value: {{ printf "http://%s/api/v1" (include "fluffy.rbacServiceName" .) | quote }}
  - name: LAKEFS_AUTH_UI_CONFIG_RBAC
    value: internal
  {{- end }}
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
  {{- if and (.Values.fluffy).enabled (.Values.fluffy.rbac).enabled }}
  - name: LAKEFS_DATABASE_TYPE
    value: postgres
  - name: LAKEFS_DATABASE_POSTGRES_CONNECTION_STRING
    value: 'postgres://lakefs:lakefs@postgres-server:5432/postgres?sslmode=disable'
  {{- end }}
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
