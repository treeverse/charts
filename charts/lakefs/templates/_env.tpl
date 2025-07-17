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
  {{- if (.Values.enterprise).enabled}}
  {{- if or (and .Values.secrets .Values.secrets.licenseContents) (and .Values.existingSecret .Values.secretKeys.licenseContentsKey) }}
  - name: LAKEFS_LICENSE_PATH
    value: '/etc/lakefs/license.tkn'
  {{- end }}
  - name: LAKEFS_USAGE_REPORT_ENABLED
    value: "true"
  - name: LAKEFS_FEATURES_LOCAL_RBAC
    value: "{{ (((.Values.enterprise).auth).rbac).enabled | default false }}"
  {{- if (((.Values.enterprise).auth).saml).enabled }}
  - name: LAKEFS_AUTH_COOKIE_AUTH_VERIFICATION_AUTH_SOURCE
    value: saml
  - name: LAKEFS_AUTH_UI_CONFIG_LOGIN_URL
    value: /sso/login-saml
  - name: LAKEFS_AUTH_UI_CONFIG_LOGOUT_URL
    value: /sso/logout-saml
  - name: LAKEFS_AUTH_UI_CONFIG_LOGIN_COOKIE_NAME
    value: "internal_auth_session,saml_auth_session"
  - name: LAKEFS_AUTH_PROVIDERS_SAML_POST_LOGIN_REDIRECT_URL
    value: /
  - name: LAKEFS_AUTH_PROVIDERS_SAML_SP_X509_KEY_PATH
    value: '/etc/saml_certs/rsa_saml_private.key'
  - name: LAKEFS_AUTH_PROVIDERS_SAML_SP_X509_CERT_PATH
    value: '/etc/saml_certs/rsa_saml_public.pem'
  {{- end }}
  {{- if (((.Values.enterprise).auth).oidc).enabled }}
  - name: LAKEFS_AUTH_UI_CONFIG_LOGIN_URL
    value: '/oidc/login'
  - name: LAKEFS_AUTH_UI_CONFIG_LOGOUT_URL
    value: '/oidc/logout'
  - name: LAKEFS_AUTH_UI_CONFIG_LOGIN_COOKIE_NAME
    value: "internal_auth_session,oidc_auth_session"
  {{- if and .Values.existingSecret .Values.secretKeys.oidcClientSecret }}
  - name: LAKEFS_AUTH_PROVIDERS_OIDC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ .Values.existingSecret }}
        key: {{ .Values.secretKeys.oidcClientSecret }}
  {{- else if (((.Values.enterprise).auth).oidc).clientSecret }}
  - name: LAKEFS_AUTH_PROVIDERS_OIDC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: oidc_client_secret
  {{- end }}
  {{- end }}
  {{- if (((.Values.enterprise).auth).ldap).enabled }}
  - name: LAKEFS_AUTH_UI_CONFIG_LOGOUT_URL
    value: /logout
  {{- if and .Values.existingSecret .Values.secretKeys.ldapBindPassword }}
  - name: LAKEFS_AUTH_PROVIDERS_LDAP_BIND_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.existingSecret }}
        key: {{ .Values.secretKeys.ldapBindPassword }}
  {{- else if (((.Values.enterprise).auth).ldap).bindPassword }}
  - name: LAKEFS_AUTH_PROVIDERS_LDAP_BIND_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "lakefs.fullname" . }}
        key: ldap_bind_password
  {{- end }}
  {{- end }}
  {{- if (((.Values.enterprise).auth).rbac).enabled }}
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
{{- if (.Values.enterprise).enabled }}
{{- if and .Values.existingSecret .Values.secretKeys.licenseContentsKey }}
- name: secret-volume-license-token
  secret:
    secretName: {{ .Values.existingSecret }}
    items:
      - key: {{ .Values.secretKeys.licenseContentsKey }}
        path: license.tkn
{{- else if and .Values.secrets .Values.secrets.licenseContents }}
- name: secret-volume-license-token
  secret:
    secretName: {{ include "lakefs.fullname" . }}
    items:
      - key: license_contents
        path: license.tkn
{{- end }}
{{- end }}
{{- if (((.Values.enterprise).auth).saml).enabled }}
- name: secret-volume-license-token
  secret:
    secretName: saml-certificates
{{- end }}
{{- end }}
