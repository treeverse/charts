{{- define "lakefs.gcpProxyContainer" }}
{{- if .Values.lakefsConfig }}
{{ $config := .Values.lakefsConfig | fromYaml  }}
{{- end }}
{{- if .Values.gcpFallback.enabled }}
- name: gcp-proxy
  image: eu.gcr.io/cloudsql-docker/gce-proxy:1.33.4
  imagePullPolicy: IfNotPresent
  command:
    - /cloud_sql_proxy
    - -term_timeout=10s
  env:
{{- if .Values.gcpFallback.instances }}
  - name: INSTANCES
    value: {{ .Values.gcpFallback.instances }}
{{- end }}
{{- end }}
{{- end }}
