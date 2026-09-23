{{/*
IQS (Iceberg Query Service) resource full name.
IQS is internal: only the lakeFS server calls it, through a ClusterIP Service.
*/}}
{{- define "iqs.fullname" -}}
{{- $name := include "lakefs.fullname" . }}
{{- printf "%s-iqs" $name | trunc 63 }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "iqs.labels" -}}
helm.sh/chart: {{ include "lakefs.chart" . }}
{{ include "iqs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "iqs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lakefs.name" . }}-iqs
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: iqs
app: {{ include "lakefs.name" . }}-iqs
{{- end }}

{{/*
True when IQS should be deployed. IQS is lakeFS Enterprise only.
*/}}
{{- define "iqs.enabled" -}}
{{- if (.Values.iqs).enabled -}}
{{- if not (.Values.enterprise).enabled -}}
{{- fail "iqs.enabled requires enterprise.enabled: true" -}}
{{- end -}}
true
{{- end -}}
{{- end }}

{{/*
Shared bearer token env var, read by both the lakeFS server and IQS from the
same Secret so the two sides always match. Call with (list <ctx> <env name>).
*/}}
{{- define "iqs.tokenEnv" -}}
{{- $ := index . 0 -}}
{{- if not $.Values.existingSecret }}
{{- $_ := required "secrets.iqsToken is required when iqs.enabled is true (or use existingSecret + secretKeys.iqsToken)" ($.Values.secrets).iqsToken }}
{{- end }}
- name: {{ index . 1 }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.existingSecret | default (include "lakefs.fullname" $) }}
      key: {{ ($.Values.secretKeys).iqsToken | default "iqs_token" }}
{{- end }}

{{/*
Pod annotation that rolls both lakeFS and IQS pods when a chart-managed token
changes. Tokens in existingSecret are not visible to the chart.
*/}}
{{- define "iqs.tokenChecksum" -}}
{{- if and (include "iqs.enabled" .) (not .Values.existingSecret) }}
checksum/iqs-token: {{ required "secrets.iqsToken is required when iqs.enabled is true (or use existingSecret + secretKeys.iqsToken)" (.Values.secrets).iqsToken | sha256sum }}
{{- end }}
{{- end }}
