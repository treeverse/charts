{{/*
MDS resource full name
*/}}
{{- define "mds.fullname" -}}
{{- $name := include "lakefs.fullname" . }}
{{- printf "%s-mds" $name  | trunc 63 }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mds.labels" -}}
helm.sh/chart: {{ include "lakefs.chart" . }}
{{ include "mds.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mds.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lakefs.name" . }}-mds
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: mds
app: {{ include "lakefs.name" . }}-mds
{{- end }}

{{/*
MDS volumes
*/}}
{{- define "mds.volumes" -}}
- name: {{ include "mds.fullname" . }}-config
  configMap:
    name: {{ include "mds.fullname" . }}-config
    items:
      - key: config.yaml
        path: config.yaml
{{ with .Values.mds.extraVolumes -}}
{{- toYaml . }}
{{- end -}}
{{- end }}
 
{{/*
MDS volume mounts
*/}}
{{- define "mds.volumeMounts" -}}
- name: {{ include "mds.fullname" . }}-config
  mountPath: /app/config.yaml
  subPath: config.yaml
{{ with .Values.mds.extraVolumeMounts -}}
{{- toYaml . }}
{{- end }}
{{- end }}
