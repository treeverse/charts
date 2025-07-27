{{/*
arktika resource full name
*/}}
{{- define "arktika.fullname" -}}
{{- $name := include "lakefs.fullname" . }}
{{- printf "%s-arktika" $name  | trunc 63 }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "arktika.labels" -}}
helm.sh/chart: {{ include "lakefs.chart" . }}
{{ include "arktika.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arktika.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lakefs.name" . }}-arktika
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Arktika volumes
*/}}
{{- define "arktika.volumes" -}}
{{- with .Values.mds.extraVolumes -}}
{{- toYaml . }}
{{- end }}
- name: {{ include "arktika.fullname" . }}-config
  configMap:
    name: {{ include "arktika.fullname" . }}-config
    items:
      - key: config.yaml
        path: config.yaml
{{- end }}

{{/*
Arktika volume mounts
*/}}
{{- define "arktika.volumeMounts" -}}
{{- with .Values.mds.extraVolumeMounts -}}
{{- toYaml . }}
{{- end }}
- name: {{ include "arktika.fullname" . }}-config
  mountPath: /app/config.yaml
  subPath: config.yaml
{{- end }}
